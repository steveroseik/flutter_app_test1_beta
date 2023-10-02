import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../FETCH_wdgts.dart';


final PanelController _pc = PanelController();
// Elevated Card
class breedSearchPage extends StatefulWidget {
  final List<PetPod> ownerPets;
  List<MateRequest> petRequests;
  List<MateRequest> sentRequests;
  breedSearchPage({Key? key, required this.ownerPets, required this.petRequests, required this.sentRequests}) : super(key: key);

  @override
  State<breedSearchPage> createState() => _breedSearchPageState();
}



class _breedSearchPageState extends State<breedSearchPage> {
  final breedKey = GlobalKey<DropdownSearchState<Breed>>();
  List<Gender> genders = <Gender>[];
  List<PetPod> pets = <PetPod>[];
  List<String> breedList = <String>[];

  int gender = 2;
  int ageMin=0;
  int ageMax=20;
  bool allPets = false;
  bool distanceASC = false;

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
  var age_r = RangeValues(0, 20);
  var distance_r = RangeValues(0, 50);
  String _genderValue = 'Male';

  late Timer _sortTimer;
  int sortTrials = 5;
  bool isLoading = true;

  initPets() async{

    // List<PetPod> pods = await fetchResultedPets();
    // startSorting(pods);
    // breedList.addAll(await fetchBreedNameList());
  }

  generateDistances() async{
    List<String> userIDs = List<String>.generate(pets.length, (index) {
      return pets[index].pet.ownerId;
    });

    try{
      final resp = await SupabaseCredentials.supabaseClient.from('users').select('id,lat,long').in_('id', userIDs) as List<dynamic>;
    }catch (e){
      print(e);
    }



  }

  matchRequest(String petID){
    List<MateRequest> allList = <MateRequest>[];
    allList.addAll(widget.petRequests);
    allList.addAll(widget.sentRequests);

    try{
      return allList.firstWhere((e) {
        return e.senderPetId == petID || e.receiverPetId == petID;

      });
    }catch (e){
      return null;
    }


  }

  startSorting(List<PetPod> pods){
    sortTrials = 5;
    const time = const Duration(seconds: 2);
    _sortTimer = Timer.periodic(time, (Timer time) {
      int locAvail = 0;
      for (PetPod pod in pods){
        if (pod.hasLocation){
          locAvail = -1;
        }
      }
      if (sortTrials == 0) {
        setState(() {
        pets.addAll(pods);
        isLoading = false;
        time.cancel();
      });
      }else{
        if (locAvail != -1){
          pods.sort((a,b) => a.distance
              .compareTo(b.distance));
          if (distanceASC) {
            pods = pods.reversed.toList();
          }
          setState(() {
            pets.addAll(pods);
            isLoading = false;
            time.cancel();
          });
        }else{
          sortTrials--;
        }
      }


    });
  }

  refreshResults(List<dynamic> newList){
    setState(() {
      pets.clear();
      isLoading = true;
    });
    // FIX ME ASAP
    // final encoded = petProfileFromJson(jsonEncode(newList));
    // final pods = List<PetPod>.generate(encoded.length, (index){
    //   return PetPod(encoded[index], false, GeoLocation(0.0, 0.0), 1);
    // });
    // sortTrials = 5;
    // startSorting(pods);
  }




