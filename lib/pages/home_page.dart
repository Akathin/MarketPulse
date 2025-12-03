import 'package:flutter/material.dart';
import '../main.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildLogo(),
        actions: [
          Row(
            children: [
              Icon(Icons.notifications_none, color: Colors.grey[800]),
              const SizedBox(width: 4),
              const Text("알림",
                  style: TextStyle(fontSize: 14, color: Colors.black87)),
              const SizedBox(width: 12),
              Icon(Icons.person_outline, color: Colors.grey[800]),
              const SizedBox(width: 4),
              const Text("내정보",
                  style: TextStyle(fontSize: 14, color: Colors.black87)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: Icon(Icons.logout, color: Colors.grey[800]),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("로그아웃",
                    style: TextStyle(fontSize: 14, color: Colors.black87)),
              ),
              const SizedBox(width: 12),
            ],
          )
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _newsCard(
            title: "뉴스 제목 ${index + 1}",
            description: "여기에 뉴스 내용 요약이 들어갑니다. 실제 뉴스로 교체됩니다.",
          );
        },
      ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  /// 로그인 화면과 동일한 Stroke 로고
  Widget _buildLogo() {
    return Text(
      "Market Pulse",
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.blueGrey.shade300,
      ),
    );
  }

  /// 뉴스 카드 디자인
  Widget _newsCard({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(1, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  /// 하단 네비게이션
  Widget _bottomNav() {
    return BottomNavigationBar(
      selectedItemColor: AppStyles.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          label: "소식",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: "차트",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          label: "커뮤니티",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: "캘린더",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: "설정",
        ),
      ],
    );
  }
}
