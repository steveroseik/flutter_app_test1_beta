import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';



class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: init_appBar(rootNav_key), // CHANGE KEY!!!
    body: Column(

    )
    );
  }
}
