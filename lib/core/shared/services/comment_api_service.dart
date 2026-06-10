import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:past_question_paper_v1/core/shared/models/comment.dart';

class CommentService {
  // Use the same base URL as RestQuestionsApiService or as provided in instructions
  static const String defaultBaseUrl = 'https://pastpapersapp-be1962e3bb81.herokuapp.com/api';
  
  final String baseUrl;
  final http.Client _client;

  CommentService({
    this.baseUrl = defaultBaseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> _getHeaders() {
    final session = Supabase.instance.client.auth.currentSession;
    final headers = {
      'Content-Type': 'application/json',
    };
    if (session != null) {
      headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    return headers;
  }

  Future<List<Comment>> fetchComments(String questionId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/questions/$questionId/comments'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Comment.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load comments (HTTP ${response.statusCode})');
    }
  }

  Future<void> postComment(String questionId, Map<String, dynamic> commentData) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/questions/$questionId/comments'),
      headers: _getHeaders(),
      body: jsonEncode(commentData),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to post comment (HTTP ${response.statusCode})');
    }
  }

  Future<void> upvoteComment(String commentId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/comments/$commentId/upvote'),
      headers: _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to upvote comment (HTTP ${response.statusCode})');
    }
  }
}
