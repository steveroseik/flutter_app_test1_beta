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




class mainApp extends StatefulWidget {
  const mainApp({Key? key}) : super(key: key);

  @override
  State<mainApp> createState() => _mainAppState();

  // Change page viewed index
  // void update_nav_index(int i){
  //     _selectedIndex = i;
  // }

}


class _mainAppState extends State<mainApp> {

  var _selectedIndex = 0;
  List<Widget> _pages = [
  home_root(),
  ReminderPage(),
  MapsPage(),
  BA_root(),
  SettingsPage()];

  @override
  void initState() {

    super.initState();
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
            _selectedIndex = value;
          });

        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.black : Colors.grey.shade500), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety, color: _selectedIndex == 1 ? Colors.black : Colors.grey.shade500), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.map, color: _selectedIndex == 2 ? Colors.black : Colors.grey.shade500), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.pets,  color: _selectedIndex == 3 ? Colors.black : Colors.grey.shade500), label: 'Breed & Adopt'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings, color: _selectedIndex == 4 ? Colors.black : Colors.grey.shade500), label: 'Settings'),
        ],
      ),
    );
  }
}
