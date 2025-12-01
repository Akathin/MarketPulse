import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl = "http://10.0.2.2:8001"; 
  // 👉 Android 에뮬레이터: 10.0.2.2
  // 👉 실제 기기: 서버 IP로 변경해야 함

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
        "username": userId,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // access_token 반환됨
    } else {
      throw Exception(jsonDecode(response.body)["detail"]);
    }
  }

  /// 회원가입 요청
  static Future<Map<String, dynamic>> register({
    required String userId,
    required String username,
    required String password,
    required String phoneNumber,
    required int ageGroup,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "username": username,
        "password": password,
        "phone_number": phoneNumber,
        "age_group": ageGroup,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // access_token 반환
    } else {
      throw Exception(jsonDecode(response.body)["detail"]);
    }
  }
}
