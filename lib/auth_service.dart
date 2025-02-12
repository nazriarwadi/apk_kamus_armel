import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class AuthService {
  // Login user dengan API menggunakan form-data
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/login.php');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['username'] = username;
      request.fields['password'] = password;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey("user")) {
          return {
            "success": true,
            "message": data["message"],
            "user": {
              "id": data["user"]["id"],
              "username": data["user"]["username"],
              "role": data["user"]["role"],
            }
          };
        } else {
          return {"success": false, "message": "Data pengguna tidak ditemukan"};
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData["message"] ?? "Gagal login"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }
}
