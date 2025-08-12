import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageUploadService {
  final String baseUrl = 'https://smartanserver-production.up.railway.app'; 

  Future<String?> uploadImage(File imageFile) async {
  final uri = Uri.parse('https://smartanserver-production.up.railway.app/upload');
  final request = http.MultipartRequest('POST', uri);

  request.files.add(await http.MultipartFile.fromPath(
    'image', imageFile.path,
    contentType: MediaType('image', 'jpeg'),
  ));

  try {
    final response = await request.send().timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final uploadedPath = jsonDecode(responseBody)['files'][0];
      return uploadedPath;
    } else {
      print('Upload failed: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error during upload: $e');
    return null;
  }
}
}