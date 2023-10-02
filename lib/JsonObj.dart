import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'configuration.dart';

List<Breed> breedFromJson(String str) => List<Breed>.from(json.decode(str).map((x) => Breed.fromJson(x)));

String breedToJson(List<Breed> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Breed {
  Breed({
    required this.id,
    required this.name,
    required this.weight,
    required this.height,
    required this.photoUrl,
  });

  int id;
  String name;
  int weight;
  int height;
  String photoUrl;

  factory Breed.fromJson(Map<String, dynamic> json) => Breed(
    id: json["id"],
    name: json["name"],
    weight: json["weight"],
    height: json["height"],
    photoUrl: json["photoUrl"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "weight": weight,
    "height": height,
    "photoUrl": photoUrl,
  };

  ///this method will prevent the override of toString
  bool filterBreedItem(String filter) {
    var nam = name.toUpperCase();
    return nam.contains(filter.toUpperCase());
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(Breed m) {
    return name == m.name;
  }
}


// end of breed list obj

// To parse this JSON data, do
//

//     final photoResponse = photoResponseFromJson(jsonString);

// Photo  analysis response object
PhotoResponse photoResponseFromJson(String str) => PhotoResponse.fromJson(json.decode(str));

String photoResponseToJson(PhotoResponse data) => json.encode(data.toJson());

class PhotoResponse {
  String id;
  String url;
  String subId;
  int width;
  int height;
  String originalFilename;
  int pending;
  int approved;

  PhotoResponse({
    required this.id,
    required this.url,
    required this.subId,
    required this.width,
    required this.height,
    required this.originalFilename,
    required this.pending,
    required this.approved,
  });

  factory PhotoResponse.fromJson(Map<String, dynamic> json) => PhotoResponse(
    id: json["id"],
    url: json["url"],
    subId: json["sub_id"],
    width: json["width"],
    height: json["height"],
    originalFilename: json["original_filename"],
    pending: json["pending"],
    approved: json["approved"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "sub_id": subId,
    "width": width,
    "height": height,
    "original_filename": originalFilename,
    "pending": pending,
    "approved": approved,
  };
}

UserAvailCheck userAvailCheckFromJson(String str) => UserAvailCheck.fromJson(json.decode(str));

String userAvailCheckToJson(UserAvailCheck data) => json.encode(data.toJson());

class UserAvailCheck {
  UserAvailCheck({
    required this.code,
    required this.message,
  });

  int code;
  String message;

  factory UserAvailCheck.fromJson(Map<String, dynamic> json) => UserAvailCheck(
    code: json["code"],
    message: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "error": message,
  };
}

UserPod userPodFromShot(Map<String, dynamic> shot) => UserPod.fromShot(shot);
UserPod userPodFromJson(String data) => UserPod.fromJson(json.decode(data));
UserPod userPodFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) => UserPod.fromShot(doc.data()!);
String userPodToJson(UserPod data) => json.encode(data.toJson());

class UserPod {
  UserPod({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.phone,
    required this.type,
    required this.isMale,
    required this.birthdate,
    required this.location,
    required this.city,
    required this.photoUrl,
    required this.createdAt,
    required this.country,
    required this.email,
    required this.lastModified
  });

  String id;
  String lastName;
  String firstName;
  String phone;
  int type;
  bool isMale;
  DateTime birthdate;
  Location location;
  String city;
  String photoUrl;
  DateTime createdAt;
  String country;
  String email;
  DateTime lastModified;

  factory UserPod.fromShot(Map<String, dynamic> json) => UserPod(
    id: json["_id"],
    lastName: json["lastName"],
    firstName: json["firstName"],
    phone: json["phone"],
    type: json["type"],
    isMale: json["isMale"],
    birthdate: DateTime.parse(json["birthdate"]),
    location: Location.fromJson(json["location"]),
    city: json["city"],
    photoUrl: json["photoUrl"],
    createdAt: DateTime.parse(json["createdAt"]),
    country: json["country"],
    email: json["email"],
    lastModified: DateTime.parse(json['lastModified'])
  );

  factory UserPod.fromJson(Map<String, dynamic> json) => UserPod(
      id: json['_id'],
      lastName: json["lastName"],
      firstName: json["firstName"],
      phone: json["phone"],
      type: json["type"],
      isMale: json["isMale"],
      birthdate: DateTime.fromMillisecondsSinceEpoch(json['birthdate']),
      location: Location.fromJson(json["location"]),
      city: json["city"],
      photoUrl: json["photoUrl"],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
      country: json["country"],
      email: json["email"],
      lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified'])
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "lastName": lastName,
    "firstName": firstName,
    "phone": phone,
    "type": type,
    "isMale": isMale,
    "birthdate": birthdate.millisecondsSinceEpoch,
    "location": location.toJson(),
    "city": city,
    "photoUrl": photoUrl,
    "ts": createdAt.millisecondsSinceEpoch,
    "country": country,
    "email": email,
    "lastModified": lastModified.millisecondsSinceEpoch

  };

  Map<String, dynamic> toShot() => {
    "lastName": lastName,
    "firstName": firstName,
    "phone": phone,
    "type": type,
    "isMale": isMale,
    "birthdate": birthdate,
    "location": location.toJson(),
    "city": city,
    "photoUrl": photoUrl,
    "ts": createdAt.millisecondsSinceEpoch,
    "country": country,
    "email": email,
    "lastModified": lastModified.millisecondsSinceEpoch
  };

  UserPod copyWith({
    String? id,
    String? lastName,
    String? firstName,
    String? phone,
    int? type,
    bool? isMale,
    DateTime? birthdate,
    Location? location,
    String? city,
    String? photoUrl,
    DateTime? createdAt,
    String? country,
    String? email,
    DateTime? lastModified
  }){
    return UserPod(id: id ?? this.id,
        lastName: lastName ?? this.lastName,
        firstName: firstName ?? this.firstName,
        phone: phone ?? this.phone,
        type: type ?? this.type,
        isMale: isMale ?? this.isMale,
        birthdate: birthdate ?? this.birthdate,
        location: location ?? this.location,
        city: city ?? this.city,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
        country: country ?? this.country,
        email: email ?? this.email,
        lastModified: lastModified ?? this.lastModified);
  }

}

class Location {
  Location({
    required this.longitude,
    required this.latitude,
  });

  double longitude;
  double latitude;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    longitude: json["long"] is int ? json['long'].toDouble() : json['long'],
    latitude: json["lat"]is int ? json['lat'].toDouble() : json['lat'],
  );

  Map<String, dynamic> toJson() => {
    "long": longitude,
    "lat": latitude,
  };
}


List<PetProfile> petProfileFromShot(List<dynamic> data) => List<PetProfile>.from(data.map((e) => PetProfile.fromShot(e)));
List<PetProfile> petProfileFromJson(List<dynamic> data) => List<PetProfile>.from(data.map((e) => PetProfile.fromJson(e)));
String petProfileToJson(List<PetProfile> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

PetProfile singlePetProfileFromShot(Map<String, dynamic> data) => PetProfile.fromShot(data);
PetProfile singlePetProfileFromJson(String data) => PetProfile.fromJson(json.decode(data));
PetProfile singlePetProfileFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) => PetProfile.fromShot(doc.data());
String singlePetProfileToJson(PetProfile data) => json.encode(data.toJson());

class PetProfile {
  PetProfile({
    required this.id,
    required this.name,
    required this.breed,
    required this.isMale,
    required this.birthdate,
    required this.photoUrl,
    required this.ownerId,
    this.type,
    required this.createdAt,
    required this.vaccines,
    required this.rateSum,
    required this.rateCount,
    required this.passport,
    required this.lastModified,
    this.location
  });

  String id;
  String name;
  String breed;
  bool isMale;
  DateTime birthdate;
  String photoUrl;
  String ownerId;
  int? type;
  DateTime createdAt;
  List<String> vaccines;
  int rateSum;
  int rateCount;
  String passport;
  DateTime lastModified;
  Location? location;

  factory PetProfile.fromShot(Map<String, dynamic> json) => PetProfile(
    id: json['_id'],
    name: json["name"],
    breed: json["breed"],
    isMale: json["isMale"],
    birthdate: DateTime.parse(json["birthdate"]),
    photoUrl: json["photoUrl"],
    ownerId: json["ownerId"],
    type: json["owner"]?['type'],
    location: json['owner'] != null ? Location.fromJson(json['owner']["location"]) : null,
    createdAt: DateTime.parse(json["createdAt"]),
    vaccines: List<String>.from(json["vaccines"].map((x) => x)),
    rateSum: json["rateSum"],
    rateCount: json["rateCount"],
    passport: json["passport"],
    lastModified: DateTime.parse(json['lastModified'])
  );

  factory PetProfile.fromJson(Map<String, dynamic> json) => PetProfile(
    id: json["_id"],
    name: json["name"],
    breed: json["breed"],
    isMale: json["isMale"],
    birthdate: DateTime.fromMillisecondsSinceEpoch(json["birthdate"]),
    photoUrl: json["photoUrl"],
    ownerId: json["ownerId"],
    type: json['type'],
    location: json["location"] != null ? Location.fromJson(json["location"]) : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
    vaccines: List<String>.from(json["vaccines"].map((x) => x)),
    rateSum: json["rateSum"],
    rateCount: json["rateCount"],
    passport: json["passport"],
    lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified'])
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "breed": breed,
    "isMale": isMale,
    "birthdate": birthdate.millisecondsSinceEpoch,
    "photoUrl": photoUrl,
    "ownerId": ownerId,
    "type": type,
    "location": location?.toJson(),
    "createdAt": createdAt.millisecondsSinceEpoch,
    "vaccines": List<dynamic>.from(vaccines.map((x) => x)),
    "rateSum": rateSum,
    "rateCount": rateCount,
    "passport": passport,
    "lastModified": lastModified.millisecondsSinceEpoch
  };

  Map<String, dynamic> toShot() => {
    "name": name,
    "breed": breed,
    "isMale": isMale,
    "birthdate": birthdate,
    "photoUrl": photoUrl,
    "ownerId": ownerId,
    "verified": type,
    "location": location?.toJson(),
    "createdAt": createdAt,
    "vaccines": List<dynamic>.from(vaccines.map((x) => x)),
    "rateSum": rateSum,
    "rateCount": rateCount,
    "passport": passport,
    "lastModified": lastModified
  };
}
// To parse this JSON data, do
//

List<PetAnalysis> petAnalysisFromJson(String str) => List<PetAnalysis>.from(json.decode(str).map((x) => PetAnalysis.fromJson(x)));

String petAnalysisToJson(List<PetAnalysis> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PetAnalysis {
  List<Label> labels;
  List<dynamic> moderationLabels;
  String vendor;
  String imageId;
  DateTime createdAt;

  PetAnalysis({
    required this.labels,
    required this.moderationLabels,
    required this.vendor,
    required this.imageId,
    required this.createdAt,
  });

  factory PetAnalysis.fromJson(Map<String, dynamic> json) => PetAnalysis(
    labels: List<Label>.from(json["labels"].map((x) => Label.fromJson(x))),
    moderationLabels: List<dynamic>.from(json["moderation_labels"].map((x) => x)),
    vendor: json["vendor"],
    imageId: json["image_id"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "labels": List<dynamic>.from(labels.map((x) => x.toJson())),
    "moderation_labels": List<dynamic>.from(moderationLabels.map((x) => x)),
    "vendor": vendor,
    "image_id": imageId,
    "created_at": createdAt.toIso8601String(),
  };
}

class Label {
  String name;
  double confidence;
  List<Instance> instances;
  List<Parent> parents;

  Label({
    required this.name,
    required this.confidence,
    required this.instances,
    required this.parents,
  });

  factory Label.fromJson(Map<String, dynamic> json) => Label(
    name: json["Name"],
    confidence: json["Confidence"]?.toDouble(),
    instances: List<Instance>.from(json["Instances"].map((x) => Instance.fromJson(x))),
    parents: List<Parent>.from(json["Parents"].map((x) => Parent.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Confidence": confidence,
    "Instances": List<dynamic>.from(instances.map((x) => x.toJson())),
    "Parents": List<dynamic>.from(parents.map((x) => x.toJson())),
  };
}

class Instance {
  BoundingBox boundingBox;
  double confidence;

  Instance({
    required this.boundingBox,
    required this.confidence,
  });

  factory Instance.fromJson(Map<String, dynamic> json) => Instance(
    boundingBox: BoundingBox.fromJson(json["BoundingBox"]),
    confidence: json["Confidence"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "BoundingBox": boundingBox.toJson(),
    "Confidence": confidence,
  };
}

class BoundingBox {
  double width;
  double height;
  double left;
  double top;

  BoundingBox({
    required this.width,
    required this.height,
    required this.left,
    required this.top,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) => BoundingBox(
    width: json["Width"]?.toDouble(),
    height: json["Height"]?.toDouble(),
    left: json["Left"]?.toDouble(),
    top: json["Top"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "Width": width,
    "Height": height,
    "Left": left,
    "Top": top,
  };
}

class Parent {
  String name;

  Parent({
    required this.name,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
  };
}




List<MateRequest> mateRequestFromShot(List<dynamic> data) => List<MateRequest>.from(data.map((e) => MateRequest.fromShot(e)));
List<MateRequest> mateRequestFromDocs(List<DocumentSnapshot<Map<String, dynamic>>> docs) => List<MateRequest>.from(docs.map((x) => MateRequest.fromShot(x.data()!)));
List<MateRequest> mateRequestFromJson(String data) => List<MateRequest>.from(json.decode(data).map((x) => MateRequest.fromJson(x)));


String mateRequestToJson(List<MateRequest> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

MateRequest singleMateRequestFromShot(Map<String, dynamic> data) => MateRequest.fromShot(data);
MateRequest singleMateRequestFromJson(Map<String, dynamic> data) => MateRequest.fromJson(data);

String singleMateRequestToJson(MateRequest data) => json.encode(data.toJson());

class MateRequest {
  MateRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderPetId,
    required this.receiverPetId,
    required this.status,
    required this.createdAt,
    required this.lastModified,
    this.senderPet,
    this.receiverPet

  });

  String id;
  String senderId;
  String receiverId;
  String senderPetId;
  String receiverPetId;
  requestState status;
  DateTime createdAt;
  DateTime lastModified;
  PetProfile? senderPet;
  PetProfile? receiverPet;

  factory MateRequest.fromShot(Map<String, dynamic> json) => MateRequest(
    id: json['_id'],
    senderId: json["senderId"],
    receiverId: json["receiverId"],
    senderPetId: json["senderPetId"],
    receiverPetId: json["receiverPetId"],
    status: requestState.values[json["status"]],
    createdAt: DateTime.parse(json['createdAt']),
    lastModified:  DateTime.parse(json['lastModified']),
    senderPet: json['senderPet'] != null ? singlePetProfileFromShot(json['senderPet']) : null,
    receiverPet: json['receiverPet'] != null ? singlePetProfileFromShot(json['receiverPet']): null
  );
  factory MateRequest.fromJson(Map<String, dynamic> json) => MateRequest(
    id: json['_id'],
    senderId: json["senderId"],
    receiverId: json["receiverId"],
    senderPetId: json["senderPetId"],
    receiverPetId: json["receiverPetId"],
    status: requestState.values[json["status"]],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified']),
    senderPet: json['senderPet'] != null ? singlePetProfileFromShot(json['senderPet']) : null,
    receiverPet: json['receiverPet'] != null ? singlePetProfileFromShot(json['receiverPet']): null
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "senderId": senderId,
    "receiverId": receiverId,
    "senderPetId": senderPetId,
    "receiverPetId": receiverPetId,
    "status": status.index,
    "createdAt": createdAt.millisecondsSinceEpoch,
    "lastModified": lastModified.millisecondsSinceEpoch,
    "senderPet": senderPet?.toJson(),
    "receiverPet": receiverPet?.toJson()
  };

  petSendState(String petID){
    if (petID == senderId){
      return status;
    }else{
      return -1;
    }
  }

  petReceiveState(String petID){
    if (petID == receiverId){
      return status;
    }else{
      return -1;
    }
  }

}

