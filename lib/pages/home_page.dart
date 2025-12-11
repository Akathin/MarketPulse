import 'package:flutter/material.dart';
import '../main.dart';
import 'login_page.dart';
import 'notification_page.dart';
import 'community_page.dart';
import 'calendar_page.dart';
import 'settings_page.dart';
import '../models/news.dart';
import '../services/news_service.dart';

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
    const SettingsPage(isSubscribed: false, username: 'username'),
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
            icon: Icon(Icons.notifications_none, color: Colors.grey[800]),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              "로그아웃",
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppStyles.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: "소식"),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: "커뮤니티"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "캘린더"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "설정"),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Text(
      "Market Pulse",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey.shade700,
      ),
    );
  }
}

class _NewsListPage extends StatefulWidget {
  @override
  State<_NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<_NewsListPage> {
  final NewsService newsService = NewsService();

  // 각 뉴스의 펼침 여부 상태 저장
  final Map<int, bool> expandedMap = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsItem>>(
      future: newsService.fetchNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("뉴스 로드 실패: ${snapshot.error}"));
        }

        final newsList = snapshot.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];

            final bool isExpanded = expandedMap[index] ?? false;

            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(1, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    news.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  // 요약 (펼치기/접기)
                  Text(
                    news.summaryKo ?? "",
                    maxLines: isExpanded ? null : 3,
                    overflow:
                        isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 6),

                  // 더보기 / 접기 버튼
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedMap[index] = !isExpanded;
                      });
                    },
                    child: Text(
                      isExpanded ? "접기 ▲" : "더보기 ▼",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 감정 분석 표시
                  Row(
                    children: [
                      Icon(
                        news.sentiment == "positive"
                            ? Icons.sentiment_satisfied_alt
                            : news.sentiment == "negative"
                                ? Icons.sentiment_dissatisfied
                                : Icons.sentiment_neutral,
                        color: news.sentiment == "positive"
                            ? Colors.green
                            : news.sentiment == "negative"
                                ? Colors.red
                                : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        news.sentiment.toUpperCase(),
                        style: TextStyle(
                          color: news.sentiment == "positive"
                              ? Colors.green
                              : news.sentiment == "negative"
                                  ? Colors.red
                                  : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text("출처: ${news.company}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
