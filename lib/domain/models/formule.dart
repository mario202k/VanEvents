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
        id: data['id'],
        title: data['title'] ?? '',
        prix: data['prix'] ?? '',
        nombreDePersonne: data['nb'] ?? 0);
  }

  @override
  String toString() {
    return 'Formule{id: $id, title: $title, prix: $prix, nombreDePersonne: $nombreDePersonne}';
  }
}