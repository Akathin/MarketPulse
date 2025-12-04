import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final int views;
  final int comments;
  final String time;
  final String userName;
  final String userImage;

  const PostDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.views,
    required this.comments,
    required this.time,
    this.userName = "익명 유저",
    this.userImage = "",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "게시글 상세",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.more_horiz, color: Colors.black54),
          SizedBox(width: 12),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// -------------------- 작성자 정보 --------------------
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: userImage.isNotEmpty
                            ? NetworkImage(userImage)
                            : null,
                        child: userImage.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// -------------------- 제목 --------------------
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// -------------------- 내용 --------------------
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// -------------------- 안내 문구 --------------------
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "본 게시물은 사용자 개인의 의견으로, 서비스의 공식 입장이나 투자 조언이 아닙니다.\n"
                      "게시물의 내용으로 인한 투자 손실에 대해 책임지지 않습니다.",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// -------------------- 좋아요, 댓글, 조회수 --------------------
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 22, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text("0"),

                      const SizedBox(width: 20),

                      Icon(Icons.mode_comment_outlined, size: 22, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text("$comments"),

                      const Spacer(),

                      Text("조회 $views",
                          style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      const SizedBox(width: 12),
                      Icon(Icons.bookmark_border, size: 22, color: Colors.grey[700]),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// -------------------- 댓글 헤더 --------------------
                  Row(
                    children: [
                      Text("0 댓글", style: TextStyle(color: Colors.deepPurple, fontSize: 14)),
                      const Spacer(),
                      Text("오래된순", style: TextStyle(color: Colors.black54)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 아직 댓글 없음
                  Text(
                    "아직 댓글이 없습니다.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          /// -------------------- 댓글 입력창 --------------------
          _commentInput(),
        ],
      ),
    );
  }

  /// 댓글 입력창 UI
  Widget _commentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.deepPurple,
            child: const Text(
              "U",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "댓글을 입력해 보세요...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: const Color(0xFFF7F7F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
