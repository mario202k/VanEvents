class ConnectedAccount {
  String id;
  String object;
  Business_profile businessProfile;
  String businessType;
  Capabilities capabilities;
  bool chargesEnabled;
  Company company;
  String country;
  int created;
  String defaultCurrency;
  bool detailsSubmitted;
  String email;
  ExternalAccounts externalAccounts;
  Metadata metadata;
  bool payoutsEnabled;
  Requirements requirements;
  Settings settings;
  Tos_acceptance tosAcceptance;
  String type;

  static ConnectedAccount fromMap(Map map) {
    if (map == null) return null;
    ConnectedAccount connectedAccount = ConnectedAccount();
    connectedAccount.id = map['id'];
    connectedAccount.object = map['object'];
    connectedAccount.businessProfile = Business_profile.fromMap(map['business_profile']);
    connectedAccount.businessType = map['business_type'];
    connectedAccount.capabilities = Capabilities.fromMap(map['capabilities']);
    connectedAccount.chargesEnabled = map['charges_enabled'];
    connectedAccount.company = Company.fromMap(map['company']);
    connectedAccount.country = map['country'];
    connectedAccount.created = map['created'];
    connectedAccount.defaultCurrency = map['default_currency'];
    connectedAccount.detailsSubmitted = map['details_submitted'];
    connectedAccount.email = map['email'];
    connectedAccount.externalAccounts = ExternalAccounts.fromMap(map['external_accounts']);
    connectedAccount.metadata = Metadata.fromMap(map['metadata']);
    connectedAccount.payoutsEnabled = map['payouts_enabled'];
    connectedAccount.requirements = Requirements.fromMap(map['requirements']);
    connectedAccount.settings = Settings.fromMap(map['settings']);
    connectedAccount.tosAcceptance = Tos_acceptance.fromMap(map['tos_acceptance']);
    connectedAccount.type = map['type'];
    return connectedAccount;
  }

  Map toJson() => {
    "id": id,
    "object": object,
    "business_profile": businessProfile,
    "business_type": businessType,
    "capabilities": capabilities,
    "charges_enabled": chargesEnabled,
    "company": company,
    "country": country,
    "created": created,
    "default_currency": defaultCurrency,
    "details_submitted": detailsSubmitted,
    "email": email,
    "external_accounts": externalAccounts,
    "metadata": metadata,
    "payouts_enabled": payoutsEnabled,
    "requirements": requirements,
    "settings": settings,
    "tos_acceptance": tosAcceptance,
    "type": type,
  };
}

class Tos_acceptance {
  dynamic date;
  dynamic ip;
  dynamic userAgent;

  static Tos_acceptance fromMap(Map map) {
    if (map == null) return null;
    Tos_acceptance tos_acceptance = Tos_acceptance();
    tos_acceptance.date = map['date'];
    tos_acceptance.ip = map['ip'];
    tos_acceptance.userAgent = map['user_agent'];
    return tos_acceptance;
  }

  Map toJson() => {
    "date": date,
    "ip": ip,
    "user_agent": userAgent,
  };
}

class Settings {
  Bacs_debit_payments bacsDebitPayments;
  Branding branding;
  Card_payments cardPayments;
  Dashboard dashboard;
  Payments payments;
  Payouts payouts;

  static Settings fromMap(Map map) {
    if (map == null) return null;
    Settings settings = Settings();
    settings.bacsDebitPayments = Bacs_debit_payments.fromMap(map['bacs_debit_payments']);
    settings.branding = Branding.fromMap(map['branding']);
    settings.cardPayments = Card_payments.fromMap(map['card_payments']);
    settings.dashboard = Dashboard.fromMap(map['dashboard']);
    settings.payments = Payments.fromMap(map['payments']);
    settings.payouts = Payouts.fromMap(map['payouts']);
    return settings;
  }

  Map toJson() => {
    "bacs_debit_payments": bacsDebitPayments,
    "branding": branding,
    "card_payments": cardPayments,
    "dashboard": dashboard,
    "payments": payments,
    "payouts": payouts,
  };
}

class Payouts {
  bool debitNegativeBalances;
  Schedule schedule;
  dynamic statementDescriptor;

  static Payouts fromMap(Map map) {
    if (map == null) return null;
    Payouts payouts = Payouts();
    payouts.debitNegativeBalances = map['debit_negative_balances'];
    payouts.schedule = Schedule.fromMap(map['schedule']);
    payouts.statementDescriptor = map['statement_descriptor'];
    return payouts;
  }

