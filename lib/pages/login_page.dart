import 'package:flutter/material.dart';
import 'signup_page.dart';
import '../main.dart';
import '../services/auth_api_service.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.horizontalPadding,
              vertical: AppStyles.verticalPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const _LogoSection(),
                  const SizedBox(height: 20),
                  const _LoginInputSection(),
                  const SizedBox(height: 12),
                  const _LoginOptionsRow(),
                  const SizedBox(height: 18),
                  _SocialButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '주식, 암호화폐 등 경제관련\n최근 소식과 정보를 알고 싶으시다면',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(
          'Market\nPulse',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = Colors.blueGrey.shade300,
          ),
        ),
      ],
    );
  }
}

class _LoginInputSection extends StatefulWidget {
  const _LoginInputSection();

  @override
  State<_LoginInputSection> createState() => _LoginInputSectionState();
}

class _LoginInputSectionState extends State<_LoginInputSection> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  bool autoLogin = false;

  Future<void> _handleLogin() async {
    final userId = idController.text.trim();
    final password = pwController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("아이디와 비밀번호를 입력해주세요.")),
      );
      return;
    }

    try {
      final result = await AuthApiService.login(
        userId: userId,
        password: password,
      );

      final accessToken = result["access_token"];

      // 자동 로그인 시 토큰 저장
      if (autoLogin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", accessToken);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 480
        ? 420.0
        : double.infinity;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: idController,
            decoration: AppStyles.input('아이디를 입력하세요'),  // ✅ 수정됨
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pwController,
            obscureText: true,
            decoration: AppStyles.input('비밀번호를 입력하세요'), // ✅ 수정됨
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Checkbox(
                value: autoLogin,
                onChanged: (v) {
                  setState(() {
                    autoLogin = v ?? false;
                  });
                },
              ),
              const Text('자동 로그인'),
            ],
          ),
          const SizedBox(height: 6),

          // ElevatedButton(
          //   onPressed: _handleLogin,
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppStyles.primary,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(vertical: 14),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          //     ),
          //   ),
          //   child: const Text('로그인', style: TextStyle(fontSize: 16)),
          // ),
          ElevatedButton(
            onPressed: () {
              // 🔥 서버 없이 바로 홈 화면으로 이동 (테스트용)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
}


class _LoginOptionsRow extends StatelessWidget {
  const _LoginOptionsRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: () {},
            child: const Text('로그인 없이 둘러보기')),
        TextButton(
            onPressed: () {
              _showTermsBottomSheet(context);
            },
            child: const Text('회원가입하기')),
      ],
    );
  }
}

/// SNS 버튼 묶음 (네이버 / 카카오)
class _SocialButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 480
        ? 420.0
        : double.infinity;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
          ),
        ],
      ),
    );
  }
}


/// ─────────────────────────────────────────
///   📌 약관 BottomSheet 함수
/// ─────────────────────────────────────────
void _showTermsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.35, // 화면의 1/3 크기
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "회원가입을 위해 약관에 동의해주세요",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    "여기에 간단한 약관 요약...\n"
                    "필요하다면 실제 약관 내용 삽입 가능",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // bottomsheet 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("동의하고 회원가입", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      );
    },
  );
}
