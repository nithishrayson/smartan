import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
class BackendService {
  static Future<Map<String, dynamic>> getKeypoints(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final response = await http.post(
      Uri.parse('http://your-node-backend-url/analyze'),
      headers: {'Content-Type': 'application/octet-stream'},
      body: bytes,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get keypoints');
    }
  }
}