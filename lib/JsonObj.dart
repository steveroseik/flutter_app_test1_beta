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
    "id": id,
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
  PhotoResponse({
    required this.id,
    required this.url,
    required this.subId,
    required this.originalFilename,
    required this.pending,
    required this.approved,
  });

  String id;
  String url;
  String subId;
  String originalFilename;
  int pending;
  int approved;

  factory PhotoResponse.fromJson(Map<String, dynamic> json) => PhotoResponse(
    id: json["id"],
    url: json["url"],
    subId: json["sub_id"],
    originalFilename: json["original_filename"],
    pending: json["pending"],
    approved: json["approved"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "sub_id": subId,
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

UserPod userPodFromShot(QuerySnapshot<Map<String, dynamic>> shot) => UserPod.fromShot(shot.docs.first.data(), shot.docs.first.id);
UserPod userPodFromJson(String data) => UserPod.fromJson(json.decode(data));
UserPod userPodFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) => UserPod.fromShot(doc.data()!, doc.id);
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
    required this.ts,
    required this.country,
    required this.email,
    required this.petCount,
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
  DateTime ts;
  String country;
  String email;
  int petCount;
  DateTime lastModified;

  factory UserPod.fromShot(Map<String, dynamic> json, String id) => UserPod(
    id: id,
    lastName: json["lastName"],
    firstName: json["firstName"],
    phone: json["phone"],
    type: json["type"],
    isMale: json["isMale"],
    birthdate: (json["birthdate"] as Timestamp).toDate(),
    location: Location.fromJson(json["location"]),
    city: json["city"],
    photoUrl: json["photoUrl"],
    ts: json["ts"].toDate(),
    country: json["country"],
    email: json["email"],
    petCount: json["petCount"],
    lastModified: json['lastModified'].toDate()
  );

  factory UserPod.fromJson(Map<String, dynamic> json) => UserPod(
      id: json['id'],
      lastName: json["lastName"],
      firstName: json["firstName"],
      phone: json["phone"],
      type: json["type"],
      isMale: json["isMale"],
      birthdate: DateTime.fromMillisecondsSinceEpoch(json['birthdate']),
      location: Location.fromJson(json["location"]),
      city: json["city"],
      photoUrl: json["photoUrl"],
      ts: DateTime.fromMillisecondsSinceEpoch(json["ts"]),
      country: json["country"],
      email: json["email"],
      petCount: json["petCount"],
      lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified'])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lastName": lastName,
    "firstName": firstName,
    "phone": phone,
    "type": type,
    "isMale": isMale,
    "birthdate": birthdate.millisecondsSinceEpoch,
    "location": location.toJson(),
    "city": city,
    "photoUrl": photoUrl,
    "ts": ts.millisecondsSinceEpoch,
    "country": country,
    "email": email,
    "petCount": petCount,
    "lastModified": lastModified.millisecondsSinceEpoch

  };

  Map<String, dynamic> toShot() => {
    "lastName": lastName,
    "firstName": firstName,
    "phone": phone,
    "type": type,
    "isMale": isMale,
    "birthdate": Timestamp.fromMillisecondsSinceEpoch(birthdate.millisecondsSinceEpoch),
    "location": location.toJson(),
    "city": city,
    "photoUrl": photoUrl,
    "ts": Timestamp.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch),
    "country": country,
    "email": email,
    "petCount": petCount,
    "lastModified": Timestamp.fromMillisecondsSinceEpoch(lastModified.millisecondsSinceEpoch)
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
    DateTime? ts,
    String? country,
    String? email,
    int? petCount,
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
        ts: ts ?? this.ts,
        country: country ?? this.country,
        email: email ?? this.email,
        petCount: petCount ?? this.petCount,
        lastModified: lastModified ?? this.lastModified);
  }

}

class Location {
  Location({
    required this.longtitude,
    required this.latitude,
  });

  double longtitude;
  double latitude;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    longtitude: json["longtitude"],
    latitude: json["latitude"],
  );

  Map<String, dynamic> toJson() => {
    "longtitude": longtitude,
    "latitude": latitude,
  };
}


