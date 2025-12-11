import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsService {
  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(Uri.parse("$baseUrl/news"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => NewsItem.fromJson(item)).toList();
    } else {
      throw Exception("뉴스 불러오기 실패: ${response.statusCode}");
    }
  }
}
