import 'dart:async';
import 'dart:io' as io;
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

// Function to retry requests : retry(int, Future<>);
typedef Future<T> FutureGenerator<T>();

final dB = FirebaseFirestore.instance;

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
    final resp = await SupabaseCredentials.supabaseClient.from('breed').select('name,photoUrl') as List<dynamic>;
    final List<Breed> bList = breedFromJson(jsonEncode(resp));
    return bList;

  } catch (e) {
    return List<Breed>.empty();
  }finally{

  }
}
Future generateBreedPossibilities(String id) async{
  try {
    Map<String, String> headers = {
      'x-api-key': '7312afbd-ed2d-4fe2-b7d9-b66602ea58f7'
    };

    var url = Uri.parse('https://api.thedogapi.com/v1/images/${id}/analysis');

    var response = await http.get(url, headers: headers);
    final obj = petAnalysisFromJson(response.body);

    final breeds = await getBreedList(0);
    final List<String> names = <String>[];
    final matches = <Breed>[];
    for(Label label in obj[0].labels){
      names.add(label.name);
      for(Parent parent in label.parents){
        names.add(parent.name);
      }
    }

    for (Breed breed in breeds){
      for (String name in names){
        if (breed.name.toUpperCase().contains(name.toUpperCase())){
          if (!breed.name.toUpperCase().contains('DOG')
              && !breed.name.toUpperCase().contains('TERRIER')
              && !breed.name.toUpperCase().contains('PET')){
            matches.add(breed);
          }

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
        contentType: new MediaType("image", "jpeg"));

    request.files.add(multipartFile);
    request.fields['sub_id'] = 'betaTest_FETCH';

    var res = await request.send();
    var response = await http.Response.fromStream(res);

    if (response.body != null) {
      pRes = photoResponseFromJson(response.body);
      if (pRes.approved == 1) {
        return pRes;
      }

      return PhotoResponse(
          id: '-505',
          url: "Can't find a dog in photo",
          subId: '-11',
          originalFilename: '-11',
          pending: -1,
          approved: -1);
    }

    return PhotoResponse(
        id: '-503',
        url: 'No response received',
        subId: '-11',
        originalFilename: '-11',
        pending: -1,
        approved: -1);
  } catch (e) {
    return PhotoResponse(
        id: '-504',
        url: 'An error happened, retry process',
        subId: '-11',
        originalFilename: '-11',
        pending: -1,
        approved: -1);
  }
}

// add pet

Future addPet(String name, String dogBreed, bool isMale, DateTime petBirthDate, String photoUrl, String uid, List<dynamic> vaccines, String pdfUrl) async{
  int ret = -100;
  PetProfile? newPet;
  try{
    final query = await dB.collection('pets/$dogBreed/dogs').add({
      'name': name.capitalize(),
      'breed': dogBreed,
      'isMale': isMale,
      'birthdate': Timestamp.fromMillisecondsSinceEpoch(petBirthDate.millisecondsSinceEpoch),
      'photoUrl': photoUrl,
      'ownerId': uid,
      'verified': false,
      'ts': FieldValue.serverTimestamp(),
      'vaccines': vaccines,
      'passport': pdfUrl,
      'rateSum': 0,
      'rateCount': 0,
      'lastModified': FieldValue.serverTimestamp(),
    });
    final petData = await query.get();
    newPet = singlePetProfileFromShot(petData.data()!, petData.reference.path);
    ret = 200;
  } on FirebaseException catch (error) {
    print(error.message);
  }catch (e) {
    print(e);
  }

  return [ret, newPet];
}

Future incrementUserPetCount(String uid, int petCount) async{
  int ret = -100;
  try{
    await dB.collection('users').doc(uid).update({"petCount": petCount, "lastModified": FieldValue.serverTimestamp()});
    ret = 200;
  }on FirebaseException catch (e){
    print("incrementFunction: ${e.message}");
  }
  return ret;
}

Future editPet(String name, bool isMale, DateTime petBirthDate, List<dynamic> vaccines, String pid, String breed) async{
  int ret = -100;
  try{

    await dB.collection('pets/$breed/dogs').doc(pid).update({
      'name': name,
      'isMale': isMale ? true : false,
      'birthdate': petBirthDate,
      'vaccines': vaccines,
      'lastModified': FieldValue.serverTimestamp()
    });
    ret = 200;
  } on FirebaseException catch (error) {
    print(error.message);
  }catch (e){
    print(e);
  }

  return ret;

}
// POST request for adding new user
Future addUser(String userid, String email, String phone, String fname,
    String lname, String country, String? state, String? city, DateTime birthdate, bool isMale) async {
  var resp = 100;
  UserPod? newUser;
 try {
   Map<String, dynamic> userMap = {
     "email": email,
     "phone": phone,
     "firstName": fname.capitalize(),
     "lastName": lname.capitalize(),
     "country": country,
     "state": state?? "",
     "city": city?? "",
     "isMale": isMale,
     "birthdate": Timestamp.fromMillisecondsSinceEpoch(birthdate.millisecondsSinceEpoch),
     "location": {"latitude": 0.0, "longtitude": 0.0},
     "type": 0,
     "petCount": 0,
     "photoUrl": '',
     "ts": FieldValue.serverTimestamp(),
     "lastModified": FieldValue.serverTimestamp()
   };
   await dB.collection('users').doc(userid).set(userMap);
   final data = await dB.collection('users').doc(userid).get();
   newUser = userPodFromDoc(data);
   resp = 200;
 } on FirebaseException catch (error) {
   print("addUserError: ${error.message}");
 }catch (e){
   print('addUser unexpected: $e');
 }

 return [resp, newUser];

}

verifyUser()async{
  final uid = FirebaseAuth.instance.currentUser!.uid;
  try{

    upgradeUserPets(uid);
    await dB.collection('users').doc(uid).update({'type': 1, 'lastModified': FieldValue.serverTimestamp()});

  }on FirebaseException catch (e){
    print(e.message);
  }

}


upgradeUserPets(String uid) async{
  try{
    final resp = await SupabaseCredentials.supabaseClient.from('pets').select('id').eq('owner_id', uid) as List<dynamic>;

    for (Map pet in resp){
      await SupabaseCredentials.supabaseClient.from('pets').update({'verified': true}).eq('id', pet['id']);
    }
  }catch(e){
    print(e);
  }

}


Future checkPhoneAvailability(String phoneNumber) async {
  var ret = -100;

  try {
    final query = await dB.collection('users').where('phone', isEqualTo: phoneNumber).get();
    if (query.docs.isEmpty) ret = 200;
  } on PostgrestException catch (error) {
    print(error.message);

  } catch (error) {
    print("checkPAVail: ${error}");
    ret = 0;
  }finally{
    return ret;
  }


}

//check if user is registered in database
Future<List<dynamic>> userInDb(String email, String uid) async {
  usrState ret = usrState.connectionError;
  UserPod? pod;
  try{
   final userQuery = dB.collection('users').where("email", isEqualTo: email);
   final response = await userQuery.get();



   if (response.docs.isNotEmpty){
     if (response.docs.first.id == uid){
       pod = userPodFromShot(response);
       ret = usrState.completeUser;
     }else{
       ret = usrState.userAlreadyExists;
     }

   }else{
     ret = usrState.newUser;
   }


  }on FirebaseException catch (e){
   print("exception: " + e.message.toString());
  }

  return [ret, pod];
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
    final petList = await dB.collectionGroup('dogs').where('ownerId', isEqualTo: uid).get();
    final pets = petProfileFromShot(petList);
    var ret = List<PetPod>.generate(pets.length, (index){
      if (petIndex == index) {

        return PetPod(pet: pets[index], isSelected: true);
      }
        return PetPod(pet: pets[index],  isSelected: false);
    });
    return ret;
  }catch (e){
    print(e);
    return List<PetPod>.empty();
  }
}

Future<List<PetProfile>>fetchOwnerPets() async{
  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final petList = await dB.collectionGroup('dogs').where('ownerId', isEqualTo: uid).get();
    final pets = petProfileFromShot(petList);
    return pets;
  }catch (e){
    print(e);
    return List<PetProfile>.empty();
  }
}


