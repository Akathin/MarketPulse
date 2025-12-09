import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool isSubscribed; /// true = 구독중, false = 무료버전
  final String username;

  const SettingsPage({
    super.key,
    required this.isSubscribed,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _profileSection(),
              const SizedBox(height: 32),

              // -------------------- 설정 --------------------
              _sectionTitle("설정"),
              _settingCard(
                icon: Icons.notifications,
                title: "알림 설정",
                subtitle: "관심 태그 알림 관리",
                onTap: () {},
              ),
              _settingCard(
                icon: Icons.person,
                title: "회원 정보 수정",
                subtitle: "프로필 수정 관리",
                onTap: () {},
              ),
              _settingCard(
                icon: Icons.color_lens,
                title: "앱 화면 설정",
                subtitle: "화면 테마 관리",
                onTap: () {},
              ),
              _settingCard(
                icon: Icons.headset_mic,
                title: "문의하기",
                subtitle: "MarketPulse팀에 의견 남기기",
                onTap: () {},
              ),

              const SizedBox(height: 28),

              // -------------------- 활동 --------------------
              _sectionTitle("활동"),
              _settingCard(
                icon: Icons.edit,
                title: "내가 쓴 글",
                subtitle: "작성한 게시글 관리",
                onTap: () {},
              ),
              _settingCard(
                icon: Icons.bookmark,
                title: "저장한 글",
                subtitle: "북마크한 게시글 관리",
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // -------------------- 회원탈퇴/약관 --------------------
              Text("회원탈퇴",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 20),
              Text("이용약관",
                  style: TextStyle(color: Colors.purple, fontSize: 14)),
              const SizedBox(height: 20),

              // -------------------- 버전 --------------------
              Text("Runtime Version: 1.0.0",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // 프로필 섹션
  // ----------------------------------------------------------
  Widget _profileSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.purple[400],
          child: const Text(
            "Market\nPulse",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSubscribed ? Colors.green[100] : Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isSubscribed ? "구독중" : "무료버전",
            style: TextStyle(
              color: isSubscribed ? Colors.green[800] : Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 10),
        Text(
          username,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // 섹션 타이틀
  // ----------------------------------------------------------
  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // 설정 카드 UI
  // ----------------------------------------------------------
  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      // 카드 자체는 클릭 불가 (중요!)
      child: Row(
        children: [
          // 아이콘 + 텍스트 + 화살표 전체를 버튼처럼 묶음
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, // 내용 부분만 클릭됨
              onTap: onTap,
              child: Row(
                children: [
                  Icon(icon, size: 30, color: Colors.purple),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios,
                      size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
