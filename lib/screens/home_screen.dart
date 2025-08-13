import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartan/models/ImageMetadata.dart';
import 'package:smartan/screens/image_detail_screen.dart';
import 'package:smartan/services/LocalDatabaseServices.dart';
import 'package:smartan/services/firebase_service.dart';
import 'package:smartan/services/image_upload_service.dart';
import 'package:smartan/services/image_picker_service.dart';
import 'package:smartan/services/firebase_upload_service.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  final pickerService = ImagePickerService();
  final firebaseUploadService = FirebaseUploadService();
  final localDb = LocalDatabaseService.instance;
  final firestore = FirestoreService.instance;

  Future<void> _pickAndUploadImage({required bool fromCamera}) async {
    final image = fromCamera
        ? await pickerService.pickImageFromCamera()
        : await pickerService.pickImageFromGallery();

    if (image == null) return;

    setState(() {
      _selectedImage = image;
      _isUploading = true;
      _uploadedImageUrl = null;
    });

    // 🔍 Extract pose keypoints before upload
    final poseData = await ImageUploadService().extractKeypoints(image);

    // ✅ Upload image to Firebase
    final uploadedUrl = await firebaseUploadService.uploadImage(image);
    final imageId = const Uuid().v4();

    final metadata = ImageMetadata(
      id: imageId,
      localPath: image.path,
      remoteUrl: uploadedUrl ?? '',
      timestamp: DateTime.now(),
    );

    await localDb.insertImage(metadata);
    await firestore.uploadMetadata(metadata);

    setState(() {
      _uploadedImageUrl = uploadedUrl;
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image uploaded successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // 🖼️ Navigate to ImageDetailScreen with pose overlay
    if (poseData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageDetailScreen(
            imagePath: image.path,
            timestamp: metadata.timestamp,
            isSynced: true,
            keypoints: poseData,
          ),
        ),
      );
    }
  }

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text('Choose Image Source',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickAndUploadImage(fromCamera: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickAndUploadImage(fromCamera: false);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildImageCard({required String title, required Widget imageWidget}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smartan Image Uploader'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                key: ValueKey(_isUploading),
                onPressed: _isUploading ? null : _showImageSourceOptions,
                icon: const Icon(Icons.add_a_photo),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Select Image',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_selectedImage != null)
              _buildImageCard(
                title: 'Selected Image',
                imageWidget:
                    Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
              ),

            if (_uploadedImageUrl != null)
              Column(
                children: [
                  const SizedBox(height: 24),
                  _buildImageCard(
                    title: 'Uploaded Image Preview',
                    imageWidget: Image.network(_uploadedImageUrl!,
                        height: 200, fit: BoxFit.cover),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}