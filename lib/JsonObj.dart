import 'dart:convert';

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

class ImgUploaded {
  ImgUploaded({
    required this.statusCode,
    required this.success,
    required this.image,
    required this.statusTxt,
  });

  int statusCode;
  Success success;
  ImgUploadedImage image;
  String statusTxt;

  factory ImgUploaded.fromJson(Map<String, dynamic> json) => ImgUploaded(
    statusCode: json["status_code"],
    success: Success.fromJson(json["success"]),
    image: ImgUploadedImage.fromJson(json["image"]),
    statusTxt: json["status_txt"],
  );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "success": success.toJson(),
    "image": image.toJson(),
    "status_txt": statusTxt,
  };
}
ImgUploaded imgUploadedFromJson(String str) => ImgUploaded.fromJson(json.decode(str));

String imgUploadedToJson(ImgUploaded data) => json.encode(data.toJson());

class ImgUploadedImage {
  ImgUploadedImage({
    required this.name,
    required this.extension,
    required this.width,
    required this.height,
    required this.size,
    required this.time,
    required this.expiration,
    required this.adult,
    required this.status,
    required this.cloud,
    required this.vision,
    required this.likes,
    required this.description,
    required this.originalExifdata,
    required this.originalFilename,
    required this.viewsHtml,
    required this.viewsHotlink,
    required this.accessHtml,
    required this.accessHotlink,
    required this.file,
    required this.isAnimated,
    required this.nsfw,
    required this.idEncoded,
    required this.ratio,
    required this.sizeFormatted,
    required this.filename,
    required this.url,
    required this.urlShort,
    required this.urlSeo,
    required this.urlViewer,
    required this.urlViewerPreview,
    required this.urlViewerThumb,
    required this.image,
    required this.thumb,
    required this.medium,
    required this.displayUrl,
    required this.displayWidth,
    required this.displayHeight,
    required this.viewsLabel,
    required this.likesLabel,
    required this.howLongAgo,
    required this.dateFixedPeer,
    required this.title,
    required this.titleTruncated,
    required this.titleTruncatedHtml,
    required this.isUseLoader,
  });

  String name;
  String extension;
  String width;
  String height;
  int size;
  String time;
  String expiration;
  String adult;
  String status;
  String cloud;
  String vision;
  String likes;
  dynamic description;
  dynamic originalExifdata;
  String originalFilename;
  String viewsHtml;
  String viewsHotlink;
  String accessHtml;
  String accessHotlink;
  FileClass file;
  int isAnimated;
  int nsfw;
  String idEncoded;
  double ratio;
  String sizeFormatted;
  String filename;
  String url;
  String urlShort;
  String urlSeo;
  String urlViewer;
  String urlViewerPreview;
  String urlViewerThumb;
  MediumClass image;
  MediumClass thumb;
  MediumClass medium;
  String displayUrl;
  String displayWidth;
  String displayHeight;
  String viewsLabel;
  String likesLabel;
  String howLongAgo;
  DateTime dateFixedPeer;
  String title;
  String titleTruncated;
  String titleTruncatedHtml;
  bool isUseLoader;

