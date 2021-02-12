class Formule {
  final String id;
  String title;
  double prix;
  int nombreDePersonne;

  Formule({this.id, this.title, this.prix, this.nombreDePersonne});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'prix': prix,
      'nombreDePersonne': nombreDePersonne,
    };
  }

  factory Formule.fromMap(Map data) {
    return Formule(
        id: data['id'] as String,
        title: data['title'] as String,
        prix: data['prix'] as double,
        nombreDePersonne: data['nb'] as int ?? 0);
  }

  @override
  String toString() {
    return 'Formule{id: $id, title: $title, prix: $prix, nombreDePersonne: $nombreDePersonne}';
  }
}
