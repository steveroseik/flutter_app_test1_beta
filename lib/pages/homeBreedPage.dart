import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../FETCH_wdgts.dart';
import '../routesGenerator.dart';

class HomeBreedPage extends StatefulWidget {
  const HomeBreedPage({Key? key}) : super(key: key);

  @override
  State<HomeBreedPage> createState() => _HomeBreedPageState();
}

class _HomeBreedPageState extends State<HomeBreedPage> {


  var isLoading = true;
  // if user has no pets he is forced to add at least one pet
  usrHasPets() async{
    final prefs = await SharedPreferences.getInstance();
    if (prefs.get('hasPets') == null) {
      BA_key.currentState?.pushNamedAndRemoveUntil('/add_pet', (Route<dynamic> route) => false);
    }

    setState((){
      isLoading = false;
    });

  }
  late Future<List<PetPod>> petPods;
  late PetPod selectedPet;

  @override
  void initState() {
    petPods = fetchPets();
    usrHasPets();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return isLoading ? LoadingPage() : Scaffold(
      appBar: init_appBar(BA_key),
      body: Column(
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                child: Text('Your Pets',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    )),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width-10,
                height: height/5,
                padding: EdgeInsets.all(10),
                child: PetCard(petPods: petPods),
              ),
            ],
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
        label: Text('add pet'),
        icon: Icon(Icons.add),
        onPressed: () {
          BA_key.currentState?.pushNamed('/add_pet');
        },
      )
    );
  }
}
