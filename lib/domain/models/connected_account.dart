class ConnectedAccount {
  String id;
  String object;
  BusinessProfile businessProfile;
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
  TosAcceptance tosAcceptance;
  String type;

  ConnectedAccount(
      {this.id,
      this.object,
      this.businessProfile,
      this.businessType,
      this.capabilities,
      this.chargesEnabled,
      this.company,
      this.country,
      this.created,
      this.defaultCurrency,
      this.detailsSubmitted,
      this.email,
      this.externalAccounts,
      this.metadata,
      this.payoutsEnabled,
      this.requirements,
      this.settings,
      this.tosAcceptance,
      this.type});

  factory ConnectedAccount.fromMap(Map map) {
    if (null == map) return null;
    return ConnectedAccount(
      id: map['id'] as String,
      object: map['object'] as String,
      businessProfile: BusinessProfile.fromMap(map['business_profile'] as Map),
      businessType: map['businessType'] as String,
      capabilities: Capabilities.fromMap(map['capabilities'] as Map),
      chargesEnabled: map['chargesEnabled'] as bool,
      company: Company.fromMap(map['company'] as Map),
      country: map['country'] as String,
      created: map['created'] as int,
      defaultCurrency: map['defaultCurrency'] as String,
      detailsSubmitted: map['detailsSubmitted'] as bool,
      email: map['email'] as String,
      externalAccounts: ExternalAccounts.fromMap(map['external_accounts'] as Map),
      metadata: Metadata.fromMap(map['metadata'] as Map),
      payoutsEnabled: map['payoutsEnabled'] as bool,
      requirements: Requirements.fromMap(map['requirements'] as Map),
      settings: Settings.fromMap(map['settings'] as Map),
      tosAcceptance:TosAcceptance.fromMap(map['tosAcceptance'] as Map),
      type: map['type'] as String,
    );
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

class TosAcceptance {
  dynamic date;
  dynamic ip;
  dynamic userAgent;

  TosAcceptance({this.date, this.ip, this.userAgent});

  factory TosAcceptance.fromMap(Map map) {
    if (null == map) return null;
    return TosAcceptance(
      date: map['date'],
      ip: map['ip'],
      userAgent: map['user_agent'],
    );
  }

  Map toJson() => {
        "date": date,
        "ip": ip,
        "user_agent": userAgent,
      };
}

class Settings {
  BacsDebitPayments bacsDebitPayments;
  Branding branding;
  CardPayments cardPayments;
  Dashboard dashboard;
  Payments payments;
  Payouts payouts;

  Settings(
      {this.bacsDebitPayments,
      this.branding,
      this.cardPayments,
      this.dashboard,
      this.payments,
      this.payouts});

  factory Settings.fromMap(Map map) {
    if (null == map) return null;
    return Settings(
      bacsDebitPayments: BacsDebitPayments.fromMap(
          map['bacs_debit_payments'] as Map),
      branding: Branding.fromMap(map['branding'] as Map),
      cardPayments:
          CardPayments.fromMap(map['card_payments'] as Map),
      dashboard: Dashboard.fromMap(map['dashboard'] as Map),
      payments: Payments.fromMap(map['payments'] as Map),
      payouts: Payouts.fromMap(map['payouts'] as Map),
    );
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
  String statementDescriptor;

  Payouts(
      {this.debitNegativeBalances, this.schedule, this.statementDescriptor});

  factory Payouts.fromMap(Map map) {
    return Payouts(
      debitNegativeBalances: map['debit_negative_balances'] as bool,
      schedule: Schedule.fromMap(map['schedule'] as Map),
      statementDescriptor: map['statement_descriptor'] as String,
    );
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

  Schedule({this.delayDays, this.interval});

  factory Schedule.fromMap(Map map) {
    return Schedule(
      delayDays: map['delay_days'] as int,
      interval: map['interval'] as String,
    );
  }

  Map toJson() => {
        "delay_days": delayDays,
        "interval": interval,
      };
}

class Payments {
  String statementDescriptor;
  String statementDescriptorKana;
  String statementDescriptorKanji;

  Payments(
      {this.statementDescriptor,
      this.statementDescriptorKana,
      this.statementDescriptorKanji});

  factory Payments.fromMap(Map map) {
    return Payments(
      statementDescriptor: map['statement_descriptor'] as String,
      statementDescriptorKana: map['statement_descriptor_kana'] as String,
      statementDescriptorKanji: map['statement_descriptor_kanji'] as String,
    );
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

  Dashboard({this.displayName, this.timezone});

  factory Dashboard.fromMap(Map map) {
    return Dashboard(
      displayName: map['display_name'] as String,
      timezone: map['timezone'] as String,
    );
  }

  Map toJson() => {
        "display_name": displayName,
        "timezone": timezone,
      };
}

class CardPayments {
  DeclineOn declineOn;
  String statementDescriptorPrefix;

  CardPayments({this.declineOn, this.statementDescriptorPrefix});


  Map toJson() => {
        "decline_on": declineOn,
        "statement_descriptor_prefix": statementDescriptorPrefix,
      };

  factory CardPayments.fromMap(Map map) {
    if (null == map) return null;
    return CardPayments(
      declineOn: DeclineOn.fromMap(map['decline_on'] as Map),
      statementDescriptorPrefix: map['statement_descriptor_prefix']?.toString(),
    );
  }
}

class DeclineOn {
  bool avsFailure;
  bool cvcFailure;

  DeclineOn({this.avsFailure, this.cvcFailure});

  factory DeclineOn.fromMap(Map map) {
    return DeclineOn(
      avsFailure: map['avs_failure'] as bool,
      cvcFailure: map['cvc_failure'] as bool,
    );
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
  String secondaryColor;

  Branding({this.icon, this.logo, this.primaryColor, this.secondaryColor});

  factory Branding.fromMap(Map map) {
    return Branding(
      icon: map['icon'] as String,
      logo: map['logo'] as String,
      primaryColor: map['primary_color'] as String,
      secondaryColor: map['secondary_color'] as String,
    );
  }

  Map toJson() => {
        "icon": icon,
        "logo": logo,
        "primary_color": primaryColor,
        "secondary_color": secondaryColor,
      };
}

class BacsDebitPayments {
  BacsDebitPayments();

  factory BacsDebitPayments.fromMap(Map map) {
    if (null == map) return null;
    return BacsDebitPayments();
  }

  Map toJson() => {};
}

class Requirements {
  dynamic currentDeadline;
  List currentlyDue;
  String disabledReason;
  List errors;
  List eventuallyDue;
  List pastDue;
  List pendingVerification;

  Requirements(
      {this.currentDeadline,
      this.currentlyDue,
      this.disabledReason,
      this.errors,
      this.eventuallyDue,
      this.pastDue,
      this.pendingVerification});

  factory Requirements.fromMap(Map map) {
    if (null == map) return null;
    return Requirements(
      currentDeadline: map['current_deadline'] as dynamic,
      currentlyDue: map['currently_due'] as List,
      disabledReason: map['disabled_reason'] as String,
      errors: map['errors'] as List,
      eventuallyDue: map['eventually_due'] as List,
      pastDue: map['past_due'] as List,
      pendingVerification: map['pending_verification'] as List,
    );
  }

  // factory Requirements.fromMap(Map map) {
  //   if (null == map) return null;
  //   var temp;
  //   return Requirements(
  //     currentDeadline: map['currentDeadline'],
  //     currentlyDue: null == (temp = map['currentlyDue'])
  //         ? []
  //         : (temp is List ? temp.map((map) => map?.toString()).toList() : []),
  //     disabledReason: map['disabledReason']?.toString(),
  //     errors: null == (temp = map['errors'])
  //         ? []
  //         : (temp is List ? temp.map((map) => map).toList() : []),
  //     eventuallyDue: null == (temp = map['eventuallyDue'])
  //         ? []
  //         : (temp is List ? temp.map((map) => map?.toString()).toList() : []),
  //     pastDue: null == (temp = map['pastDue'])
  //         ? []
  //         : (temp is List ? temp.map((map) => map).toList() : []),
  //     pendingVerification: null == (temp = map['pendingVerification'])
  //         ? []
  //         : (temp is List ? temp.map((map) => map).toList() : []),
  //   );
  // }

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
  Map toJson() => {};

  Metadata();

  factory Metadata.fromMap(Map map) {
    if (null == map) return null;
    return Metadata();
  }
}

class ExternalAccounts {
  String object;
  List data;
  bool hasMore;
  String url;

  ExternalAccounts({this.object, this.data, this.hasMore, this.url});


  Map toJson() => {
        "object": object,
        "data": data,
        "has_more": hasMore,
        "url": url,
      };

  factory ExternalAccounts.fromMap(Map map) {
    if (null == map) return null;
    return  ExternalAccounts(
      object: map['object'] as String,
      data: map['data'] as List,
      hasMore: map['has_more'] as bool,
      url: map['url'] as String,
    );
  }

// factory ExternalAccounts.fromMap(Map map) {
  //   if (null == map) return null;
  //   var temp;
  //   return ExternalAccounts(
  //     object: map['object']?.toString(),
  //     data: null == (temp = map['data'])
  //         ? []
  //         : (temp is List ? temp.map((map) => map).toList() : []),
  //     hasMore: null == (temp = map['hasMore'])
  //         ? null
  //         : (temp is bool
  //             ? temp
  //             : (temp is num
  //                 ? 0 != temp.toInt()
  //                 : ('true' == temp.toString()))),
  //     url: map['url']?.toString(),
  //   );
  // }
}

class Company {
  Address address;
  bool directorsProvided;
  bool executivesProvided;
  String name;
  bool ownersProvided;
  bool taxIdProvided;
  Verification verification;

  Company(
      {this.address,
      this.directorsProvided,
      this.executivesProvided,
      this.name,
      this.ownersProvided,
      this.taxIdProvided,
      this.verification});


  Map toJson() => {
        "address": address,
        "directors_provided": directorsProvided,
        "executives_provided": executivesProvided,
        "name": name,
        "owners_provided": ownersProvided,
        "tax_id_provided": taxIdProvided,
        "verification": verification,
      };

  factory Company.fromMap(Map map) {

    if (null == map) return null;
    return Company(
      address: Address.fromMap(map['address'] as Map),
      directorsProvided: map['directors_provided'] as bool,
      executivesProvided: map['executives_provided'] as bool,
      name: map['name'] as String,
      ownersProvided: map['owners_provided'] as bool,
      taxIdProvided: map['tax_id_provided'] as bool,
      verification: Verification.fromMap(map['verification'] as Map),
    );
  }

// factory Company.fromMap(Map map) {
  //   print(map);
  //   print(map['taxIdProvided']);
  //   if (null == map) return null;
  //   var temp;
  //   return Company(
  //     address: Address.fromMap(map['address'] as Map),
  //     directorsProvided: null == (temp = map['directorsProvided'])
  //         ? null
  //         : (temp is bool
  //             ? temp
  //             : (temp is num
  //                 ? 0 != temp.toInt()
  //                 : ('true' == temp.toString()))),
  //     executivesProvided: null == (temp = map['executivesProvided'])
  //         ? null
  //         : (temp is bool
  //             ? temp
  //             : (temp is num
  //                 ? 0 != temp.toInt()
  //                 : ('true' == temp.toString()))),
  //     name: map['name'] as String,
  //     ownersProvided: null == (temp = map['ownersProvided'])
  //         ? null
  //         : (temp is bool
  //             ? temp
  //             : (temp is num
  //                 ? 0 != temp.toInt()
  //                 : ('true' == temp.toString()))),
  //     taxIdProvided: null == (temp = map['taxIdProvided'])
  //         ? null
  //         : (temp is bool
  //             ? temp
  //             : (temp is num
  //                 ? 0 != temp.toInt()
  //                 : ('true' == temp.toString()))),
  //     verification: Verification.fromMap(map['verification'] as Map),
  //   );
  // }
}

class Verification {
  Document document;

  Verification({this.document});

  factory Verification.fromMap(Map map) {
    if (null == map) return null;
    return Verification(
        document: Document.fromMap(
      map['document'] as Map,
    ));
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

  Document({this.back, this.details, this.detailsCode, this.front});

  factory Document.fromMap(Map map) {
    if (null == map) return null;
    return Document(
      back: map['back'],
      details: map['details'],
      detailsCode: map['details_code'],
      front: map['front'],
    );
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
  String line1;
  String line2;
  dynamic postalCode;
  dynamic state;

  Address(
      {this.city,
      this.country,
      this.line1,
      this.line2,
      this.postalCode,
      this.state});

  factory Address.fromMap(Map map) {
    if (null == map) return null;
    return Address(
      city: map['city'] as dynamic,
      country: map['country'] as String,
      line1: map['line1'] as String,
      line2: map['line2'] as String,
      postalCode: map['postal_code'] as dynamic,
      state: map['state'] as dynamic,
    );
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

  Capabilities({this.cardPayments, this.transfers});

  factory Capabilities.fromMap(Map map) {
    if (null == map) return null;
    return Capabilities(
      cardPayments: map['card_payments'] as String,
      transfers: map['transfers'] as String,
    );
  }

  Map toJson() => {
        "card_payments": cardPayments,
        "transfers": transfers,
      };
}

class BusinessProfile {
  String mcc;
  String name;
  String productDescription;
  SupportAddress supportAddress;
  String supportEmail;
  String supportPhone;
  dynamic supportUrl;
  dynamic url;

  BusinessProfile(
      {this.mcc,
      this.name,
      this.productDescription,
      this.supportAddress,
      this.supportEmail,
      this.supportPhone,
      this.supportUrl,
      this.url});

  factory BusinessProfile.fromMap(Map map) {

    if (null == map) return null;
    return BusinessProfile(
      mcc: map['mcc'] as String,
      name: map['name'] as String,
      productDescription: map['product_description'] as String,
      supportAddress: SupportAddress.fromMap(map['support_address'] as Map),
      supportEmail: map['support_email'] as String,
      supportPhone: map['support_phone'] as String,
      supportUrl: map['support_url'] as String,
      url: map['url'] as String,
    );
  }

  // factory BusinessProfile.fromMap(Map map) {
  //   print(map);
  //   if (null == map) return null;
  //   return BusinessProfile(
  //     mcc: map['mcc']?.toString() ?? '',
  //     name: map['name']?.toString() ?? '',
  //     productDescription: map['productDescription']?.toString() ?? '',
  //     supportAddress:
  //         SupportAddress.fromMap(map['supportAddress'] as Map),
  //     supportEmail: map['supportEmail']?.toString() ?? '',
  //     supportPhone: map['supportPhone']?.toString() ?? '',
  //     supportUrl: map['supportUrl'],
  //     url: map['url'],
  //   );
  // }



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

class SupportAddress {
  String city;
  String country;
  String line1;
  dynamic line2;
  String postalCode;
  dynamic state;

  SupportAddress(
      {this.city,
      this.country,
      this.line1,
      this.line2,
      this.postalCode,
      this.state});

  factory SupportAddress.fromMap(Map map) {
    if (null == map) return null;
    return SupportAddress(
      city: map['city'] as String,
      country: map['country'] as String,
      line1: map['line1'] as String,
      line2: map['line2'] as dynamic,
      postalCode: map['postal_code'] as String,
      state: map['state'] as dynamic,
    );
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
