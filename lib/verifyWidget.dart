import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



class VerifyPhoneWidget extends StatelessWidget {
  const VerifyPhoneWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: phoneNav_key,
      initialRoute:'/',
      onGenerateRoute: RouteGenerator.generateRoute_phone,
    );
  }
}
