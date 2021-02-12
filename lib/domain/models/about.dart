

class About {
  final String id;
  final String title;
  final Map<String,String> content;

  About({this.id, this.title, this.content});

  factory About.fromMap(Map<String, dynamic> map) {
    return About(
      id: map['id'] as String,
      title: map['title'] as String ?? '',
      content: Map.castFrom(map['content']as Map??{}) ?? {},
    );
  }



  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': id,
      'title': title,
      'content': content,
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'About{id: $id, title: $title, content: $content}';
  }
}