  Map toJson() => {
    "debit_negative_balances": debitNegativeBalances,
    "schedule": schedule,
    "statement_descriptor": statementDescriptor,
  };
}

class Schedule {
  int delayDays;
  String interval;

  static Schedule fromMap(Map map) {
    if (map == null) return null;
    Schedule schedule = Schedule();
    schedule.delayDays = map['delay_days'];
    schedule.interval = map['interval'];
    return schedule;
  }

  Map toJson() => {
    "delay_days": delayDays,
    "interval": interval,
  };
}

class Payments {
  String statementDescriptor;
  dynamic statementDescriptorKana;
  dynamic statementDescriptorKanji;

  static Payments fromMap(Map map) {
    if (map == null) return null;
    Payments payments = Payments();
    payments.statementDescriptor = map['statement_descriptor'];
    payments.statementDescriptorKana = map['statement_descriptor_kana'];
    payments.statementDescriptorKanji = map['statement_descriptor_kanji'];
    return payments;
  }

  Map toJson() => {
    "statement_descriptor": statementDescriptor,
    "statement_descriptor_kana": statementDescriptorKana,
    "statement_descriptor_kanji": statementDescriptorKanji,
  };
}

class Dashboard {
  String displayName;
  String timezone;

  static Dashboard fromMap(Map map) {
    if (map == null) return null;
    Dashboard dashboard = Dashboard();
    dashboard.displayName = map['display_name'];
    dashboard.timezone = map['timezone'];
    return dashboard;
  }

  Map toJson() => {
    "display_name": displayName,
    "timezone": timezone,
  };
}

class Card_payments {
  Decline_on declineOn;
  String statementDescriptorPrefix;

  static Card_payments fromMap(Map map) {
    if (map == null) return null;
    Card_payments card_payments = Card_payments();
    card_payments.declineOn = Decline_on.fromMap(map['decline_on']);
    card_payments.statementDescriptorPrefix = map['statement_descriptor_prefix'];
    return card_payments;
  }

  Map toJson() => {
    "decline_on": declineOn,
    "statement_descriptor_prefix": statementDescriptorPrefix,
  };
}

class Decline_on {
  bool avsFailure;
  bool cvcFailure;

  static Decline_on fromMap(Map map) {
    if (map == null) return null;
    Decline_on decline_on = Decline_on();
    decline_on.avsFailure = map['avs_failure'];
    decline_on.cvcFailure = map['cvc_failure'];
    return decline_on;
  }

  Map toJson() => {
    "avs_failure": avsFailure,
    "cvc_failure": cvcFailure,
  };
}

class Branding {
  String icon;
  String logo;
  String primaryColor;
  dynamic secondaryColor;

  static Branding fromMap(Map map) {
    if (map == null) return null;
    Branding branding = Branding();
    branding.icon = map['icon'];
    branding.logo = map['logo'];
    branding.primaryColor = map['primary_color'];
    branding.secondaryColor = map['secondary_color'];
    return branding;
  }

  Map toJson() => {
    "icon": icon,
    "logo": logo,
    "primary_color": primaryColor,
    "secondary_color": secondaryColor,
  };
}

class Bacs_debit_payments {

  static Bacs_debit_payments fromMap(Map map) {
    if (map == null) return null;
    Bacs_debit_payments bacs_debit_payments = Bacs_debit_payments();
    return bacs_debit_payments;
  }

  Map toJson() => {
  };
}

class Requirements {
  dynamic currentDeadline;
  List<String> currentlyDue;
  String disabledReason;
  List<dynamic> errors;
  List<String> eventuallyDue;
  List<dynamic> pastDue;
  List<dynamic> pendingVerification;

  static Requirements fromMap(Map map) {
    if (map == null) return null;
    Requirements requirements = Requirements();
    requirements.currentDeadline = map['current_deadline'];
    requirements.currentlyDue = List()..addAll(
      (map['currently_due'] as List ?? []).map((o) => o.toString())
    );
    requirements.disabledReason = map['disabled_reason'];
    requirements.errors = map['errors'];
    requirements.eventuallyDue = List()..addAll(
      (map['eventually_due'] as List ?? []).map((o) => o.toString())
    );
    requirements.pastDue = map['past_due'];
    requirements.pendingVerification = map['pending_verification'];
    return requirements;
  }

  Map toJson() => {
    "current_deadline": currentDeadline,
    "currently_due": currentlyDue,
    "disabled_reason": disabledReason,
    "errors": errors,
    "eventually_due": eventuallyDue,
    "past_due": pastDue,
    "pending_verification": pendingVerification,
  };
}

class Metadata {

