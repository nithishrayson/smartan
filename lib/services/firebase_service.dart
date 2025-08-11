import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartan/models/ImageMetadata.dart';
import 'package:smartan/models/pose_data.dart';

class FirestoreService {
  final _collection = FirebaseFirestore.instance.collection('images');
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  Future<void> uploadMetadata(ImageMetadata image) async {
    await _collection.doc(image.id).set(image.toMap());
  }

  Future<List<PoseEntry>> fetchCloudEntries() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pose_entries')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => PoseEntry.fromFirestore(doc)).toList();
  }

  Future<List<ImageMetadata>> fetchImageMetadata() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('images')
          .orderBy('timestamp', descending: true)
          .get();

      print('Firestore returned ${snapshot.docs.length} docs');

      return snapshot.docs.map((doc) {
        final data = doc.data();
        print('Image doc: $data');
        return ImageMetadata.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching image metadata: $e');
      return [];
    }
  }
}
