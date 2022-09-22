import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';

class home_root extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return Navigator(
        key: UserNav_key,
        initialRoute:'/',
        onGenerateRoute: RouteGenerator.generateRoute_user,
    );
  }
  // MaterialApp
}