  static Metadata fromMap(Map map) {
    if (map == null) return null;
    Metadata metadata = Metadata();
    return metadata;
  }

  Map toJson() => {
  };
}

class ExternalAccounts {
  String object;
  List<dynamic> data;
  bool hasMore;
  String url;

  static ExternalAccounts fromMap(Map map) {
    if (map == null) return null;

    ExternalAccounts externalAccounts = ExternalAccounts();
    externalAccounts.object = map['object'];
    externalAccounts.data = map['data'];
    externalAccounts.hasMore = map['has_more'];
    externalAccounts.url = map['url'];
    return externalAccounts;
  }

  Map toJson() => {
    "object": object,
    "data": data,
    "has_more": hasMore,
    "url": url,
  };
}

class Company {
  Address address;
  bool directorsProvided;
  bool executivesProvided;
  dynamic name;
  bool ownersProvided;
  bool taxIdProvided;
  Verification verification;

  static Company fromMap(Map map) {
    if (map == null) return null;
    Company company = Company();
    company.address = Address.fromMap(map['address']);
    company.directorsProvided = map['directors_provided'];
    company.executivesProvided = map['executives_provided'];
    company.name = map['name'];
    company.ownersProvided = map['owners_provided'];
    company.taxIdProvided = map['tax_id_provided'];
    company.verification = Verification.fromMap(map['verification']);
    return company;
  }

  Map toJson() => {
    "address": address,
    "directors_provided": directorsProvided,
    "executives_provided": executivesProvided,
    "name": name,
    "owners_provided": ownersProvided,
    "tax_id_provided": taxIdProvided,
    "verification": verification,
  };
}

class Verification {
  Document document;

  static Verification fromMap(Map map) {
    if (map == null) return null;
    Verification verification = Verification();
    verification.document = Document.fromMap(map['document']);
    return verification;
  }

  Map toJson() => {
    "document": document,
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

class Address {
  dynamic city;
  String country;
  dynamic line1;
  dynamic line2;
  dynamic postalCode;
  dynamic state;

  static Address fromMap(Map map) {
    if (map == null) return null;
    Address address = Address();
    address.city = map['city'];
    address.country = map['country'];
    address.line1 = map['line1'];
    address.line2 = map['line2'];
    address.postalCode = map['postal_code'];
    address.state = map['state'];
    return address;
  }

  Map toJson() => {
    "city": city,
    "country": country,
    "line1": line1,
    "line2": line2,
    "postal_code": postalCode,
    "state": state,
  };
}

class Capabilities {
  String cardPayments;
  String transfers;

  static Capabilities fromMap(Map map) {
    if (map == null) return null;
    Capabilities capabilities = Capabilities();
    capabilities.cardPayments = map['card_payments'];
    capabilities.transfers = map['transfers'];
    return capabilities;
  }

  Map toJson() => {
    "card_payments": cardPayments,
    "transfers": transfers,
  };
}

class Business_profile {
  String mcc;
  String name;
  String productDescription;
  Support_address supportAddress;
  String supportEmail;
  String supportPhone;
  dynamic supportUrl;
  dynamic url;

  static Business_profile fromMap(Map map) {
    if (map == null) return null;
    Business_profile business_profile = Business_profile();
    business_profile.mcc = map['mcc'];
    business_profile.name = map['name'];
    business_profile.productDescription = map['product_description'];
    business_profile.supportAddress = Support_address.fromMap(map['support_address']);
    business_profile.supportEmail = map['support_email'];
    business_profile.supportPhone = map['support_phone'];
    business_profile.supportUrl = map['support_url'];
    business_profile.url = map['url'];
    return business_profile;
  }

  Map toJson() => {
    "mcc": mcc,
    "name": name,
    "product_description": productDescription,
    "support_address": supportAddress,
    "support_email": supportEmail,
    "support_phone": supportPhone,
    "support_url": supportUrl,
    "url": url,
  };
}

class Support_address {
  String city;
  String country;
  String line1;
  dynamic line2;
  String postalCode;
  dynamic state;

  static Support_address fromMap(Map map) {
    if (map == null) return null;
    Support_address support_address = Support_address();
    support_address.city = map['city'];
    support_address.country = map['country'];
    support_address.line1 = map['line1'];
    support_address.line2 = map['line2'];
    support_address.postalCode = map['postal_code'];
    support_address.state = map['state'];
    return support_address;
  }

  Map toJson() => {
    "city": city,
    "country": country,
    "line1": line1,
    "line2": line2,
    "postal_code": postalCode,
    "state": state,
  };
}