import 'dart:async';
import 'dart:io' as io;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FETCH_wdgts.dart';
import 'cacheBox.dart';

// Function to retry requests : retry(int, Future<>);
typedef Future<T> FutureGenerator<T>();

final dB = FirebaseFirestore.instance;

const gqlUrl = 'http://192.168.1.8:5000/graphql';//'https://o8klhba4g7.execute-api.eu-west-1.amazonaws.com/dev/graphql';

int readsTotal = 0;

Future<T> retry<T>(int retries, FutureGenerator aFuture) async {
  try {
    return await aFuture();
  } catch (e) {
    if (retries > 1) {
      return retry(retries - 1, aFuture);
    }

    rethrow;
  }
}

// Function returns breeds of dogs with image url
Future<List<Breed>> getBreedList(int counter) async {

  try {
    final resp = await SupabaseCredentials.supabaseClient.from('breed').select('*') as List<dynamic>;
    return breedFromJson(jsonEncode(resp));
  } catch (e) {
    print('getBreedList err: $e');
    return List<Breed>.empty();
  }finally{

  }
}
Future generateBreedPossibilities(String id) async{
  try {
    Map<String, String> headers = {
      'x-api-key': '7312afbd-ed2d-4fe2-b7d9-b66602ea58f7'
    };

    var url = Uri.parse('https://api.thedogapi.com/v1/images/$id/analysis');

    var response = await http.get(url, headers: headers);
    final obj = petAnalysisFromJson(response.body);

    final rejectedNames = ['DOG', 'MAMMAL', 'PET', 'ANIMAL',
                        'GRASS', 'PLANT', 'PUPPY','CANINE', 'HOUND', 'TERRIER', ];
    final breeds = await getBreedList(0);
    final List<String> names = <String>[];
    final matches = <Breed>[];
    for(Label label in obj[0].labels){
      if (!rejectedNames.contains(label.name.toUpperCase())) names.add(label.name);
      for(Parent parent in label.parents){
        if (!rejectedNames.contains(parent.name.toUpperCase())) names.add(parent.name);

      }
    }
    print(names);
    for (Breed breed in breeds){
      for (String name in names){
        if (breed.name.toUpperCase().contains(name.toUpperCase())){
          matches.add(breed);
        }
      }

    }
    return matches;

  } catch (e) {
    print(e);
  }
  return List<String>.empty();
}

// POST Request for sending pet photo to thedogapi API for verification
Future<PhotoResponse> getUploadResponse(io.File imgFile) async {
  late final PhotoResponse pRes;
  try {
    Map<String, String> headers = {
      'x-api-key': '7312afbd-ed2d-4fe2-b7d9-b66602ea58f7'
    };

    var url = Uri.parse('https://api.thedogapi.com/v1/images/upload');
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    var multipartFile = await http.MultipartFile.fromPath('file', imgFile.path,
        filename: basename(imgFile.path),
        contentType: MediaType("image", "jpeg"));

    request.files.add(multipartFile);
    request.fields['sub_id'] = 'betaTest_FETCH';

    var res = await request.send();
    var response = await http.Response.fromStream(res);

    if (response.statusCode == 201) {
      pRes = photoResponseFromJson(response.body);
      if (pRes.approved == 1) {
        return pRes;
      }

      return PhotoResponse(
          id: '-505',
          url: "Can't find a dog in photo",
          subId: '-11',
          originalFilename: '-11',
          width: 0,
          height: 0,
          pending: -1,
          approved: -1);
    }

    return PhotoResponse(
        id: '-503',
        url: 'No response received',
        subId: '-11',
        originalFilename: '-11',
        pending: -1,
        width: 0,
        height: 0,
        approved: -1);
  } catch (e) {
    return PhotoResponse(
        id: '-504',
        url: 'An error happened, retry process',
        subId: '-11',
        originalFilename: '-11',
        pending: -1,
        width: 0,
        height: 0,
        approved: -1);
  }
}


Future<String?> generateMyToken({required SharedPreferences prefs}) async{
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  try{
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = {
      'query': '''mutation{
  login(userId: "$uid")
    }''',
    };

    final response = await http.post(
      Uri.parse(gqlUrl),
      headers: headers,
      body: jsonEncode(body),
    );
    print(response.body);
    final data = jsonDecode(response.body);
    if (data['data']['login']['token'] != null){
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('authToken', data['data']['login']['token']);
      return data['data']['login']['token'];
    }
  }catch (e){
    if (kDebugMode) print('generateMyToken error: $e');
  }
  return null;

}

