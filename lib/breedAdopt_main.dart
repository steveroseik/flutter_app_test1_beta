import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataPass.dart';

class BA_root extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    final cacheBox = DataPassWidget.of(context);
    return Navigator(
      key: homeNav_key,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute_BA,
    );
  }
  // MaterialApp
}