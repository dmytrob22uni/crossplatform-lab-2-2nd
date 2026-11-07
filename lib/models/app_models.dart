abstract class FeedItem {
  final int id;
  final int sortOrder;
  FeedItem({required this.id, this.sortOrder = 0});
}

class UserItem extends FeedItem {
  final String name;
  final String username;
  final String email;

  UserItem({
    required super.id,
    required this.name,
    required this.username,
    required this.email,
    super.sortOrder,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'sort_order': sortOrder,
    };
  }

  factory UserItem.fromMap(Map<String, dynamic> map) {
    return UserItem(
      id: map['id'] as int,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}

class PostItem extends FeedItem {
  final String title;
  final String body;

  PostItem({
    required super.id,
    required this.title,
    required this.body,
    super.sortOrder,
  });

  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'sort_order': sortOrder,
    };
  }

  factory PostItem.fromMap(Map<String, dynamic> map) {
    return PostItem(
      id: map['id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}