Future<Map<String, dynamic>?> sendGraphQLQuery(String q) async {
  bool retry = true;
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');
  if (token == null || token.isEmpty) token = await generateMyToken(prefs: prefs);

  do{
    retry = false;
    try{
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final body = {
        'query': q,
      };

      final response = await http.post(
        Uri.parse(gqlUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        String? errMsg = data['errors']?[0]['message'];
        if (errMsg != null && errMsg == 'jwt expired'){
          token = await generateMyToken(prefs: prefs);
          retry = true;
        }else{
          return data;
        }
      }else{
        throw Exception('Status code: ${response.statusCode} \n Message: ${response.body}');
      }

    }catch (e){
      print(q);
      print("errr GQL: ${e.toString()}");
      return null;
    }
  }while(retry);
}


// add pet
Future<List<dynamic>> addPet(String name, String dogBreed, bool isMale, DateTime petBirthDate, String photoUrl, String uid, List<String> vaccines, String pdfUrl) async{
  int ret = -100;
  PetProfile? newPet;
  try{
    final query = '''
    mutation{
   addPet(name: "$name", breed: "$dogBreed", ownerId: "$uid"
   birthdate: "${petBirthDate.toIso8601String()}", 
   isMale: $isMale,
   vaccines: ${jsonEncode(vaccines)}, passport: "$pdfUrl", photoUrl: "$photoUrl"){
      _id,
      name,
      breed,
      isMale,
      birthdate,
      photoUrl,
      ownerId,
      createdAt,
      lastModified,
      vaccines,
      rateSum,
      rateCount,
      passport,
   }
}''';
    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['addPet'] != null){
      newPet = singlePetProfileFromShot(response['data']['addPet']);
      ret = 200;
    }
  } catch (error) {
    print('addPet ERR: $error');
  }

  return [ret, newPet];
}

//TODO: OUTDATED
Future incrementUserPetCount(String uid, int petCount) async{
  int ret = -100;
  try{
    await dB.collection('users').doc(uid).update({"petCount": petCount, "lastModified": FieldValue.serverTimestamp()});
    ret = 200;
  }catch (e){
    print("incrementFunction: ${e}");
  }
  return ret;
}



Future editPet(String? name, bool? isMale, DateTime? petBirthDate, List<dynamic> vaccines, String pid, String? breed,
    String? passport) async{
  int ret = -100;
  try{

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final query = '''
    mutation{
      editPet(
      id: "$pid",
      ownerId: "$uid",
      vaccines: ${jsonEncode(vaccines)},
      ${name != null ? 'name: "$name"': '' },
      ${isMale != null ? 'isMale: "$isMale"': '' },
      ${petBirthDate != null ? 'birthdate: "${petBirthDate.toIso8601String()}"' : ''}
      ${passport != null ? 'passport: "$passport"': '' },
      )
    }
    ''';
    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['editPet'] == 1) ret = 200;
  } catch (error) {
    print(error);
  }

  return ret;

}
// POST request for adding new user
Future addUser(String userid, String email, String phone, String fname,
    String lname, String country, String? state, String? city, DateTime birthdate, bool isMale) async {
  var resp = 100;
  UserPod? newUser;
 try {


 } catch (error) {
   print("addUserError: ${error}");
 }
  final query = '''
   mutation{
    addUser(
       id: "$userid",
       email: "$email",
       phone: "$phone",
       firstName: "${fname.capitalize()}",
       lastName: "${lname.capitalize()}",
       country: "$country",
       city: "$city",
       isMale: $isMale,
       birthdate: "${birthdate.toIso8601String()}",
       lat: 0.0, 
       long: 0.0,
       type: 0,
       photoUrl: "",
    )
   }
   ''';
  final response = await sendGraphQLQuery(query);
  if (response != null && response['data']['addUser'] == 'success') {

    final data = await sendGraphQLQuery('''{
       getMyUserData(id: "$userid"){
       _id,
       firstName,
       lastName,
       email,
       birthdate,
       isMale,
       country,
       city,
       location,
       type,
       verified,
       createdAt,
       lastModified,
       phone,
       photoUrl,
       }
   }''');

    newUser = userPodFromShot(data!['data']['getMyUserData']);

    resp = 200;
  }
  //TODO: Lazem yrg3lo token w baadein ygeeb biha el data!!!!
  return [resp, newUser];

}


