import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageUploadService {
  final String baseUrl = 'http://172.17.14.67:3000';

  /// Uploads image to `/upload`
  Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse('$baseUrl/upload');
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

  /// Sends image to `/extract` and returns keypoints
  Future<List<Map<String, dynamic>>?> extractKeypoints(File imageFile) async {
    final uri = Uri.parse('$baseUrl/extract');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'image', imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      final response = await request.send().timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = jsonDecode(responseBody);
        print(decoded);
        return List<Map<String, dynamic>>.from(decoded['keypoints']);
      } else {  
        print('Extraction failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during extraction: $e');
      return null;
    }
  }
}
