import 'package:flutter/material.dart';
import 'package:market_pulse/pages/follow_page.dart'; // ★ FollowPage 연결 추가

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _TopBar(),
            const _Banner(),
            const SizedBox(height: 12),
            const _ProfileCard(),
            const SizedBox(height: 16),

            // ★ 팔로워/팔로잉 보기 버튼
            _followButton(context),

            const SizedBox(height: 20),
            const _StatsSection(),
            const SizedBox(height: 20),
            const _PostListSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // 팔로워 / 팔로잉 보기 버튼
  // -----------------------------------------------------
  Widget _followButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FollowPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFB46CFF),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text(
          "팔로워 / 팔로잉 보기",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// 상단 TopBar
// ----------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          const Spacer(),
          const Text(
            "Market Pulse",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          const Icon(Icons.edit, size: 22, color: Colors.black54),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// 보라색 배너
// ----------------------------------------------------------
class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, top: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB46CFF), Color(0xFF8E4DFF)],
        ),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "프로필",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// 프로필 카드
// ----------------------------------------------------------
class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFCC8DFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "U",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "username",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "user@example.com",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            "임시 프로필 소개입니다.",
            style: TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 22),
          const Text("관심 분야", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            children: const [
              _Tag("관심사1"),
              _Tag("관심사2"),
              _Tag("관심사3"),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2D9FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF9440FF)),
      ),
    );
  }
}

// ----------------------------------------------------------
// 통계 카드
// ----------------------------------------------------------
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Expanded(
            child: _StatsCard(
              icon: Icons.show_chart,
              value: "42",
              label: "작성한 글",
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _StatsCard(
              icon: Icons.calendar_today_outlined,
              value: "15",
              label: "일정",
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatsCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF9440FF), size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// 작성한 글 리스트 섹션
// ----------------------------------------------------------
class _PostListSection extends StatelessWidget {
  const _PostListSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "내가 작성한 글",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20),
          _PostItem(title: "임시 내 게시글 제목 1", comments: 15),
          Divider(height: 30),
          _PostItem(title: "임시 내 게시글 제목 2", comments: 28),
        ],
      ),
    );
  }
}

class _PostItem extends StatelessWidget {
  final String title;
  final int comments;

  const _PostItem({
    required this.title,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              "$comments",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}