//TODO: needs to be more secure...?
Future<bool> verifyUser()async{
  final uid = FirebaseAuth.instance.currentUser!.uid;
  try{
    final query = '''
    mutation{
      editUser(
        id: "$uid",
        verified: true
      )
    }
    ''';

    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['editUser'] == 1){
      return true;
    }
    return false;
  }catch (e){
    print(e);
    return false;
  }
}


Future checkPhoneAvailability(String phoneNumber) async {
  var ret = -100;

  try {
    final query ='''{
      checkPhone(phone: "$phoneNumber")
    }
  ''';
    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['checkPhone'] != null){
      ret = response['data']['checkPhone'] as bool ? 200 : 1;
    }else {
      ret = 0;
    }
  } on PostgrestException catch (error) {
    print(error);
  } catch (error) {
    print("checkPAVail: ${error}");
  }
  return ret;

}

//check if user is registered in database
Future<List<dynamic>> userInDb(String email, String uid) async {
  //-1 = connection error
  // 0 = new user
  // 1 = user already exists
  // 2 = complete user
  usrState ret = usrState.connectionError;
  UserPod? pod;
  List<PetProfile> pets = <PetProfile>[];
  final query = '''{
    userExist(email: "$email", id: "$uid")
    }''';

  final response = await sendGraphQLQuery(query);

  if (response != null && response['data']['userExist'] != null){
    if (response['data']['userExist']['status'] != null){
      switch(response['data']['userExist']['status']){
        case 0: ret = usrState.newUser;
        break;
        case 1: ret = usrState.userAlreadyExists;
        break;
        case 2: ret = usrState.completeUser;
        break;
      }
    }
  }


  if (ret == usrState.completeUser){

    pod = userPodFromShot(response!['data']['userExist']['owner']);
    pets = petProfileFromShot(response['data']['userExist']['pets']);
  }
  try{

  }catch (e){
   print("exception: $e");
  }


  return [ret, pod, pets];
}

Future<String> uploadPhoto(io.File imgFile) async {
  // late final ImgUploaded img;
  String img = '-100';
  try{
    var url = Uri.parse('https://freeimage.host/api/1/upload?key=6d207e02198a847aa98d0a2a901485a5');
    var request = http.MultipartRequest('POST', url);

    var multipartFile = await http.MultipartFile.fromPath('source', imgFile.path,
        filename: basename(imgFile.path),
        contentType: new MediaType("image", "jpeg"));

    request.files.add(multipartFile);

    var _res = await request.send();
    var response = await http.Response.fromStream(_res);
    final dec = jsonDecode(response.body);

    if (dec['status_code'] != 200){
      img = '-100';
    }else{
      img = dec['image']['url'];
    }
  }catch (e){
    print('imageUploadError: $e');
    img = '-100';
  }
  return img;

}

Future fetchBreedNameList() async{

  try{
    final response = await SupabaseCredentials.supabaseClient.from('breed').select('name') as List<dynamic>;
    final petList = List<String>.generate(response.length, (index) {
      return response[index]['name'].toString();
    });
    return petList;

  }on PlatformException catch (e){
    return <String>[];
  }
}

Future<List<PetPod>>fetchPets(int petIndex) async{
  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final query = '''{
           pets(ownerId: "$uid"){
               _id,
                name,
                breed,
                isMale,
                birthdate,
                photoUrl,
                ownerId,
                createdAt,
                lastModified,
                vaccines,
                rateSum,
                rateCount,
                passport,
           }
        }''';
    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['pets'] != null){
      final pets = petProfileFromShot(response['data']['pets']);
      var ret = List<PetPod>.generate(pets.length, (index){
        if (petIndex == index) {
          return PetPod(pet: pets[index], isSelected: true);
        }
        return PetPod(pet: pets[index],  isSelected: false);
      });
      return ret;
    }
    return List<PetPod>.empty();
  }catch (e){
    print(e);
    return List<PetPod>.empty();
  }
}

Future<List<PetProfile>>fetchOwnerPets() async{
  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final query = '''{
           pets(ownerId: "$uid"){
               _id,
                name,
                breed,
                isMale,
                birthdate,
                photoUrl,
                ownerId,
                createdAt,
                lastModified,
                vaccines,
                rateSum,
                rateCount,
                passport,
           }
        }''';
    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['pets'] != null){
      final pets = petProfileFromShot(response['data']['pets']);
      return pets;
    }
    return List<PetProfile>.empty();
  }catch (e){
    print("fetchOwnerPets: $e");
    return List<PetProfile>.empty();
  }
}


