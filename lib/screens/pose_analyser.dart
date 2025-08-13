import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartan/models/ImageMetadata.dart';
import 'package:smartan/screens/image_detail_screen.dart';
import 'package:smartan/services/firebase_service.dart';
import 'package:smartan/services/firebase_upload_service.dart';

class PoseGalleryScreen extends StatefulWidget {
  const PoseGalleryScreen({Key? key}) : super(key: key);

  @override
  State<PoseGalleryScreen> createState() => _PoseGalleryScreenState();
}

class _PoseGalleryScreenState extends State<PoseGalleryScreen> {
  List<ImageMetadata> images = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await FirestoreService.instance.fetchImageMetadata();
      setState(() {
        images = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load images. Please try again.';
        loading = false;
      });
    }
  }

  Future<File> downloadImage(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: loadImages, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (images.isEmpty) {
      return const Center(child: Text('No images found.'));
    }

    return RefreshIndicator(
      onRefresh: loadImages,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final img = images[index];
          return GestureDetector(
            onTap: () async {
              final imageId = p.basenameWithoutExtension(
                img.localPath,
              );
              // Download original image from remoteUrl
              final response = await http.get(Uri.parse(img.remoteUrl));
              final tempFile = File(
                '${Directory.systemTemp.path}/$imageId${p.extension(img.localPath)}',
              );
              await tempFile.writeAsBytes(response.bodyBytes);

              // Upload to Firebase (optional)
              final firebaseUrl = await FirebaseUploadService()
                  .uploadMappedImage(tempFile, imageId);
              if (firebaseUrl == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to upload image')),
                );
                return;
              }

              // Send to backend for pose extraction
              final request = http.MultipartRequest(
                'POST',
                Uri.parse('http://172.17.14.67:3000/extract?imageId=$imageId'),
              );
              request.files.add(
                await http.MultipartFile.fromPath('image', tempFile.path),
              );
              final responseExtract = await request.send();

              if (responseExtract.statusCode != 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pose extraction failed')),
                );
                return;
              }

              // ✅ Now fetch processed image + keypoints
              final poseResponse = await http.get(
                Uri.parse('http://172.17.14.67:3000/pose/$imageId'),
              );
              if (poseResponse.statusCode != 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pose data not available')),
                );
                return;
              }

              final poseData = jsonDecode(poseResponse.body);
              final mappedUrl = poseData['mappedImage'];
              final keypoints = List<Map<String, dynamic>>.from(
                poseData['keypoints'],
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageDetailScreen(
                    imagePath: mappedUrl,
                    timestamp: img.timestamp,
                    isSynced: true,
                    keypoints: keypoints,
                  ),
                ),
              );
            },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      img.remoteUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(img.timestamp),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