List<PetProfile> petProfileFromShot(QuerySnapshot<Map<String, dynamic>> query) => List<PetProfile>.from(query.docs.map((x) => PetProfile.fromShot(x.data(), x.reference.path)));
List<PetProfile> petProfileFromDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> query) => List<PetProfile>.from(query.map((x) => PetProfile.fromShot(x.data(), x.reference.path)));
List<PetProfile> petProfileFromJson(String data) => List<PetProfile>.from(json.decode(data).map((e) => PetProfile.fromJson(e)));
String petProfileToJson(List<PetProfile> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

PetProfile singlePetProfileFromShot(Map<String, dynamic> data, String id) => PetProfile.fromShot(data, id);
PetProfile singlePetProfileFromJson(String data) => PetProfile.fromJson(json.decode(data));
PetProfile singlePetProfileFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) => PetProfile.fromShot(doc.data(), doc.reference.path);
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
    required this.verified,
    required this.ts,
    required this.vaccines,
    required this.rateSum,
    required this.rateCount,
    required this.passport,
    required this.lastModified,
    required this.location
  });

  String id;
  String name;
  String breed;
  bool isMale;
  DateTime birthdate;
  String photoUrl;
  String ownerId;
  bool verified;
  DateTime ts;
  List<String> vaccines;
  int rateSum;
  int rateCount;
  String passport;
  DateTime lastModified;
  Location location;

  factory PetProfile.fromShot(Map<String, dynamic> json, String? id) => PetProfile(
    id: id?? json["id"],
    name: json["name"],
    breed: json["breed"],
    isMale: json["isMale"],
    birthdate: json["birthdate"].toDate(),
    photoUrl: json["photoUrl"],
    ownerId: json["ownerId"],
    verified: json["verified"],
    location: Location.fromJson(json["location"]),
    ts: json["ts"].toDate(),
    vaccines: List<String>.from(json["vaccines"].map((x) => x)),
    rateSum: json["rateSum"],
    rateCount: json["rateCount"],
    passport: json["passport"],
    lastModified: json['lastModified'].toDate()
  );

  factory PetProfile.fromJson(Map<String, dynamic> json) => PetProfile(
    id: json["id"],
    name: json["name"],
    breed: json["breed"],
    isMale: json["isMale"],
    birthdate: DateTime.fromMillisecondsSinceEpoch(json["birthdate"]),
    photoUrl: json["photoUrl"],
    ownerId: json["ownerId"],
    verified: json["verified"],
    location: Location.fromJson(json["location"]),
    ts: DateTime.fromMillisecondsSinceEpoch(json["ts"]),
    vaccines: List<String>.from(json["vaccines"].map((x) => x)),
    rateSum: json["rateSum"],
    rateCount: json["rateCount"],
    passport: json["passport"],
    lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified'])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "breed": breed,
    "isMale": isMale,
    "birthdate": birthdate.millisecondsSinceEpoch,
    "photoUrl": photoUrl,
    "ownerId": ownerId,
    "verified": verified,
    "location": location.toJson(),
    "ts": ts.millisecondsSinceEpoch,
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
    "birthdate": Timestamp.fromMillisecondsSinceEpoch(birthdate.millisecondsSinceEpoch),
    "photoUrl": photoUrl,
    "ownerId": ownerId,
    "verified": verified,
    "location": location.toJson(),
    "ts": Timestamp.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch),
    "vaccines": List<dynamic>.from(vaccines.map((x) => x)),
    "rateSum": rateSum,
    "rateCount": rateCount,
    "passport": passport,
    "lastModified": lastModified.millisecondsSinceEpoch
  };
}
// To parse this JSON data, do
//

List<PetAnalysis> petAnalysisFromJson(String str) => List<PetAnalysis>.from(json.decode(str).map((x) => PetAnalysis.fromJson(x)));

