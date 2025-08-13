import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartan/models/ImageMetadata.dart';

class FirestoreService {
  static final instance = FirestoreService._();
  final _db = FirebaseFirestore.instance;

  FirestoreService._();

  /// Uploads image metadata to Firestore
  Future<void> uploadMetadata(ImageMetadata metadata) async {
    await _db.collection('images').doc(metadata.id).set({
      'filename': metadata.localPath.split('/').last,
      'url': metadata.remoteUrl,
      'timestamp': metadata.timestamp.toIso8601String(),
    });
  }

  

  /// Fetches uploaded image metadata
  Future<List<ImageMetadata>> fetchImageMetadata() async {
    final snapshot = await _db.collection('images').orderBy('timestamp', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ImageMetadata(
        id: doc.id,
        localPath: data['filename'] ?? '',
        remoteUrl: data['url'] ?? '',
        timestamp: DateTime.parse(data['timestamp']),
      );
    }).toList();
  }

  /// Saves pose data (mapped image + keypoints)
  Future<void> savePoseData({
    required String imageId,
    required String mappedUrl,
    required List<Map<String, dynamic>> keypoints,
  }) async {
    await _db.collection('pose_data').doc(imageId).set({
      'mappedUrl': mappedUrl,
      'keypoints': keypoints,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}