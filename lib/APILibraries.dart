import 'dart:async';

// import 'dart:html' as html;
import 'dart:io' as io;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

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
  try {
    Map<String, String> headers = {
      'x-api-key': '7312afbd-ed2d-4fe2-b7d9-b66602ea58f7'
    };
    var url = Uri.parse('https://api.thedogapi.com/v1/breeds');
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<Breed> bList = breedFromJson(response.body);
      print(response.body);
      return bList;
    } else {
      print('Response error with code ${response.statusCode}');
      return List<Breed>.empty();
    }
  } catch (e) {
    return List<Breed>.empty();
  }
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
        url: 'No response receieved',
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

// POST request for adding new user
Future<String> addUser(
    String userid,
    String email,
    int phone,
    String fname,
    String lname,
    String country,
    String city,
    String birthdate) async {
  var url = Uri.parse('https://fetch-api-skeleton.vercel.app/add_user');

  Map data = {
    "userid": userid,
    "email": email,
    "phone": phone,
    "firstname": fname,
    "lastname": lname,
    "country": country,
    "city": city,
    "birthdate": birthdate,
    "type": 0
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> checkEmailAvailability(TextEditingController email) async {
  var url = Uri.parse('https://fetch-api-skeleton.vercel.app/check_user_email');
  Map data = {'email': email.text};
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> checkPhoneAvailability(TextEditingController phoneNumber) async {
  var url = Uri.parse('https://fetch-api-skeleton.vercel.app/check_user_phone');
  Map data = {'phone': phoneNumber.text};
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> authenticate_user(String email, String password) async {
  var url = Uri.parse('https://fetch-api-skeleton.vercel.app/auth_user');
  Map data = {
    'email': email,
    'password': password,
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

//check if user is registered in database
Future<email_verif> userInDb(String email, String uid) async {
  email_verif ret = email_verif.connectionError;

  try {
    var url = Uri.parse('https://fetch-api-skeleton.vercel.app/auth_user');
    Map data = {
      'email': email,
      'uid': uid
    };
    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);

    final ans = userAvailCheckFromJson(response.body).code;
    if (ans == 200){
      ret = email_verif.completeUser;
    }else if (ans == 0){
      ret = email_verif.newUser;
    }else if (ans == -100){
      ret = email_verif.userAlreadyExists;
    }else{
      ret = email_verif.connectionError;
    }
  } catch (e) {
    print(e);
    var url = Uri.parse('https://fetch-api-skeleton.vercel.app/check_user_email');
    Map data = {
      'email': email,
    };
    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);

    final ans = userAvailCheckFromJson(response.body).code;
    if (ans == 200){
      ret = email_verif.completeUser;
    }else if (ans == 0){
      ret = email_verif.newUser;
    }else if (ans == -100){
      ret = email_verif.userAlreadyExists;
    }else{
      ret = email_verif.connectionError;
    }
  }finally{
    print(ret);
    return ret;
  }
}
