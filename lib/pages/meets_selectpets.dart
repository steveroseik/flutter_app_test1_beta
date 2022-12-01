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
  final int id;
  const SelectPets_Meets({Key? key, required this.criteria, required this.id}) : super(key: key);
  @override
  State<SelectPets_Meets> createState() => SelectPets_MeetsState();
}
class SelectPets_MeetsState extends State<SelectPets_Meets> {
  List<PetPod> petPods = <PetPod>[];
  List<PetPod> Podsinitial = <PetPod>[];
  final uid = FirebaseAuth.instance.currentUser!.uid; // user id
  var isLoading = true;
  List<int> fitsCrit=[];
  var attendees = 0;
  Future from_meet() async {
    try {
        final data = await SupabaseCredentials.supabaseClient
            .from('meets')
            .select('*').eq('id', widget.id) as List<dynamic>;

        for (var entry in data) {
          final map = Map.from(entry);
          attendees = map['no_of_attending'];
        }
      }
      on PostgrestException catch (error) {
        print(error.message);
      }
      catch (e) {
        print(e);
      }
  }

  Future add_to_meets(petIDs) async {

    attendees++;
    try {

    await SupabaseCredentials.supabaseClient.from('meets').update({
        'no_of_attending': attendees,
        'attending_pets': petIDs
      }).eq('id',widget.id);
    }
    on PostgrestException catch (error) {
      print(error.message);
    }
    catch (e) {
      print(e);
    }
  }

  int validate_pets(var x){
    if(widget.criteria[0]=='All breeds welcome') return 2;
  for (int i = 0;i < widget.criteria.length; i++){
    var z = widget.criteria[i];
      if(z==x){
         return 1;
       }
    }
  return 0;
}
  initUser() async {
    Podsinitial = await fetchPets(-1);
    for (int i = 0; i < Podsinitial.length;i++){
      var x = Podsinitial[i].pet.breed;
      var y = validate_pets(x);
      if(y == 1){ fitsCrit.add(1);break;}

      if(y==2){fitsCrit.add(2);break;}
    }
    for (int i = 0; i < fitsCrit.length; i++){
      if(fitsCrit[i]==1){
        petPods.add(Podsinitial[i]);
      }
      if(fitsCrit[i]==2){
        petPods = Podsinitial;
      }
    }
    setState(() {
      isLoading = false;
    });
    from_meet();
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
                  petIDs.isEmpty? showSnackbar(context, 'Please select at least one pet') :
                  add_to_meets(petIDs);
                  if(!petIDs.isEmpty){
                  explore_key.currentState
                      ?.pushNamed('/');
                  setState(() {});}
                }



              },
            ),

          )
        ]

        ))
    );}

}
