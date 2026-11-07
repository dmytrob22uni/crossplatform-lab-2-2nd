import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_models.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<UserItem>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users?_limit=20'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<List<PostItem>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts?_limit=20'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PostItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }
}
