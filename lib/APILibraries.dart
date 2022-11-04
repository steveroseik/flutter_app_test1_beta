import 'dart:async';
import 'dart:io' as io;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FETCH_wdgts.dart';

// Function to retry requests : retry(int, Future<>);
typedef Future<T> FutureGenerator<T>();

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
  int ret = -100;
  try {
    final resp = await SupabaseCredentials.supabaseClient.from('breed').select('name,photoUrl') as List<dynamic>;
    final List<Breed> bList = breedFromJson(jsonEncode(resp));
    ret = 200;
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

    var _res = await request.send();
    var response = await http.Response.fromStream(_res);

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

Future addPet(String name, dogBreed, bool isMale, String petBirthDate, String photoUrl, String uid, List<dynamic> vaccines) async{
  int ret = -100;
  try{

    final resp = await SupabaseCredentials.supabaseClient.from('pets').insert({
      'name': name,
      'breed': dogBreed,
      'isMale': isMale ? true : false,
      'birthdate': petBirthDate,
      'photo_url': photoUrl,
      'owner_id': uid,
      'ready': false,
      'created_at': DateTime.now().toIso8601String(),
      'vaccines': vaccines
    }).select('id').single() as Map;
    ret = 200;
  } on PostgrestException catch (error) {
    print(error.message);
  }catch (e){
    print(e);
  }finally{
    return ret;
  }

}

Future editPet(String name, bool isMale, String petBirthDate, List<dynamic> vaccines, String uid, String pid) async{
  int ret = -100;
  try{

    await SupabaseCredentials.supabaseClient.from('pets').update({
      'name': name,
      'isMale': isMale ? true : false,
      'birthdate': petBirthDate,
      'vaccines': vaccines
    }).eq('id', pid).eq('owner_id', uid);
    ret = 200;
  } on PostgrestException catch (error) {
    print(error.message);
  }catch (e){
    print(e);
  }finally{
    return ret;
  }

}
// POST request for adding new user
Future addUser(String userid, String email, int phone, String fname,
    String lname, String country, String city, String birthdate) async {
  var ret = -100;
 try {
   await SupabaseCredentials.supabaseClient.from('users').insert({
     "id": userid,
     "email": email,
     "phone": phone.toString(),
     "firstName": fname,
     "lastName": lname,
     "country": country,
     "city": city,
     "birthdate": birthdate,
     "long": 0.0,
     "lat": 0.0,
     "type": 0,
     "created_at": DateTime.now().toIso8601String(),

   });
   ret = 200;
 } on PostgrestException catch (error) {
   print(error.message);
 }catch (e){
   print(e);
 }finally{
   return ret;
 }

}

Future checkEmailAvailability(TextEditingController email) async {
  var ret = -100;

  try {
    final data = await SupabaseCredentials.supabaseClient
        .from('users')
        .select('firstName').eq('email', email.text) as List<dynamic>;

    // parse response
    for (var entry in data){
      entry = Map.from(entry);
    }

    if (data.isEmpty) ret = 200;

  } on PostgrestException catch (error) {
    print(error.message);

  } catch (error) {
    print('Unexpeted error occured');

  }finally{
    return ret;
  }
}

Future checkPhoneAvailability(TextEditingController phoneNumber) async {
  var ret = -100;

  try {
    final pNumber = int.parse(phoneNumber.text);
    final data = await SupabaseCredentials.supabaseClient
        .from('users')
        .select('*')
        .eq('phone', pNumber) as List<dynamic>;

    // parse response
    for (var entry in data){
      entry = Map.from(entry);
    }

    if (data.isEmpty) ret = 200;
  } on PostgrestException catch (error) {
    print(error.message);

  } catch (error) {
    print('Unexpeted error occured');

  }finally{
    return ret;
  }


}

//check if user is registered in database
Future<usrState> userInDb(String email, String uid) async {
  usrState ret = usrState.connectionError;
  var data = await SupabaseCredentials.supabaseClient
      .from('users')
      .select('id')
      .eq('email', email) as List<dynamic>;

  // parse response
  for (var entry in data){
    entry = Map.from(entry);
  }

  if (data.isNotEmpty) {
    if (data[0]['id'].toString() == uid) {
      ret = usrState.completeUser;
    } else {
      ret = usrState.userAlreadyExists;
    }
  } else {
    ret = usrState.newUser;
  }

  return ret;
}

// Future testingSupa() async{
//
//   final data = await SupabaseCredentials.supabaseClient.from('users').select('*').eq('phone', 1224363456) as List<dynamic>;
//
//   for (var entry in data) {
//     entry = Map.from(entry);
//   }
//
//   print(data);
//
// }

Future<String> uploadPhoto(io.File imgFile) async {
  late final ImgUploaded img;
  try{
    var url = Uri.parse('https://freeimage.host/api/1/upload?key=6d207e02198a847aa98d0a2a901485a5');
    var request = http.MultipartRequest('POST', url);

    var multipartFile = await http.MultipartFile.fromPath('source', imgFile.path,
        filename: basename(imgFile.path),
        contentType: new MediaType("image", "jpeg"));

    request.files.add(multipartFile);

    var _res = await request.send();
    var response = await http.Response.fromStream(_res);

    img = imgUploadedFromJson(response.body);

    if (img.statusCode != 200){
      return '-100';
    }
    return img.image.url;

  }catch (e){
    print(e);
    return '';
  }

}

Future<bool> fetchUserPets() async{

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final data = await SupabaseCredentials.supabaseClient.from('pets').select('id').eq('owner_id', uid) as List<dynamic>;

  final prefs = await SharedPreferences.getInstance();

  if (data.isNotEmpty){
    prefs.setBool('hasPets', true);
    return true;
  }else{
    if (prefs.get('hasPets') != null){
      prefs.setBool('hasPets', false);
    }
    return false;
  }
}

Future<List<PetPod>>fetchPets(int petIndex) async{
  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final petList = await SupabaseCredentials.supabaseClient.from('pets').select('*').eq('owner_id', uid ) as List<dynamic>;
    final pets = petProfileFromJson(jsonEncode(petList));
    var ret = List<PetPod>.generate(pets.length, (index){
      if (petIndex == index) {

        return PetPod(pets[index], true);
      }
        return PetPod(pets[index], false);
    });
    return ret;
  }catch (e){
    print(e);
    return List<PetPod>.empty();
  }
}