  factory ImgUploadedImage.fromJson(Map<String, dynamic> json) => ImgUploadedImage(
    name: json["name"],
    extension: json["extension"],
    width: json["width"],
    height: json["height"],
    size: json["size"],
    time: json["time"],
    expiration: json["expiration"],
    adult: json["adult"],
    status: json["status"],
    cloud: json["cloud"],
    vision: json["vision"],
    likes: json["likes"],
    description: json["description"],
    originalExifdata: json["original_exifdata"],
    originalFilename: json["original_filename"],
    viewsHtml: json["views_html"],
    viewsHotlink: json["views_hotlink"],
    accessHtml: json["access_html"],
    accessHotlink: json["access_hotlink"],
    file: FileClass.fromJson(json["file"]),
    isAnimated: json["is_animated"],
    nsfw: json["nsfw"],
    idEncoded: json["id_encoded"],
    ratio: json["ratio"].toDouble(),
    sizeFormatted: json["size_formatted"],
    filename: json["filename"],
    url: json["url"],
    urlShort: json["url_short"],
    urlSeo: json["url_seo"],
    urlViewer: json["url_viewer"],
    urlViewerPreview: json["url_viewer_preview"],
    urlViewerThumb: json["url_viewer_thumb"],
    image: MediumClass.fromJson(json["image"]),
    thumb: MediumClass.fromJson(json["thumb"]),
    medium: MediumClass.fromJson(json["medium"]),
    displayUrl: json["display_url"],
    displayWidth: json["display_width"],
    displayHeight: json["display_height"],
    viewsLabel: json["views_label"],
    likesLabel: json["likes_label"],
    howLongAgo: json["how_long_ago"],
    dateFixedPeer: DateTime.parse(json["date_fixed_peer"]),
    title: json["title"],
    titleTruncated: json["title_truncated"],
    titleTruncatedHtml: json["title_truncated_html"],
    isUseLoader: json["is_use_loader"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "extension": extension,
    "width": width,
    "height": height,
    "size": size,
    "time": time,
    "expiration": expiration,
    "adult": adult,
    "status": status,
    "cloud": cloud,
    "vision": vision,
    "likes": likes,
    "description": description,
    "original_exifdata": originalExifdata,
    "original_filename": originalFilename,
    "views_html": viewsHtml,
    "views_hotlink": viewsHotlink,
    "access_html": accessHtml,
    "access_hotlink": accessHotlink,
    "file": file.toJson(),
    "is_animated": isAnimated,
    "nsfw": nsfw,
    "id_encoded": idEncoded,
    "ratio": ratio,
    "size_formatted": sizeFormatted,
    "filename": filename,
    "url": url,
    "url_short": urlShort,
    "url_seo": urlSeo,
    "url_viewer": urlViewer,
    "url_viewer_preview": urlViewerPreview,
    "url_viewer_thumb": urlViewerThumb,
    "image": image.toJson(),
    "thumb": thumb.toJson(),
    "medium": medium.toJson(),
    "display_url": displayUrl,
    "display_width": displayWidth,
    "display_height": displayHeight,
    "views_label": viewsLabel,
    "likes_label": likesLabel,
    "how_long_ago": howLongAgo,
    "date_fixed_peer": dateFixedPeer.toIso8601String(),
    "title": title,
    "title_truncated": titleTruncated,
    "title_truncated_html": titleTruncatedHtml,
    "is_use_loader": isUseLoader,
  };
}

class FileClass {
  FileClass({
    required this.resource,
  });

  Resource resource;

  factory FileClass.fromJson(Map<String, dynamic> json) => FileClass(
    resource: Resource.fromJson(json["resource"]),
  );

  Map<String, dynamic> toJson() => {
    "resource": resource.toJson(),
  };
}

class Resource {
  Resource({
    required this.chain,
    required this.chainCode,
  });

  Chain chain;
  Chain chainCode;

  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
    chain: Chain.fromJson(json["chain"]),
    chainCode: Chain.fromJson(json["chain_code"]),
  );

  Map<String, dynamic> toJson() => {
    "chain": chain.toJson(),
    "chain_code": chainCode.toJson(),
  };
}

class Chain {
  Chain({
    required this.image,
    required this.thumb,
    required this.medium,
  });

  String image;
  String thumb;
  String medium;

  factory Chain.fromJson(Map<String, dynamic> json) => Chain(
    image: json["image"],
    thumb: json["thumb"],
    medium: json["medium"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "thumb": thumb,
    "medium": medium,
  };
}

class MediumClass {
  MediumClass({
    required this.filename,
    required this.name,
    required this.mime,
    required this.extension,
    required this.url,
    required this.size,
  });

  String filename;
  String name;
  String mime;
  String extension;
  String url;
  int size;

  factory MediumClass.fromJson(Map<String, dynamic> json) => MediumClass(
    filename: json["filename"],
    name: json["name"],
    mime: json["mime"],
    extension: json["extension"],
    url: json["url"],
    size: json["size"] == null ? null : json["size"],
  );