// TODO: OUTDATED FUNCTION - SHOULD NOT BE USED
// Future fetchResultedPets() async{
//
//   final uid = FirebaseAuth.instance.currentUser!.uid;
//   try{
//     // incorrect path
//     final petList = await dB.collection('pets').where('ownerId', isNotEqualTo: uid).get();
//     final pets = petProfileFromJson(petList);
//     final pods = List<PetPod>.generate(pets.length, (index){
//       return PetPod(pet: pets[index],  isSelected: false, foreign: true);
//     });
//     return pods;
//   }on PlatformException catch (e){
//     print(e);
//     return <PetProfile>[];
//   }
//
// }



Future<List<PetProfile>> fetchMatchesWithLimits(PetProfile pet, int limit, DateTime lastFetched) async{

  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final query = '''{
    pets(notOwnerId: "$uid", breed: "${pet.breed}", 
    skipTime: "${lastFetched.toIso8601String()}", limit: $limit, isMale: ${!pet.isMale}){
        _id,
        isMale,
        birthdate,
        breed,
        createdAt,
        rateCount,
        rateSum,
        photoUrl,
        ownerId,
        vaccines,
        lastModified,
        createdAt,
        passport,
        name,
        owner{
            location,
            type
        }
    }
}''';
    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['pets'] != null){
      return petProfileFromShot(response['data']['pets']);
    }
    return List<PetProfile>.empty();

  }catch (e){
    print('petMatchWithLimit: ${e}');
    return <PetProfile>[];
  }

}

List<PetPod> convertToPods(List<PetProfile> pets, bool foreign){
  return List<PetPod>.from(pets.map((e) => PetPod(pet: e, isSelected: false, foreign: foreign)));
}

Future updatePassport(String urlPath, PetPod pod) async{
  int i = -100;
  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (pod.pet.ownerId != uid) throw Exception('User not granted access');
    final query = '''mutation{
    editPet(id: "${pod.pet.id}", passport: "$urlPath",
    ownerId: "$uid")
  }''';
    final response = await sendGraphQLQuery(query);
    if (response != null
        && response['data']['editPet'] != null
        &&  response['data']['editPet'] == 1){

      i = 200;
    }
  }catch (e){
    print(e);
  }
  return i;
}

Future<List<MateRequest>> refreshMateRequests(DateTime lastSent, DateTime lastReceived) async{
  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final query = '''{
    mateRefresh(userId: "$uid", lastSent: "${lastSent.toIso8601String()}",
    lastReceived: "${lastReceived.toIso8601String()}"){
        _id,
        senderId,
        receiverId,
        senderPetId,
        receiverPetId,
        status,
        createdAt,
        lastModified
    }
}''';
    final response = await sendGraphQLQuery(query);

    if (response != null && response['data']['mateRefresh'] != null) {
      return mateRequestFromShot(response['data']['mateRefresh']);
    }

    return <MateRequest>[];
  }catch (e){
    if (kDebugMode) print('RefreshMateReq Err: $e');
    return <MateRequest>[];
  }

}


Future<List<MateRequest>> fetchOwnerPetRequests(String uid, DateTime lastFetched) async{
  try{


    final query = '''{
    mateRequests(targetUser: "$uid", skipTime: "${lastFetched.toIso8601String()}"){
        _id,
        senderId,
        receiverId,
        senderPetId,
        receiverPetId,
        status,
        createdAt,
        lastModified
    }
}''';
    final response = await sendGraphQLQuery(query);

    if (response != null && response['data']['mateRequests'] != null) {
      return mateRequestFromShot(response['data']['mateRequests']);
    }

    return <MateRequest>[];
  }catch (e){
    print("fetchOwnerPetRequests Error: $e");
    return <MateRequest>[];
  }
}


Future<MateRequest?> sendMateRequest(String sid, String rid, String spid, String rpid) async{
  final query = '''mutation{
    addMateRequest(
        senderId: "$sid",
        receiverId: "$rid",
        senderPetId: "$spid",
        receiverPetId: "$rpid",
    )
}''';

  final response = await sendGraphQLQuery(query);


  if (response != null && response['data']['error'] == null
      && response['data']['addMateRequest'] != null) {
    if (response['data']['addMateRequest']['acknowledged'] == true){

      final reqId = response['data']['addMateRequest']['insertedId'];
      final now = DateTime.now();

      MateRequest newRequest = singleMateRequestFromShot({
        "_id": reqId,
        "senderId": sid,
        "receiverId": rid,
        "senderPetId": spid,
        "receiverPetId": rpid,
        "status": 0,
        "createdAt": now.toIso8601String(),
        "lastModified": now.toIso8601String()
      });
      return newRequest;
    }
  }

  try{


  }catch (e){
    print(e);
    return null;
  }

}