// OUTDATED FUNCTION - SHOULD NOT BE USED
Future fetchResultedPets() async{

  final uid = FirebaseAuth.instance.currentUser!.uid;
  try{
    // incorrect path
    final petList = await dB.collection('pets').where('ownerId', isNotEqualTo: uid).get();
    final pets = petProfileFromShot(petList);
    final pods = List<PetPod>.generate(pets.length, (index){
      return PetPod(pet: pets[index],  isSelected: false, foreign: true);
    });
    return pods;
  }on PlatformException catch (e){
    print(e);
    return <PetProfile>[];
  }

}




Future<List<PetProfile>> fetchMatchesWithLimits(PetProfile pet, int limit, DateTime lastFetched) async{

  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final lfetched = Timestamp.fromMillisecondsSinceEpoch(lastFetched.millisecondsSinceEpoch);
    final petList = await dB.collection('pets/${pet.breed}/dogs')
        .where('isMale', isEqualTo: !pet.isMale)
        .where('lastModified', isGreaterThan: lfetched).limit(limit).get().then((value) => value.docs);
    petList.removeWhere((element) => element.data()['ownerId'] == uid);
    return petProfileFromDocs(petList);

  }on FirebaseException catch (e){
    print('petMatchWithLimit: ${e.message}');
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

    if (pod.pet.ownerId != uid){
      throw Exception('User not granted access');
    }

    await dB.collection('pets/${pod.pet.breed}/dogs').doc(pod.pet.id).update({'passport': urlPath});

    i = 200;
  }catch (e){
    print(e);
  }
  return i;
}
Future<List<MateRequest>> fetchPetsRelation(String uid, DateTime lastFetched) async{
  try{
    final ts = Timestamp.fromDate(lastFetched);
    final q1 = dB.collection('mateRequests')
        .where('senderId', isEqualTo: uid).where('lastModified', isGreaterThan: ts).get();
    final q2 = dB.collection('mateRequests')
        .where('receiverId', isEqualTo: uid).where('lastModified', isGreaterThan: ts).get();
    final resp = await Future.wait([q1, q2]);

    if (resp[0].docs.isNotEmpty || resp[1].docs.isNotEmpty){
      final requestItems = mateRequestFromShot(resp[0]);
      requestItems.addAll(mateRequestFromShot(resp[0]));
      return requestItems;
    }else{
      return <MateRequest>[];
    }
  }catch (e){
    print("fetchPetsRelationError: $e");
    return <MateRequest>[];
  }
}


