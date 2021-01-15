import 'dart:convert';

class About {
  final String id;
  final String title;
  final Map content;

  About({this.id, this.title, this.content});

  factory About.fromMap(Map<String, dynamic> map) {
    return About(
      id: map['id'] as String,
      title: map['title'] as String ?? '',
      content: Map.castFrom(map['content']??{}) ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': this.id,
      'title': this.title,
      'content': this.content,
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'About{id: $id, title: $title, content: $content}';
  }
}