Future<int> updateMateRequest(MateRequest req, int val) async{
  int i = -100;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  if ( (req.receiverId != uid) && (req.senderId != uid)) return -200;

  try{
    final query = '''mutation{
    updateMateRequest(
        id: "${req.id}",
        status: $val
    )
}''';

    final response = await sendGraphQLQuery(query);

    if (response != null && response['data']['updateMateRequest'] == 1){
      i = 200;
    }

  }catch (e){
    print(e);
  }
  return i;
}

//TODO:: REMOVE [NOT USED]
// Future fetchUserData(String uid) async{
//   try{
//     final query = '''{
//     user(id: $uid){
//         _id
//
//     }
// }''';
//     final response = await sendGraphQLQuery(query);
//     if (response )
//   }catch (e){
//     print(e);
//   }
// }


Future pickImage(BuildContext context, ImageSource src) async {
  var imageFile;
  try {
    final image = await ImagePicker().pickImage(source: src);
    if (image == null) {
      showSnackbar(context, 'Cancelled.');
      return null;
    }else{
      imageFile = io.File(image.path);
      return imageFile;
    }
  } on PlatformException catch (e) {
    // showSnackbar(context, e.toString());
    // img_src.value = 0;
    return null;
  }

}

Future compareFacial(io.File rawImage1, io.File rawImage2) async {

  Uint8List imagebytes = await rawImage1.readAsBytes(); //convert to bytes
  String data1 = base64.encode(imagebytes);
  imagebytes = await rawImage2.readAsBytes();
  String data2 = base64.encode(imagebytes);

  try {
    String body = json.encode({
      "encoded_image1": data1,
      "encoded_image2": data2
    });

    final uri = Uri.parse('https://faceapi.mxface.ai/api/v2/face/verify');
    final headers = {
      'SubscriptionKey': 'AVj9iM1dHULqhfxIXE-KGLhU8YBxb1121',
      io.HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.post(uri, headers: headers, body: body);
    print(response.body);
    final res = jsonDecode(response.body)['matchedFaces'][0]['confidence'];
    return res;
  } catch (e) {
    print('failed here');
   print(e);
   return 0;
  }
}

//TODO:: OUTDATED
void filterPetSearch() async{
  try{
    final resp = await SupabaseCredentials.supabaseClient.from('pets')
        .select('name')
        .or("and(birthdate.gte.2020-01-01,birthdate.lte.2023-01-01)").in_('breed', ['Yorkshire Terrier']).eq('isMale', false) as List<dynamic>;
    // print(resp);
  }catch (e){
    print(e);
  }
}

getUserCurrentLocation() async {
  await Geolocator.requestPermission().then((value){
  }).onError((error, stackTrace) async {
    await Geolocator.requestPermission();
    print("ERROR"+error.toString());
  });
  try{
    final loc = await Geolocator.getCurrentPosition();
    print('this loc: $loc');
    if (loc.latitude != 0.0 && loc.longitude != 0.0){
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble("long", loc.longitude);
      prefs.setDouble("lat", loc.latitude);

      try{
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final query = '''mutation{
                              editUser(
                                  id: "$uid",
                                  long: ${loc.longitude},
                                  lat: ${loc.latitude},
                                )
                              }''';

        final response = await sendGraphQLQuery(query);

        if (response != null && response['data']['editUser'] == 1){
          print('location updated');
        }
      }catch (e){
        print('loc update err: ${e}');
      }
    }
  }catch(e){
    print('loc: $e');
  }

  // return GeoLocation(loc.latitude, loc.longitude);
}

Future<bool> deleteRequestsFromServer(List<String> reqIds) async{
  try{
      final query = '''mutation{
                    deleteMateRequests(
                        ids: ${jsonEncode(reqIds)}
                    )
                }''';

      final response = await sendGraphQLQuery(query);
      if (response != null && response['data']['deleteMateRequests'] > 1){
        return true;
      }
      return false;

  }catch (e){
    print('deleteRequestsFromServer Error: ${e}');
    return false;
  }
}

Future<String> uploadAndStorePDF(String filePath) async {

  final pdfFile = io.File(filePath);
  try {
    Reference ref = FirebaseStorage.instance.ref().child('pdfs/${FieldValue.serverTimestamp()}');
    UploadTask uploadTask = ref.putFile(pdfFile, SettableMetadata(contentType: 'file/pdf'));

    TaskSnapshot snapshot = await uploadTask;

    String url = await snapshot.ref.getDownloadURL();
    print('done');
    return url;
  } catch (e) {
    print("exception!?@: " + e.toString());
    return "";
  }
}

Future<List<PetProfile>> getPetsWithIDs(List<String> ids) async{
  try{
    final query = '''{
    listOfPets(ids: ${jsonEncode(ids)}) {
      _id
      name
      breed
      isMale
      birthdate
      photoUrl
      ownerId
      createdAt
      lastModified
      vaccines
      rateSum
      rateCount
      passport
      owner{
          location,
          type
      }
    }
  }''';

    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['listOfPets'] != null){
      return petProfileFromShot(response['data']['listOfPets']);
    }
    return <PetProfile>[];
  }catch (e){
    print(e);
    return <PetProfile>[];
  }
}

