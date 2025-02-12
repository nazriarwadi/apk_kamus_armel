// File: api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiService {
  // Fungsi untuk mengambil data dictionary
  Future<List<Map<String, String>>> fetchDictionaryData() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/dictionary_api.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Menyaring data yang diinginkan, hanya 'word' dan 'translation'
          List<Map<String, String>> dictionaryData =
              List<Map<String, String>>.from(data['data'].map((item) => {
                    'word': item['word'].toString(),
                    'translation': item['translation'].toString(),
                  }));

          return dictionaryData;
        } else {
          throw Exception('Tidak ada data ditemukan');
        }
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // Menambahkan print error ke console debug
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<List<Map<String, String>>> fetchSearchResults(
      String searchWord) async {
    try {
      // Mengirimkan permintaan POST ke API untuk pencarian kata
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/search_dictionary.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'word': searchWord}, // Mengirimkan kata yang dicari
      );

      // Jika respons sukses (200)
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['message'] == 'Pencarian berhasil') {
          List<Map<String, String>> searchResults = [];

          // Cek apakah data['data'] berupa list atau objek tunggal
          if (data['data'] is List) {
            for (var item in data['data']) {
              searchResults.add({
                'word': item['word'].toString(),
                'translation': item['translation'].toString(),
              });
            }
          } else if (data['data'] is Map) {
            var item = data['data'];
            searchResults.add({
              'word': item['word'].toString(),
              'translation': item['translation'].toString(),
            });
          }

          return searchResults;
        } else {
          return []; // Jika pesan tidak cocok atau tidak ditemukan, kembalikan list kosong
        }
      }

      // Jika respons status 404 (kata tidak ditemukan)
      if (response.statusCode == 404) {
        return []; // Tidak dianggap error, hanya mengembalikan list kosong
      }

      // Jika respons bukan 200 atau 404, lempar error
      throw Exception('Gagal mengambil data: ${response.statusCode}');
    } catch (e) {
      print('Error: $e'); // Debugging log error
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
