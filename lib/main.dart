import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MarketPulseApp());
}

class MarketPulseApp extends StatelessWidget {
  const MarketPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Pulse',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(), // 선택사항
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 공통 스타일 상수
class AppStyles {
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 20.0;
  static const borderRadius = 10.0;
  static const Color primary = Color(0xFF8A6FA0); // 보라 계열 로그인 버튼
  static const Color naver = Color(0xFF03C75A);
  static const Color kakao = Color(0xFFFEE500);
  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Color(0xFFFDF4F8),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFE9E0EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFCFB8D7)),
      ),
    );
  }
}

/// 로그인 페이지 (초기 화면)
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
            decoration: AppStyles.inputDecoration('아이디를 입력하세요'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pwController,
            obscureText: true,
            decoration: AppStyles.inputDecoration('비밀번호를 입력하세요'),
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
                  }),
              const Text('자동 로그인')
            ],
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {
              // TODO: 실제 로그인 로직 연결
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그인 버튼 클릭')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              ),
            ),
            child: const Text('로그인', style: TextStyle(fontSize: 16)),
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
            onPressed: () {
              // 로그인 없이 둘러보기
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('둘러보기 선택')));
            },
            child: const Text('로그인 없이 둘러보기')),
        TextButton(
            onPressed: () {
              // 회원가입(약관) 화면으로 이동
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TermsPage()),
              );
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
          ElevatedButton(
            onPressed: () {
              // TODO: 네이버 로그인 연동
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('네이버 로그인')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.naver,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // 아이콘 대신 텍스트 (원하면 svg/이미지 추가)
                Text('N', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Text('네이버 로그인', style: TextStyle(fontSize: 16))
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // TODO: 카카오 로그인 연동
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('카카오 로그인')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.kakao,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.chat_bubble, size: 18),
                SizedBox(width: 8),
                Text('카카오 로그인', style: TextStyle(fontSize: 16))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Terms (약관 동의) 화면
class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool t1 = false;
  bool t2 = false;
  bool t3 = false;

  bool get allRequired => t1 && t2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용약관'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.horizontalPadding, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('이용약관에 동의해주세요',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              CheckboxListTile(
                value: t1,
                onChanged: (v) => setState(() => t1 = v ?? false),
                title: const Text('이용약관 1 (필수)'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: t2,
                onChanged: (v) => setState(() => t2 = v ?? false),
                title: const Text('이용약관 2 (필수)'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: t3,
                onChanged: (v) => setState(() => t3 = v ?? false),
                title: const Text('선택 약관 (선택)'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('취소')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: allRequired
                        ? () {
                            // 필수 약관 동의 시 회원가입 화면으로 이동
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const SignUpPage()));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppStyles.borderRadius)),
                    ),
                    child: const Text('동의하기'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Sign Up (회원가입) 화면
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
              horizontal: AppStyles.horizontalPadding, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Market\nPulse',
                      style: TextStyle(
                          fontSize: 36, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  TextField(
                    controller: id,
                    decoration: AppStyles.inputDecoration('아이디를 입력하세요'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pw,
                    obscureText: true,
                    decoration: AppStyles.inputDecoration('비밀번호를 입력하세요'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pw2,
                    obscureText: true,
                    decoration:
                        AppStyles.inputDecoration('비밀번호를 다시 입력하세요'),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 회원가입 로직
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('회원가입 완료(샘플)')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppStyles.borderRadius)),
                    ),
                    child: const Text('회원가입'),
                  ),
                  const SizedBox(height: 18),
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
                    child: const Text('네이버 로그인'),
                  ),
                  const SizedBox(height: 12),
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
                    child: const Text('카카오 로그인'),
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