Future<List<MateRequest>?> fetchPetsRelation(String ownerPetId, String petId) async{

  try{
    final query = '''{
    petRelation(firstPet: "$ownerPetId", secondPet: "$petId"){
        _id,
        senderId,
        receiverId,
        senderPetId,
        receiverPetId,
        status,
        createdAt,
        lastModified
    }
}''';
    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['petRelation'] != null) {
      return mateRequestFromShot(response['data']['petRelation']);
    }
    return null;

  }catch (e){
    if (kDebugMode) print('fetchPetsRealtion Error: $e');
    return null;
  }
}


Future<UserPod?> getPetOwner(String ownerId) async{

  try{
    final query = '''{
    user(id: "$ownerId") {
       _id,
      firstName,
      lastName,
      email,
      birthdate,
      isMale,
      country,
      city,
      location,
      type,
      verified,
      createdAt,
      lastModified,
      phone,
      photoUrl,
    }
  }''';

    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['user'] != null){
      return userPodFromShot(response['data']['user']);
    }
    return null;
  }catch (e){
    return null;
  }
}


Future<PetProfile?> getSinglePetWithId(String id) async{
  try{
    final query = '''{
    pet(ids: "$id") {
      _id
      name
      breed
      isMale
      birthdate
      photoUrl
      ownerId
      createdAt
      lastModified
      vaccines
      rateSum
      rateCount
      passport
      owner{
          location,
          type
      }
    }
  }''';

    final response = await sendGraphQLQuery(query);
    if (response != null && response['data']['pet'] != null){
      return singlePetProfileFromShot(response['data']['pet']);
    }
    return null;
  }catch (e){
    return null;
  }
}

Future<MapEntry<String, dynamic>> getSinglePetFriendList(String id) async{
 try{
   final doc = await dB.doc('$id/friends/ids').get();
   return MapEntry(id, List<String>.from(doc.data()!['list'].map((x) => x)));
 }catch (e){
   return MapEntry(id, null);
 }
}

Future<Map<String, List<String>>> getPetFriendsList(List<String> ids) async{
  Map<String, List<String>> resultMap = {};

  await Future.wait(ids.map((id) async {
    MapEntry<String, dynamic> entry = await getSinglePetFriendList(id);
    if (entry.value != null) {
      resultMap[entry.key] = List<String>.from(entry.value);
    }
  }));

  return resultMap;
}

// addNewPetFriend(MateRequest m, CacheBox box, {bool? server}){
//   final uid = FirebaseAuth.instance.currentUser!.uid;
//   if (uid == m.senderId){
//     box.addPetFriendList(m.senderPetId, m.receiverPetId);
//   }else{
//     box.addPetFriendList(m.receiverPetId, m.senderPetId);
//   }
//
//   if (server?? false) addNewMate(m.senderPetId, m.receiverPetId);
// }


addNewMate(String petId1, String petId2){

  dB.collection('$petId1/friends').doc('list').set({
    'ids': FieldValue.arrayUnion([petId2]),
    'lastModified': FieldValue.serverTimestamp()
  }, SetOptions(merge: true))
      .then((value) => print('Pet added to document list'))
      .catchError((error) => print('Failed to add pet: $error'));
  dB.collection('$petId2/friends').doc('list').set({
    'ids': FieldValue.arrayUnion([petId1]),
    'lastModified': FieldValue.serverTimestamp()
  }, SetOptions(merge: true))
      .then((value) => print('Pet added to document list'))
      .catchError((error) => print('Failed to add pet: $error'));
}
