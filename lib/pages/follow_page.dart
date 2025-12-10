import 'package:flutter/material.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  int selectedTab = 0; // 0 = 팔로워, 1 = 팔로잉

  // 더미 데이터
  final List<Map<String, dynamic>> followers = [
    {"name": "사용자1", "email": "user1@example.com", "following": true},
    {"name": "사용자2", "email": "user2@example.com", "following": false},
    {"name": "사용자3", "email": "user3@example.com", "following": true},
    {"name": "사용자4", "email": "user4@example.com", "following": false},
    {"name": "사용자5", "email": "user5@example.com", "following": true},
  ];

  final List<Map<String, dynamic>> followings = [
    {"name": "사용자6", "email": "user6@example.com", "following": false},
    {"name": "사용자7", "email": "user7@example.com", "following": false},
    {"name": "사용자8", "email": "user8@example.com", "following": false},
    {"name": "사용자9", "email": "user9@example.com", "following": false},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> userList =
        selectedTab == 0 ? followers : followings;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          "팔로우",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // ----------------------- 탭 전환 -----------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabButton("팔로워", 0),
                const SizedBox(width: 10),
                _tabButton("팔로잉", 1),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ----------------------- 리스트 -----------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                return _userTile(
                  name: user["name"],
                  email: user["email"],
                  following: user["following"],
                  onToggle: () {
                    setState(() => user["following"] = !user["following"]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- 탭 버튼 --------------------
  Widget _tabButton(String text, int index) {
    bool isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFB46CFF) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- 사용자 카드 --------------------
  Widget _userTile({
    required String name,
    required String email,
    required bool following,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // 프로필 이미지(이니셜)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFB46CFF), Color(0xFF8E4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              "사",
              style: TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(width: 14),

          // 이름/이메일
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),

          // 팔로우 / 팔로잉 버튼
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color:
                    following ? Colors.grey.shade200 : const Color(0xFFB46CFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                following ? "팔로잉" : "팔로우",
                style: TextStyle(
                  color: following ? Colors.black54 : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}