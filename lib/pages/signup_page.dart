import 'package:flutter/material.dart';
import '../main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController id = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController ageGroup = TextEditingController();
  final TextEditingController pw = TextEditingController();
  final TextEditingController pw2 = TextEditingController();

  // 나이대 선택 옵션
  final List<String> ageOptions = ["10대", "20대", "30대", "40대", "50대 이상"];
  String? selectedAge;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 480 ? 420.0 : double.infinity;

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
                    decoration: AppStyles.input("아이디를 입력하세요"),
                  ),
                  const SizedBox(height: 12),

                  // 이름
                  TextField(
                    controller: username,
                    decoration: AppStyles.input("이름을 입력하세요"),
                  ),
                  const SizedBox(height: 12),

                  // 전화번호
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: AppStyles.input("전화번호를 입력하세요"),
                  ),
                  const SizedBox(height: 12),

                  // 나이대 선택 (Dropdown)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF4F8),
                      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                      border: Border.all(color: const Color(0xFFE9E0EE)),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedAge,
                      underline: const SizedBox(),
                      hint: const Text("나이대를 선택하세요"),
                      items: ageOptions.map((age) {
                        return DropdownMenuItem(
                          value: age,
                          child: Text(age),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAge = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 비밀번호
                  TextField(
                    controller: pw,
                    obscureText: true,
                    decoration: AppStyles.input("비밀번호를 입력하세요"),
                  ),
                  const SizedBox(height: 12),

                  // 비밀번호 확인
                  TextField(
                    controller: pw2,
                    obscureText: true,
                    decoration: AppStyles.input("비밀번호를 다시 입력하세요"),
                  ),
                  const SizedBox(height: 20),

                  // 회원가입 버튼
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 백엔드 register API 연결
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("회원가입 버튼 클릭됨")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
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