  Map<String, dynamic> toJson() => {
    "filename": filename,
    "name": name,
    "mime": mime,
    "extension": extension,
    "url": url,
    "size": size == null ? null : size,
  };
}

class Success {
  Success({
    required this.message,
    required this.code,
  });

  String message;
  int code;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    message: json["message"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
  };
}

List<PetProfile> petProfileFromJson(String str) => List<PetProfile>.from(json.decode(str).map((x) => PetProfile.fromJson(x)));

String petProfileToJson(List<PetProfile> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PetProfile {
  PetProfile({
    required this.id,
    required this.name,
    required this.breed,
    required this.isMale,
    required this.birthdate,
    required this.photoUrl,
    required this.ownerId,
    required this.ready,
    required this.createdAt,
    required this.vaccines,
    required this.rateSum,
    required this.rateCount,
    required this.passport,
  });

  String id;
  String name;
  String breed;
  bool isMale;
  DateTime birthdate;
  String photoUrl;
  String ownerId;
  bool ready;
  DateTime createdAt;
  List<String> vaccines;
  int rateSum;
  int rateCount;
  String passport;

  factory PetProfile.fromJson(Map<String, dynamic> json) => PetProfile(
    id: json["id"],
    name: json["name"],
    breed: json["breed"],
    isMale: json["isMale"],
    birthdate: DateTime.parse(json["birthdate"]),
    photoUrl: json["photo_url"],
    ownerId: json["owner_id"],
    ready: json["ready"],
    createdAt: DateTime.parse(json["created_at"]),
    vaccines: List<String>.from(json["vaccines"].map((x) => x)),
    rateSum: json["rateSum"],
    rateCount: json["rateCount"],
    passport: json["passport"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "breed": breed,
    "isMale": isMale,
    "birthdate": "${birthdate.year.toString().padLeft(4, '0')}-${birthdate.month.toString().padLeft(2, '0')}-${birthdate.day.toString().padLeft(2, '0')}",
    "photo_url": photoUrl,
    "owner_id": ownerId,
    "ready": ready,
    "created_at": createdAt.toIso8601String(),
    "vaccines": List<dynamic>.from(vaccines.map((x) => x)),
    "rateSum": rateSum,
    "rateCount": rateCount,
    "passport": passport,
  };
}



SinglePetProfile singlePetProfileFromJson(String str) => SinglePetProfile.fromJson(json.decode(str));

String singlePetProfileToJson(SinglePetProfile data) => json.encode(data.toJson());

class SinglePetProfile {
  SinglePetProfile({
   required this.id,
   required this.name,
   required this.breed,
   required this.isMale,
   required this.birthdate,
   required this.photoUrl,
   required this.ownerId,
   required this.ready,
   required this.createdAt,
   required this.vaccines,
  });

  String id;
  String name;
  String breed;
  bool isMale;
  DateTime birthdate;
  String photoUrl;
  String ownerId;
  bool ready;
  DateTime createdAt;
  List<String> vaccines;

  factory SinglePetProfile.fromJson(Map<String, dynamic> json) => SinglePetProfile(
    id: json["id"],
    name: json["name"],
    breed: json["breed"],
    isMale: json["isMale"],
    birthdate: DateTime.parse(json["birthdate"]),
    photoUrl: json["photo_url"],
    ownerId: json["owner_id"],
    ready: json["ready"],
    createdAt: DateTime.parse(json["created_at"]),
    vaccines: List<String>.from(json["vaccines"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "breed": breed,
    "isMale": isMale,
    "birthdate": "${birthdate.year.toString().padLeft(4, '0')}-${birthdate.month.toString().padLeft(2, '0')}-${birthdate.day.toString().padLeft(2, '0')}",
    "photo_url": photoUrl,
    "owner_id": ownerId,
    "ready": ready,
    "created_at": createdAt.toIso8601String(),
    "vaccines": List<dynamic>.from(vaccines.map((x) => x)),
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
