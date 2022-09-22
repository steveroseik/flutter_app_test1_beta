import 'package:flutter/material.dart';
import 'package:flutter_app_test1/breedAdopt_main.dart';
import 'package:flutter_app_test1/home_main.dart';
import 'package:flutter_app_test1/pages/explore.dart';
import 'package:flutter_app_test1/pages/reminder.dart';
import 'package:flutter_app_test1/pages/settings.dart';
import 'package:flutter_app_test1/pages/home.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_test1/configuration.dart';

var _selectedIndex = ValueNotifier<int>(0);



class mainApp extends StatefulWidget {
  const mainApp({Key? key}) : super(key: key);

  @override
  State<mainApp> createState() => _mainAppState();

  // Change page viewed index
  void update_nav_index(int i){
      _selectedIndex.value = i;
  }

}


class _mainAppState extends State<mainApp> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (BuildContext context, int value, Widget? child){

          switch(value){
            case 0: return home_root();
            case 1: return ReminderPage();
            case 2: return MapsPage();
            case 3: return BA_root();
            case 4: return SettingsPage();
            default: return home_root();
          }

        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (BuildContext context, int value, Widget? child){
          return BottomNavigationBar(
            key: AppNav_key,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex.value,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (value) {
              _selectedIndex.value = value;
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home, color: value == 0 ? Colors.black : Colors.grey.shade500), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.health_and_safety, color: value == 1 ? Colors.black : Colors.grey.shade500), label: 'Health'),
              BottomNavigationBarItem(icon: Icon(Icons.map, color: value == 2 ? Colors.black : Colors.grey.shade500), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.pets,  color: value == 3 ? Colors.black : Colors.grey.shade500), label: 'Breed & Adopt'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: value == 4 ? Colors.black : Colors.grey.shade500), label: 'Settings'),
            ],
          );
        },
      ),
    );
  }
}
