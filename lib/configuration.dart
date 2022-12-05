import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';


enum NavPages{
  home,
  reminder,
  explore,
  breed,
  settings
}

// user states
enum usrState{
  completeUser,
  newUser,
  userAlreadyExists,
  connectionError
}

String details = 'My job requires moving to another country. '
    'I do not have the opportunity to take the cat with me. '
    'I am looking for good people who will shelter my pet';

Map vaccineFList = {
  "rabies": "Rabies",
  "parvoVirus": "Parvo Virus",
  "distemper": "Distemper",
  "hepatitis": "Hepatitis",
  "parainfluenza": "Parainfluenza",
  "dhpp1": "DHPP first shot",
  "dhpp2": "DHPP second shot",
  "dhpp3": "DHPP third shot",
};

List<Map> categories = [
  {"name": 'Food',"imagePath":'assets/images/Bone.png'},
  {"name": 'Health',"imagePath":'assets/images/Health.png'},
  {"name": 'Breeds',"imagePath":'assets/images/dog.png'},
  {"name": 'Training',"imagePath":'assets/images/Train.png'},
];


List<Map> navList = [
  {'icon': Icons.pets_rounded,'title': 'Adoption'},
  {'icon': Icons.markunread_mailbox_rounded,'title': 'Donation'},
  {'icon': Icons.add_rounded,'title': 'Add Pet'},
  {'icon': Icons.favorite_rounded,'title': 'Favorites'},
  {'icon': Icons.mail_rounded,'title': 'Messages'},
  {'icon': Icons.person,'title': 'Profile'},
];


final key32 = encrypt.Key.fromBase16('faec7d5b616e5e4ff6119894f3d367476f6480208114ef11defc0a8c51ea76b4');
final iv16 =  encrypt.IV.fromBase16('9219d32e744667b39f882f68112f9251');

String encryptString(String s) {


  final encrypter = encrypt.Encrypter(encrypt.AES(key32));

  final encrypted = encrypter.encrypt(s, iv: iv16);

  return encrypted.base16;

  // print(encrypted.base16);
  // print('\n');
  // print(decrypted);

}

class SupabaseCredentials{
  static const String APIKEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxzbXFvdWVvYmVic29ldWhpYWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjYyNTI3MjIsImV4cCI6MTk4MTgyODcyMn0.AD-WjgLJl21S0G9Dtlx7cwOT2bQM2a73n6ysNI9jrfA";
  static const String APIURL = "https://lsmqoueobebsoeuhiaaw.supabase.co";

  static SupabaseClient supabaseClient = SupabaseClient(APIURL, APIKEY);

}

Color primaryColor = const Color(0xff376565);

List<BoxShadow> shadowList = [
  const BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(10,10))
];

class Article{
  final String url;
  final String title;
  final String urlImage;
  final String type;

  const Article({
    required this.url,
    required this.title,
    required this.urlImage,
    required this.type,
  });
}

List<Article> articles =  [];
List<Article> health_articles =  [];
List<Article> food_articles =  [];
List<Article> training_articles =  [];
List<Article> breeds_articles =  [];


int getFileSize(File file){
  int sizeInBytes = file.lengthSync();
  int sizeInKb = sizeInBytes ~/ (1024);
  return sizeInKb;
}



