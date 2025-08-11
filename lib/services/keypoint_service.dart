import 'package:http/http.dart' as http;
import 'dart:convert';

class KeypointService {
  static Future<List<Map<String, dynamic>>?> getKeypoints(String imagePath) async {
    final uri = Uri.parse('http:10.0.2.23000/extract');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      return List<Map<String, dynamic>>.from(data['keypoints']);
    } else {
      return null;
    }
  }
}