Future<List<PetProfile>> getPetMatch() async{
  try{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final petList = await SupabaseCredentials.supabaseClient.from('pets').select('*') as List<dynamic>;
    final pets = petProfileFromJson(jsonEncode(petList));

    return pets;
  }catch (e){
    print(e);
    return List<PetProfile>.empty();
  }
}

Future updateVaccine(String petId, List<dynamic> data) async{
  int i = -100;
 try{
   await SupabaseCredentials.supabaseClient.from('pets').update({'vaccines': data}).eq('id', petId);
   i = 200;
  }catch (e){
     print(e);
   }
   return i;
}

Future sendMateRequest(String sid, String rid, String spid, String rpid) async{
  int i = -100;
  try{
    final data = await SupabaseCredentials.supabaseClient.from('mate_requests')
        .insert({
      "sender_id": sid,
      "receiver_id": rid,
      "sender_pet": spid,
      "receiver_pet": rpid,
      "status": 0
    }).single();
    i = 200;
  }catch (e){
    print(e);
  }
  return i;
}

Future<List<MateItem>> fetchPetRequests(String uid) async{

  try{
    final data = await SupabaseCredentials.supabaseClient.from('mate_requests').select('*').eq('receiver_id', uid).eq('status', 0) as List<dynamic>;
    late List<MateItem> pets = List.empty(growable: true);
    for (dynamic p in data){
      Map map = Map.from(p);
      final pet = singlePetProfileFromJson(jsonEncode(await SupabaseCredentials.supabaseClient.from('pets').select('*').eq('id', map['sender_pet']).single()));
      final item = MateItem(pet, map['receiver_pet'], map['id']);
      pets.add(item);
    }
    return pets;
  }catch (e){
    print(e);
  }
return List<MateItem>.empty();


}

Future updateMateRequest(String reqID, int val) async{
  int i = -100;
  try{
    await SupabaseCredentials.supabaseClient.from('mate_requests').update({"status": val}).eq('id', reqID);
    i = 200;
  }catch (e){
    print(e);
  }
  return i;
}

Future fetchUserData(String uid) async{
  try{
    final data = await SupabaseCredentials.supabaseClient.from('users').select('*').eq('id', uid).single();
    print(jsonEncode(data));

  }catch (e){
    print(e);
  }
}
