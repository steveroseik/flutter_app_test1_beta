import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsMain extends StatelessWidget{



  @override
  Widget build(BuildContext context){
    return Navigator(
      key: settingsNav_key,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute_settings,
    );
  }
// MaterialApp
}