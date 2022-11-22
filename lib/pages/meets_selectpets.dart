import 'dart:async';
import 'dart:convert';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../configuration.dart';

class SelectPets_Meets extends StatefulWidget {

  const SelectPets_Meets({Key? key}) : super(key: key);
  @override
  State<SelectPets_Meets> createState() => SelectPets_MeetsState();
}
class SelectPets_MeetsState extends State<SelectPets_Meets> {
  List<PetPod> petPods = <PetPod>[];
  final uid = FirebaseAuth.instance.currentUser!.uid; // user id
  var isLoading = true;

  initUser() async {
    petPods = await fetchPets(-1);
    setState(() {
      isLoading = false;
    });
  }
  @override
    initState() {
      initUser();
    }



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    final height = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
        appBar: init_appBar(rootNav_key), // CHANGE KEY!!!
        body: SingleChildScrollView(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
          ),
          Text("Select one or more dogs to join Meet", style: TextStyle(fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.bold)),
          Container(
            height: height / 6,
          width: width * 0.9,
          padding: EdgeInsets.all(10),
          child: isLoading ? ShimmerOwnerPetCard() : ListView.builder(
          scrollDirection: Axis.horizontal,
        shrinkWrap: true,
          itemCount: petPods.length,
          itemBuilder: (context, index) {
          return InkWell(
          onTap: () {
          setState(() {
          if (petPods[index].isSelected == true) {
          petPods[index].isSelected = false;
          }
          else
          petPods[index].isSelected = true;
          });
          },
          child: CustomPet(
          pod: petPods[index]),
          );
          })
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: new ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              child: new Text('Done', style: TextStyle(
                  color: Colors.black),
              ),
              onPressed: () {
                List<String> petIDs = <String>[];
                for (var entry in petPods) {
                  if (entry.isSelected == true) {
                    petIDs.add(entry.pet.id);
                  }
                }
                explore_key.currentState
                    ?.pushNamed('/');
                setState(() {});

              },
            ),

          )
        ]

        ))
    );}

}