  @override
  void initState() {
    genders.add(Gender('male', Icons.male, false));
    genders.add(Gender('female', Icons.female, false));
    genders.add(Gender('all', Icons.trip_origin, true));
    initPets();
    super.initState();
    // _pc.open();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Material(
      child: SlidingUpPanel(
        backdropEnabled: true,
        minHeight: 50,
        maxHeight: width*1.15,
        controller: _pc,

        panel: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Breed',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 7*width*0.005,
                            fontWeight: FontWeight.w800),
                      ),
                      Spacer(),
                      Text(
                        'Select All',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 5*width*0.005,
                            fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 5,),
                      FlutterSwitch(
                        width: width * 0.11,
                        height: height * 0.025,
                        toggleSize: 15 * width * 0.003,
                        activeColor: Colors.greenAccent.shade400,
                        inactiveColor: Colors.grey.shade400,
                        onToggle: (v) {
                          if (v == true) {
                            allPets = true;
                          } else{
                            allPets = false;
                          }
                          setState(() {

                          });
                          print(allPets);
                        }, value: allPets,
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: IgnorePointer(
                    ignoring: allPets ? true : false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: BreedSearchMultiWidget(formKey: breedKey)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Age',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 7*width*0.005,
                        fontWeight: FontWeight.w800,),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white54
                    ),
                    child: Row(

                      children: [
                        Text('${ageMin}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey.shade900
                        ),),
                        Expanded(
                          child: RangeSlider(
                            values: age_r,
                            activeColor: Colors.blueGrey.shade900,
                            inactiveColor: Colors.blueGrey.shade100,
                            onChanged: (RangeValues n) {
                              setState((){
                                age_r = n;
                                ageMin = n.start.toInt();
                                ageMax = n.end.toInt();

                              });
                            },
                            min: 0,
                            max: 20,
                            divisions: 20,
                            labels:
                                RangeLabels('${age_r.start.ceil()} Years', '${age_r.end.ceil()} Years'),
                          ),
                        ),
                        Text('${ageMax}',style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey.shade900
                        ),),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Distance',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 7*width*0.005,
                          fontWeight: FontWeight.w800,),
                      ),
                    ),
                    SizedBox(width: 20,),
                    Text(
                      'Nearest',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 5*width*0.005,
                        fontWeight: FontWeight.w600,),
                    ),
                    SizedBox(width: 5,),
                    FlutterSwitch(
                      width: width * 0.11,
                      height: height * 0.025,
                      toggleSize: 15 * width * 0.003,
                      activeColor: Colors.blueGrey.shade700,
                      inactiveColor:  Colors.blueGrey.shade700,
                      onToggle: (v) {
                        distanceASC = !distanceASC;
                        setState(() {

                        });
                        print(allPets);
                      }, value: distanceASC,
                    ),
                    SizedBox(width: 5,),
                    Text(
                      'Farthest',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 5*width*0.005,
                        fontWeight: FontWeight.w600,),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Text(
                  'Gender ',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 10,),
                Container(
                  height: 50,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: genders.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              for (var gender in genders) {
                                gender.isSelected = false;
                              }
                              genders[index].isSelected = true;
                              gender = index;
                            });
                          },
                          child: miniCustomRadio(genders[index]),
                        );
                      }),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async{
                          if (_pc.isAttached) {
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            final dateMin = DateTime(DateTime.now().year - ageMax, DateTime.now().month, DateTime.now().day);
                            final dateMax = DateTime(DateTime.now().year - ageMin, DateTime.now().month, DateTime.now().day);
                            try{
                              if (allPets){
                                if (gender == 2){
                                  final resp = await SupabaseCredentials.supabaseClient.from('pets')
                                      .select('*').gt('birthdate', dateMin).lt('birthdate', dateMax).neq('owner_id', uid);
                                  refreshResults(resp);
                                }else{
                                  final isMale = gender == 0 ? true : false;
                                  final resp = await SupabaseCredentials.supabaseClient.from('pets')
                                      .select('*').eq('isMale', isMale).gt('birthdate', dateMin).lt('birthdate', dateMax).neq('owner_id', uid);
                                  refreshResults(resp);
                                }
                              }else{
                                final sBreeds = breedKey.currentState!.getSelectedItems;

                                if (sBreeds.isEmpty){
                                  if (gender == 2){
                                    final resp = await SupabaseCredentials.supabaseClient.from('pets')
                                        .select('*').gt('birthdate', dateMin).lt('birthdate', dateMax).neq('owner_id', uid).neq('owner_id', uid);
                                    refreshResults(resp);
                                  }else{
                                    final isMale = gender == 0 ? true : false;
                                    final resp = await SupabaseCredentials.supabaseClient.from('pets')
                                        .select('*').eq('isMale', isMale).gt('birthdate', dateMin).lt('birthdate', dateMax).neq('owner_id', uid).neq('owner_id', uid);
                                    refreshResults(resp);
                                  }
                                }else{
                                  List<String> criteriaList = <String>[];
                                  criteriaList = List<String>.generate(sBreeds.length, (index) => sBreeds[index].name);
                                  if (gender == 2){
                                    final resp = await SupabaseCredentials.supabaseClient.from('pets')
                                        .select('*').in_('breed', criteriaList).gt('birthdate', dateMin).lt('birthdate', dateMax).neq('owner_id', uid);
                                    refreshResults(resp);
                                  }else{
                                    final isMale = gender == 0 ? true : false;
                                    final resp = await SupabaseCredentials.supabaseClient.from('pets')
                                        .select('*').in_('breed', criteriaList).eq('isMale', isMale).gt('birthdate', dateMin).lt('birthdate', dateMax).neq('owner_id', uid);
                                    refreshResults(resp);
                                  }
                                }

                              }
                            }catch (e){
                              print(e);
                            }
                            // initPets();
                            _pc.close();
                          } else {}
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.blueGrey.shade900,
                        ),
                        child: Text(
                          'Apply Filter',
                          style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        collapsed: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Colors.blueGrey.shade100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(30, 15, 30, 0),
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.black54,
                  )),
              Text("Search Filters", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600, fontSize: width*0.025),)
            ],
          ),
        ),
        body: Scaffold(
          appBar: init_appBar(homeNav_key),
          body: isLoading ?  GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1/1.3,
              mainAxisSpacing: 10.0,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey.shade300
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        child: Row(
                          children: [
                            Shimmer( gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                                child: CircleAvatar(
                                  radius: 30,
                                ),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Shimmer( gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                                    child: Container(
                                      height: 10,
                                      width: width*0.15,
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20), color: Colors.white),

                                    )),
                                Shimmer( gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                                    child: Container(
                                      height: 10,
                                      width: width*0.1,
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20), color: Colors.white),

                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      Shimmer( gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                          child: Container(
                            height: 10,
                            width: width*0.3,
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), color: Colors.white),

                          )),
                      Shimmer( gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                          child: Container(
                            height: 10,
                            width: 50,
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), color: Colors.white),

                          )),
                      Spacer(),
                      Center(
                        child: Shimmer( gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                            child: Container(
                              height: 20,
                              width: width*0.2,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), color: Colors.white),

                            )),
                      )
                    ],
                  ),
                ),
              );
            },
          ) : pets.length == 0 ? Text(
            "No available pets",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: width*0.04,
                fontWeight: FontWeight.w500,color: CupertinoColors.systemGrey2),
            textAlign: TextAlign.center,
          ) : Container(
            height: height*0.72,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1/1.3,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: pets.length,
                itemBuilder: (context, index) {

                  return GestureDetector(
                    onTap: (){
                      MateRequest req = matchRequest(pets[index].pet.id);
                      if (req.status == -1){
                        homeNav_key.currentState?.pushNamed('/petProfile', arguments: [pets[index], req]).then((value) {
                          if (req.status != -1){
                            widget.sentRequests.add(req);
                          }
                        });
                      }else{
                        homeNav_key.currentState?.pushNamed('/petProfile', arguments: [pets[index], req]);
                      }


                    },
                      child: PetView(profile: pets[index], ownerPets: widget.ownerPets, rootPets: pets));
                },
              ),
            ),
          ),
        ),
        borderRadius: radius,
      ),
    );
  }
}