Future<MateRequest?> sendMateRequest(String sid, String rid, String spid, String rpid) async{
  try{
    DateTime now = DateTime.now();
    final data = await dB.collection('mateRequests').add({
      "senderId": sid,
      "receiverId": rid,
      "senderPet": spid,
      "receiverPet": rpid,
      "status": 0,
      "ts": Timestamp.fromDate(now),
      "lastModified": Timestamp.fromDate(now)
    });
    print('Notification Sent: ${data.id}');
    MateRequest newRequest = singleMateRequestFromShot({
      "senderId": sid,
      "receiverId": rid,
      "senderPet": spid,
      "receiverPet": rpid,
      "status": 0,
      "ts": Timestamp.fromDate(now),
      "lastModified": Timestamp.fromDate(now)
    }, data.id);
    return newRequest;

  }catch (e){
    print(e);
    return null;
  }

}

Future updateMateRequest(String reqID, int val) async{
  int i = -100;
  Timestamp ts = Timestamp.fromDate(DateTime.now());
  try{
    await dB.collection('mateRequests').doc(reqID).update({
      'status': val,
      'lastModified': ts
    });
    i = 200;
  }catch (e){
    print(e);
  }
  return i;
}


Future fetchUserData(String uid) async{
  try{
    final data = await dB.collection('users').doc(uid).get();
    return data;
  }catch (e){
    print(e);
  }
}


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
    print('this loc: ${loc}');
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("long", loc.longitude);
    prefs.setDouble("lat", loc.latitude);

    if (loc != null){
      try{
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await dB.collection('users').doc(uid).update({"location": {"longtitude": loc.longitude, "latitude": loc.latitude}});
      }catch (e){
        print('loc update err: ${e}');
      }
    }
  }catch(e){
    print('loc: $e');
  }

  

  // return GeoLocation(loc.latitude, loc.longitude);
}

Future<bool> deleteRequestFromServer(String reqId) async{
  try{
    await dB.collection('mateRequests').doc(reqId).delete();
    return true;
  }on FirebaseException catch (e){
    print('requestDelete Error: ${e.message}');
    return false;
  }
}

Future<String> uploadAndStorePDF(io.File pdfFile) async {
  try {
    Reference ref = FirebaseStorage.instance.ref().child('pdfs/${FieldValue.serverTimestamp()}');
    UploadTask uploadTask = ref.putFile(pdfFile, SettableMetadata(contentType: 'file/pdf'));

    TaskSnapshot snapshot = await uploadTask;

    String url = await snapshot.ref.getDownloadURL();
    print('done');
    return url;
  } on FirebaseException catch (e) {
    print("exception!?@: " + e.message.toString());
    return "";
  }
}

List<List<String>> sublistIDs(List<String> ids){
  final length = ids.length;
  List<List<String>> idsOf10 = <List<String>>[];
  List<String> temp;
  for (int i= 0; i < length ; i+= 10) {
    temp = ids.sublist(i, min(i+10, length));
    idsOf10.add(temp);
  }
  return idsOf10;
}


Future<List<PetProfile>> getPetData(List<String> ids) async{
  try{
    final g = await dB.collectionGroup('dogs').where('__name__', whereIn: ids).get();
    return petProfileFromShot(g);
  }on FirebaseException catch (e){
    print('getPetData Error (${e.code}): ${e.message}');
    return <PetProfile>[];
  }

}

Future<List<PetProfile>> getPetsWithIDs(List<String> ids) async{
  List<List<String>> idsOf10;
  idsOf10 = sublistIDs(ids);
  List<PetProfile> newDocs = await Future.wait<List<PetProfile>>(idsOf10.map((e)
  => getPetData(e))).then((value)
  => value.expand((element) => element).toList());

  return newDocs;
}
