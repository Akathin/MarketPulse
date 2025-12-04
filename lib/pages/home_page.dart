import 'package:flutter/material.dart';
import '../main.dart';
import 'login_page.dart';
import 'notification_page.dart';
import 'my_page.dart';
import 'community_page.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _NewsListPage(),
    const CommunityPage(),
    const CalendarPage(),
    const Center(child: Text("설정", style: TextStyle(fontSize: 20))),
  ];

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
              // 알림
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.notifications_none, color: Colors.grey[800]),
                    const SizedBox(width: 4),
                    const Text("알림",
                        style: TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 내정보
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPage()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.grey[800]),
                    const SizedBox(width: 4),
                    const Text("내정보",
                        style: TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 로그아웃
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

      /// 선택된 페이지 표시
    body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      /// 하단 네비게이션 동작 구현
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppStyles.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: "소식",
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
      ),
    );
  }

  /// 로고
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
}

/// 뉴스 목록 페이지 (기존 UI 그대로 유지)
class _NewsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 10,
      itemBuilder: (context, index) {
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
              Text("뉴스 제목 ${index + 1}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "여기에 뉴스 요약이 들어갑니다.",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        );
      },
    );
  }
}
