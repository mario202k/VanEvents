class Person {
  String id;
  String object;
  String account;
  int created;
  Dob dob;
  dynamic firstName;
  dynamic lastName;
  Relationship relationship;
  Requirements requirements;
  Verification verification;

  Person(
      {this.id,
      this.object,
      this.account,
      this.created,
      this.dob,
      this.firstName,
      this.lastName,
      this.relationship,
      this.requirements,
      this.verification});

  Map toJson() => {
        "id": id,
        "object": object,
        "account": account,
        "created": created,
        "dob": dob,
        "first_name": firstName,
        "last_name": lastName,
        "relationship": relationship,
        "requirements": requirements,
        "verification": verification,
      };

  factory Person.fromMap(dynamic map) {
    if (null == map) return null;
    var temp;
    return Person(
      id: map['id']?.toString(),
      object: map['object']?.toString(),
      account: map['account']?.toString(),
      created: null == (temp = map['created'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp as String)),
      dob: Dob.fromMap(map['dob'] as Map),
      firstName: map['firstName'],
      lastName: map['lastName'],
      relationship: Relationship.fromMap(map['relationship'] as Map),
      requirements: Requirements.fromMap(map['requirements'] as Map),
      verification: Verification.fromMap(map['verification'] as Map),
    );
  }
}

class Verification {
  AdditionalDocument additionalDocument;
  dynamic details;
  dynamic detailsCode;
  Document document;
  String status;

  Verification(
      {this.additionalDocument,
      this.details,
      this.detailsCode,
      this.document,
      this.status});

  factory Verification.fromMap(Map map) {
    return Verification(
      additionalDocument: AdditionalDocument.fromMap(
          map['additional_document'] as Map<dynamic, dynamic>),
      details: map['details'] as dynamic,
      detailsCode: map['detailsCode'] as dynamic,
      document: Document.fromMap(map['document'] as Map),
      status: map['status'] as String,
    );
  }

  Map toJson() => {
        "additional_document": additionalDocument,
        "details": details,
        "details_code": detailsCode,
        "document": document,
        "status": status,
      };
}

class Document {
  dynamic back;
  dynamic details;
  dynamic detailsCode;
  dynamic front;

  static Document fromMap(Map map) {
    if (map == null) return null;
    final Document document = Document();
    document.back = map['back'];
    document.details = map['details'];
    document.detailsCode = map['details_code'];
    document.front = map['front'];
    return document;
  }

  Map toJson() => {
        "back": back,
        "details": details,
        "details_code": detailsCode,
        "front": front,
      };
}

class AdditionalDocument {
  dynamic back;
  dynamic details;
  dynamic detailsCode;
  dynamic front;

  static AdditionalDocument fromMap(Map map) {
    if (map == null) return null;
    final AdditionalDocument additionalDocument = AdditionalDocument();
    additionalDocument.back = map['back'];
    additionalDocument.details = map['details'];
    additionalDocument.detailsCode = map['details_code'];
    additionalDocument.front = map['front'];
    return additionalDocument;
  }

  Map toJson() => {
        "back": back,
        "details": details,
        "details_code": detailsCode,
        "front": front,
      };
}

class Requirements {
  List<dynamic> currentlyDue;
  List<dynamic> errors;
  List<dynamic> eventuallyDue;
  List<dynamic> pastDue;
  List<dynamic> pendingVerification;

  static Requirements fromMap(Map map) {
    if (map == null) return null;
    final Requirements requirements = Requirements();
    requirements.currentlyDue = map['currently_due'] as List;
    requirements.errors = map['errors'] as List;
    requirements.eventuallyDue = map['eventually_due'] as List;
    requirements.pastDue = map['past_due'] as List;
    requirements.pendingVerification = map['pending_verification'] as List;
    return requirements;
  }

  Map toJson() => {
        "currently_due": currentlyDue,
        "errors": errors,
        "eventually_due": eventuallyDue,
        "past_due": pastDue,
        "pending_verification": pendingVerification,
      };
}

class Relationship {
  bool director;
  bool executive;
  bool owner;
  dynamic percentOwnership;
  bool representative;
  dynamic title;

  Relationship(
      {this.director,
      this.executive,
      this.owner,
      this.percentOwnership,
      this.representative,
      this.title});

  factory Relationship.fromMap(Map map) {
    return Relationship(
      director: map['director'] as bool,
      executive: map['executive'] as bool,
      owner: map['owner'] as bool,
      percentOwnership: map['percentOwnership'] as dynamic,
      representative: map['representative'] as bool,
      title: map['title'] as dynamic,
    );
  }

  Map toJson() => {
        "director": director,
        "executive": executive,
        "owner": owner,
        "percent_ownership": percentOwnership,
        "representative": representative,
        "title": title,
      };
}

class Dob {
  dynamic day;
  dynamic month;
  dynamic year;

  static Dob fromMap(Map map) {
    if (map == null) return null;
    final Dob dob = Dob();
    dob.day = map['day'];
    dob.month = map['month'];
    dob.year = map['year'];
    return dob;
  }

  Map toJson() => {
        "day": day,
        "month": month,
        "year": year,
      };
}
