import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  // 🔹 Flutter Web에서는 localhost 사용
  static const String baseUrl = "http://localhost:8001";

  /// 로그인 요청
  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": userId, // FastAPI OAuth2PasswordRequestForm의 username 필드
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>; // access_token 포함
    } else {
      throw Exception(jsonDecode(response.body)["detail"]);
    }
  }

  /// 회원가입 요청 (user_id + password + password_confirm 만 사용하는 경우)
  static Future<Map<String, dynamic>> register({
    required String userId,
    required String password,
    required String passwordConfirm,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "password": password,
        "password_confirm": passwordConfirm,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>; // access_token 포함
    } else {
      throw Exception(jsonDecode(response.body)["detail"]);
    }
  }
}
