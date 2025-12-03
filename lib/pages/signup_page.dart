import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../main.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController id = TextEditingController();
  final TextEditingController pw = TextEditingController();
  final TextEditingController pw2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final maxWidth =
        MediaQuery.of(context).size.width > 480 ? 420.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.horizontalPadding,
            vertical: 18,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Market\nPulse',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // 아이디
                 TextField(

                  controller: id,
                  maxLength: 50, // 아이디 최대 50자
                  decoration: AppStyles.input("아이디를 입력하세요"),
                  ),
                  const SizedBox(height: 12),

                  // 비밀번호
                  TextField(
                    controller: pw,
                    obscureText: true,
                    maxLength: 40,
                    decoration: AppStyles.input("비밀번호를 입력하세요"),
                  ),
                  const SizedBox(height: 12),

                  // 비밀번호 확인
                  TextField(
                    controller: pw2,
                    obscureText: true,
                    maxLength: 40,
                    decoration: AppStyles.input("비밀번호를 다시 입력하세요"),
                  ),
                  const SizedBox(height: 20),   

                  // 회원가입 버튼
                  ElevatedButton(
                    onPressed: () async {
                      final userId = id.text.trim();
                      final password = pw.text.trim();
                      final passwordConfirm = pw2.text.trim();

                      // 입력 검증
                      if (userId.isEmpty ||
                          password.isEmpty ||
                          passwordConfirm.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("모든 입력칸을 채워주세요")),
                        );
                        return;
                      }

                      if (password != passwordConfirm) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("비밀번호가 일치하지 않습니다")),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("회원가입 진행 중...")),
                      );

                      try {
                        // Flutter Web이므로 localhost 사용
                        final uri = Uri.parse(
                            'http://localhost:8001/api/auth/register');

                        // 백엔드 UserCreate 스키마에 맞게 전송
                        final res = await http.post(
                          uri,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'user_id': userId,
                            'password': password,
                            'password_confirm': passwordConfirm,
                          }),
                        );

                        if (res.statusCode == 200 ||
                            res.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("회원가입 완료")),
                          );
                          // 로그인 페이지로 이동
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        } else {
                          String msg =
                              '회원가입 실패 (${res.statusCode})';
                          try {
                            final body = jsonDecode(res.body);
                            if (body is Map &&
                                body['detail'] != null) {
                              msg = body['detail'].toString();
                            }
                          } catch (_) {}
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("오류: ${e.toString()}")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppStyles.borderRadius),
                      ),
                    ),
                    child: const Text("회원가입"),
                  ),

                  const SizedBox(height: 18),

                  // 네이버 로그인
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.naver,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppStyles.borderRadius),
                      ),
                    ),
                    child: const Text("네이버 로그인"),
                  ),
                  const SizedBox(height: 12),

                  // 카카오 로그인
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.kakao,
                      foregroundColor: Colors.black,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppStyles.borderRadius),
                      ),
                    ),
                    child: const Text("카카오 로그인"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
