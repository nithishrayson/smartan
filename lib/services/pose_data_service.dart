import 'dart:convert';
import 'package:http/http.dart' as http;

class PoseDataService {
  static Future<Map<String, dynamic>?> fetchPoseData(String imageId) async {
    final uri = Uri.parse('http://172.17.14.67:3000/pose/$imageId'); 

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {
          'keypoints': decoded['keypoints'],
          'mappedImage': decoded['mappedImage'],
        };
      } else {
        print('❌ Failed to fetch pose data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching pose data: $e');
      return null;
    }
  }
}