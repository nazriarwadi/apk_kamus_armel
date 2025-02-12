import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class AdminService {
  // Menggunakan baseUrl yang diambil dari ApiConstants
  static final String baseUrl = ApiConstants.baseUrl;

  // Fungsi untuk mendapatkan data dictionary
  static Future<Map<String, dynamic>> getDictionary() async {
    final url = Uri.parse('$baseUrl/dictionary_api.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fungsi untuk menambahkan data dictionary
  static Future<Map<String, dynamic>> addDictionary(
      String word, String translation) async {
    final url = Uri.parse('$baseUrl/dictionary_api.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'word': word,
          'translation': translation,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fungsi untuk memperbarui data dictionary
  static Future<Map<String, dynamic>> updateDictionary(
      int id, String word, String translation) async {
    final url = Uri.parse('$baseUrl/dictionary_api.php');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'word': word,
          'translation': translation,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fungsi untuk menghapus data dictionary
  static Future<Map<String, dynamic>> deleteDictionary(int id) async {
    final url = Uri.parse('$baseUrl/dictionary_api.php');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
