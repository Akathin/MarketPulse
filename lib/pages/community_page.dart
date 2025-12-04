import 'package:flutter/material.dart';
import 'post_detail_page.dart';
import 'write_post_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  /// 게시글 데이터 저장 리스트 (유저가 직접 작성한 글)
  List<Map<String, dynamic>> posts = [];

  int _selectedCategory = 0;

  /// ───────────────────────────────────────────
  ///   기본 카테고리 더미 데이터
  /// ───────────────────────────────────────────
  final List<Map<String, dynamic>> userNews = List.generate(
    10,
    (i) => {
      "title": "유저 뉴스 ${i + 1}",
      "content": "유저가 직접 올린 뉴스 내용",
      "views": 100 + i,
      "comments": 3 + i,
      "time": "${i + 1}시간 전"
    },
  );

  final List<Map<String, dynamic>> freeBoard = List.generate(
    10,
    (i) => {
      "title": "자유 게시판 글 ${i + 1}",
      "content": "자유게시판 게시글 내용 -----",
      "views": 70 + i,
      "comments": 1 + i,
      "time": "${i + 2}시간 전"
    },
  );

  final List<Map<String, dynamic>> hotPosts = List.generate(
    10,
    (i) => {
      "title": "🔥 인기 게시물 ${i + 1}",
      "content": "게시글 인기순 ------",
      "views": 300 + i,
      "comments": 10 + i,
      "time": "${i + 3}시간 전"
    },
  );

  /// ───────────────────────────────────────────
  ///   선택된 카테고리에 따라 다른 리스트 반환
  /// ───────────────────────────────────────────
  List<Map<String, dynamic>> get selectedPosts {
    switch (_selectedCategory) {
      case 0:
        return [...posts, ...userNews]; // 유저 작성 글 + 기본 유저 뉴스
      case 1:
        return [...posts, ...freeBoard];
      case 2:
        return hotPosts;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F8),

      body: Column(
        children: [
          const SizedBox(height: 12),

          /// ────────── 카테고리 선택 UI ──────────
          _buildCategorySelector(),

          const SizedBox(height: 12),

          /// ────────── 게시글 리스트 ──────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: selectedPosts.length,
              itemBuilder: (context, index) {
                final post = selectedPosts[index];
                return _postCard(
                  title: post["title"],
                  content: post["content"],
                  views: post["views"],
                  comments: post["comments"],
                  time: post["time"],
                );
              },
            ),
          ),
        ],
      ),

      /// ────────── 글쓰기 버튼 ──────────
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPost = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WritePostPage()),
          );

          if (newPost != null) {
            setState(() {
              posts.add(newPost);
            });
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  /// ───────────────────────────────────────────
  ///   카테고리 선택 UI
  /// ───────────────────────────────────────────
  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCategoryItem(index: 0, label: "유저's 뉴스"),
          _buildCategoryItem(index: 1, label: "자유 게시판"),
          _buildCategoryItem(index: 2, label: "인기 게시물"),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({required int index, required String label}) {
    final bool isSelected = _selectedCategory == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedCategory = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// ───────────────────────────────────────────
  ///   게시글 카드
  /// ───────────────────────────────────────────
  Widget _postCard({
    required String title,
    required String content,
    required int views,
    required int comments,
    required String time,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailPage(
              title: title,
              content: content,
              views: views ?? 0,
              comments: comments ?? 0,
              time: time,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
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
            /// 제목
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            /// 내용 요약
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),

            const SizedBox(height: 10),

            /// 조회수 + 댓글 + 시간
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text("$views"),

                const SizedBox(width: 12),

                Icon(Icons.mode_comment_outlined,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text("$comments"),

                const SizedBox(width: 12),

                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
