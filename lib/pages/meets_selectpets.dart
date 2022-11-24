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
  final List<dynamic> criteria;
  const SelectPets_Meets({Key? key, required this.criteria}) : super(key: key);
  @override
  State<SelectPets_Meets> createState() => SelectPets_MeetsState();
}
class SelectPets_MeetsState extends State<SelectPets_Meets> {
  List<PetPod> petPods = <PetPod>[];
  List<PetPod> Podsinitial = <PetPod>[];
  final uid = FirebaseAuth.instance.currentUser!.uid; // user id
  var isLoading = true;
  List<int> fitsCrit=[];
  var str ='';

  Future add_to_meet(var petIDs) async {
    /*try {
      await SupabaseCredentials.supabaseClient.from('meets').insert({
        'attending_pets': petIDs,
        'attending_users': ,
      });
    }

    catch (e) {
      print(e);
    }*/
  }
int validate_pets(var x){
  for (int i = 0;i < widget.criteria.length; i++){
    var z = widget.criteria[i];
    for (int j = 0; j < z.length; j++) {
      print(z[j]);
      if (z[j] != ',') {
        str = str + z[j];
      }
      if(z[j]==','){
        if(x == str){
          return 1;
        }
      str ='';
      }

    };
  }
  return 0;
}
  initUser() async {
    Podsinitial = await fetchPets(-1);
    for (int i = 0; i < Podsinitial.length;i++){
      var x = Podsinitial[i].pet.breed;
      fitsCrit.add(0);
      var y = validate_pets(x);
      if(y == 1){ fitsCrit.add(1);break;}
    }
    for (int i = 0; i < fitsCrit.length; i++){
      if(fitsCrit[i]==1){
        petPods.add(Podsinitial[i]);
      }
    }
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
                child: isLoading ? ShimmerOwnerPetCard() : petPods.length <= 0 ? Column(
                  children: [
                    Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                  ),
                  Text("None of your pets match the Meet criteria", style: TextStyle(fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.bold))],)
                    : ListView.builder(
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
                if(petPods.length > 0) {
                  add_to_meet(petIDs);
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
