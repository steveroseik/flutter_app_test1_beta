import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/mainApp.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



class LoginWidget extends StatelessWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: rootNav_key,
      initialRoute:'/login',
      onGenerateRoute: RouteGenerator.generateRoute_main,
    );
  }
}
