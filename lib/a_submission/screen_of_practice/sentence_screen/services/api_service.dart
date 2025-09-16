import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://66ed21bf380821644cdb8c6d.mockapi.io/submission';

  // Model class for paragraph data
  static Map<String, dynamic> _parseParagraphData(Map<String, dynamic> json) {
    return {
      'id': json['id'] ?? 0,
      'title': json['title'] ?? 'Untitled',
      'content': json['content'] ?? '',
    };
  }

  // Fetch all paragraphs from MockAPI
  static Future<List<Map<String, dynamic>>> fetchParagraphs() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => _parseParagraphData(item)).toList();
      } else {
        throw Exception('Failed to load paragraphs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching paragraphs: $e');
    }
  }

  // Get paragraph by ID
  static Future<Map<String, dynamic>?> getParagraphById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseParagraphData(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load paragraph: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching paragraph: $e');
    }
  }
}