import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_test1/breedAdopt_main.dart';
import 'package:flutter_app_test1/explore_main.dart';
import 'package:flutter_app_test1/home_main.dart';
import 'package:flutter_app_test1/pages/explore.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
import 'package:flutter_app_test1/pages/verifyAccount.dart';
import 'package:flutter_app_test1/pages/settings.dart';
import 'package:flutter_app_test1/pages/home.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/settings_main.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataPass.dart';
import 'JsonObj.dart';




class mainApp extends StatefulWidget {
  UserPod? pod;
  mainApp({Key? key, this.pod}) : super(key: key);

  @override
  State<mainApp> createState() => _mainAppState();

}


class _mainAppState extends State<mainApp> {

  var _selectedIndex = 1;
  late Timer _timeTimer;
  List<Widget> _pages = [
    home_root(),
    BA_root(),
    explore_root(),
    SettingsMain()
  ];

  @override
  void initState() {
    if (widget.pod != null){
      setUserPets();

    }else{
      // initUser();
      print('null pod in main');
      // then setUserPets();
    }
    super.initState();
  }

  // To handle manual changes in device's time.
  void timeDetectionTimer(){
    const plusMinus = Duration(seconds: 5);
    int counter = 0;
    _timeTimer = Timer.periodic(const Duration(seconds: 10), (timer) async{
      counter++;
      if (counter > 10){
        _timeTimer.cancel();
      }
      final offset = await NTP.getNtpOffset(localTime: DateTime.now());
      print('offset: $offset');
      if (offset.abs() > plusMinus.inMilliseconds){
        print('==>CHANGED TIME!');
      }else{
        print('CORRECT');
      }
    });
  }

  void setUserPets() async{
    final prefs = await SharedPreferences.getInstance();
    if (widget.pod!.petCount > 0){
      prefs.setBool('hasPets', true);
    }else{
      prefs.setBool('hasPets', false);
    }
  }

  // current appflow doesn't need it
  void initUser() async{
    // create userPod item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: IndexedStack(
       index: _selectedIndex,
       children: _pages,
     ),
     bottomNavigationBar: BottomNavigationBar(
       currentIndex: _selectedIndex,
       showSelectedLabels: false,
       showUnselectedLabels: false,
       onTap: (value) {
         setState((){
           if (value == _selectedIndex){
             switch(value){
               case 0: UserNav_key.currentState?.popUntil((Route<dynamic> predicate) => predicate.isFirst);
               break;
               case 1: homeNav_key.currentState?.popUntil((Route<dynamic> predicate) => predicate.isFirst);
               break;
               case 2: explore_key.currentState?.popUntil((Route<dynamic> predicate) => predicate.isFirst);
               break;
               case 3: settingsNav_key.currentState?.popUntil((Route<dynamic> predicate) => predicate.isFirst);
               break;
             }
           }
           _selectedIndex = value;
         });

       },
       items: [
         BottomNavigationBarItem(icon: Icon(Icons.notes, color: _selectedIndex == 0 ? Colors.black : Colors.grey.shade500), label: 'Home'),
         // BottomNavigationBarItem(icon: Icon(Icons.timer, color: _selectedIndex == 1 ? Colors.black : Colors.grey.shade500), label: 'Health'),
         BottomNavigationBarItem(icon: Icon(Icons.pets,  color: _selectedIndex == 1 ? Colors.black : Colors.grey.shade500), label: 'Breed & Adopt'),
         BottomNavigationBarItem(icon: ImageIcon(AssetImage("assets/mapsIcon.png"), size: 25, color: _selectedIndex == 2 ? Colors.black : Colors.grey.shade500), label: 'Explore'),
         BottomNavigationBarItem(
             icon: Icon(Icons.settings, color: _selectedIndex == 3 ? Colors.black : Colors.grey.shade500), label: 'Settings'),
       ],
     ),
      );
  }
}
