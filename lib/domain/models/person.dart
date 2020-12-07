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

  static Person fromMap(Map map) {
    if (map == null) return null;
    Person person = Person();
    person.id = map['id'];
    person.object = map['object'];
    person.account = map['account'];
    person.created = map['created'];
    person.dob = Dob.fromMap(map['dob']);
    person.firstName = map['first_name'];
    person.lastName = map['last_name'];
    person.relationship = Relationship.fromMap(map['relationship']);
    person.requirements = Requirements.fromMap(map['requirements']);
    person.verification = Verification.fromMap(map['verification']);
    return person;
  }

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
}

class Verification {
  Additional_document additionalDocument;
  dynamic details;
  dynamic detailsCode;
  Document document;
  String status;

  static Verification fromMap(Map map) {
    if (map == null) return null;
    Verification verification = Verification();
    verification.additionalDocument = Additional_document.fromMap(map['additional_document']);
    verification.details = map['details'];
    verification.detailsCode = map['details_code'];
    verification.document = Document.fromMap(map['document']);
    verification.status = map['status'];
    return verification;
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
    Document document = Document();
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

class Additional_document {
  dynamic back;
  dynamic details;
  dynamic detailsCode;
  dynamic front;

  static Additional_document fromMap(Map map) {
    if (map == null) return null;
    Additional_document additional_document = Additional_document();
    additional_document.back = map['back'];
    additional_document.details = map['details'];
    additional_document.detailsCode = map['details_code'];
    additional_document.front = map['front'];
    return additional_document;
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
    Requirements requirements = Requirements();
    requirements.currentlyDue = map['currently_due'];
    requirements.errors = map['errors'];
    requirements.eventuallyDue = map['eventually_due'];
    requirements.pastDue = map['past_due'];
    requirements.pendingVerification = map['pending_verification'];
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

  static Relationship fromMap(Map map) {
    if (map == null) return null;
    Relationship relationship = Relationship();
    relationship.director = map['director'];
    relationship.executive = map['executive'];
    relationship.owner = map['owner'];
    relationship.percentOwnership = map['percent_ownership'];
    relationship.representative = map['representative'];
    relationship.title = map['title'];
    return relationship;
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
    Dob dob = Dob();
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