String petAnalysisToJson(List<PetAnalysis> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PetAnalysis {
  PetAnalysis({
    required this.labels,
    required this.moderationLabels,
    required this.vendor,
    required this.imageId,
    required this.createdAt,
  });

  List<Label> labels;
  List<dynamic> moderationLabels;
  String vendor;
  String imageId;
  DateTime createdAt;

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
  Label({
    required this.name,
    required this.confidence,
    required this.instances,
    required this.parents,
  });

  String name;
  double confidence;
  List<Instance> instances;
  List<Parent> parents;

  factory Label.fromJson(Map<String, dynamic> json) => Label(
    name: json["Name"],
    confidence: json["Confidence"].toDouble(),
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
  Instance({
    required this.boundingBox,
    required this.confidence,
  });

  BoundingBox boundingBox;
  double confidence;

  factory Instance.fromJson(Map<String, dynamic> json) => Instance(
    boundingBox: BoundingBox.fromJson(json["BoundingBox"]),
    confidence: json["Confidence"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "BoundingBox": boundingBox.toJson(),
    "Confidence": confidence,
  };
}

class BoundingBox {
  BoundingBox({
    required this.width,
    required this.height,
    required this.left,
    required this.top,
  });

  double width;
  double height;
  double left;
  double top;

  factory BoundingBox.fromJson(Map<String, dynamic> json) => BoundingBox(
    width: json["Width"].toDouble(),
    height: json["Height"].toDouble(),
    left: json["Left"].toDouble(),
    top: json["Top"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "Width": width,
    "Height": height,
    "Left": left,
    "Top": top,
  };
}

class Parent {
  Parent({
    required this.name,
  });

  String name;

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
  };
}



List<MateRequest> mateRequestFromShot(QuerySnapshot<Map<String, dynamic>> query) => List<MateRequest>.from(query.docs.map((x) => MateRequest.fromShot(x.data(), x.id)));
List<MateRequest> mateRequestFromDocs(List<DocumentSnapshot<Map<String, dynamic>>> docs) => List<MateRequest>.from(docs.map((x) => MateRequest.fromShot(x.data()!, x.id)));
List<MateRequest> mateRequestFromJson(String data) => List<MateRequest>.from(json.decode(data).map((x) => MateRequest.fromJson(x)));


String mateRequestToJson(List<MateRequest> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
String mateRequestToFirebase(List<MateRequest> data) => json.encode(List<dynamic>.from(data.map((x) => x.toFirebase())));

MateRequest singleMateRequestFromShot(Map<String, dynamic> data, String id) => MateRequest.fromShot(data, id);
MateRequest singleMateRequestFromJson(Map<String, dynamic> data) => MateRequest.fromJson(data);

String singleMateRequestToJson(MateRequest data) => json.encode(data.toJson());
String singleMateRequestToFirebase(MateRequest data) => json.encode(data.toFirebase());

class MateRequest {
  MateRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderPet,
    required this.receiverPet,
    required this.status,
    required this.ts,
    required this.lastModified,
  });

  String id;
  String senderId;
  String receiverId;
  String senderPet;
  String receiverPet;
  requestState status;
  DateTime ts;
  DateTime lastModified;

  factory MateRequest.fromShot(Map<String, dynamic> json, String id) => MateRequest(
    id: id,
    senderId: json["senderId"],
    receiverId: json["receiverId"],
    senderPet: json["senderPet"],
    receiverPet: json["receiverPet"],
    status: requestState.values[json["status"]],
    ts: json['ts'].toDate(),
    lastModified: json['lastModified'].toDate()
  );
  factory MateRequest.fromJson(Map<String, dynamic> json) => MateRequest(
    id: json['id'],
    senderId: json["senderId"],
    receiverId: json["receiverId"],
    senderPet: json["senderPet"],
    receiverPet: json["receiverPet"],
    status: requestState.values[json["status"]],
    ts: DateTime.fromMillisecondsSinceEpoch(json['ts']),
    lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified'])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sender_id": senderId,
    "receiver_id": receiverId,
    "sender_pet": senderPet,
    "receiver_pet": receiverPet,
    "status": status.index,
    "ts": ts.millisecondsSinceEpoch,
    "lastModofied": lastModified.millisecondsSinceEpoch
  };
  Map<String, dynamic> toFirebase() => {
    "senderId": senderId,
    "receiverId": receiverId,
    "senderPet": senderPet,
    "receiverPet": receiverPet,
    "status": status.index,
    "ts": Timestamp.fromDate(ts),
    "lastModified": Timestamp.fromDate(lastModified)
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

