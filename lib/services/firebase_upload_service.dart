import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseUploadService {
  final _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile) async {
    final id = const Uuid().v4();
    final ref = _storage.ref().child('uploads/$id.jpg');

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}