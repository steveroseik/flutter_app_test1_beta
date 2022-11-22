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

class CreateMeet extends StatefulWidget {

  const CreateMeet({Key? key}) : super(key: key);
  @override
  State<CreateMeet> createState() => _CreateMeetState();
}
class Breed{
  int id;
  String breed;
  Breed({
    required this.id,
     required this.breed,
  });
  Map toJson() => {
    'id': id,
    'breed': breed,
  };
}

class Size{
  int id;
  String size;
  Size({
    required this.id,
    required this.size,
  });
  Map toJson() => {
    'id': id,
    'size': size,
  };
}
class _CreateMeetState extends State<CreateMeet> {
  DateTime dateTime = DateTime.now();
  List<PetPod> petPods = <PetPod>[];
  final uid = FirebaseAuth.instance.currentUser!.uid; // user id
  TimeOfDay _timeOfDay = TimeOfDay(hour: 12, minute: 00);
  Completer<GoogleMapController> _controller = Completer();
  double lat = 0,
      long = 0;
  String name = '',
      description = '';
  var isLoading = true;
  List<Breed?> _selectedBreeds = [];
  List<Breed?> tempSelectedBreed = [];
  List<Size?> _selectedSizes = [];
  List<Size?> tempSelectedSizes = [];
  static List<Breed> breeds = [
    Breed(id:0,breed: "All"),
    Breed(id:1,breed: "Golden"),
    Breed(id:2,breed: "German"),

  ];
  static List<Size> sizes = [
    Size(id:0,size: "All"),
    Size(id:1,size: "Small"),
    Size(id:2,size: "Medium"),
    Size(id:3,size: "Large"),
  ];
  final _items = breeds
      .map((pet) => MultiSelectItem<Breed>(pet, pet.breed))
      .toList();
  final size_items = sizes
      .map((petsize) => MultiSelectItem<Size>(petsize, petsize.size))
      .toList();
  initUser() async {
    petPods = await fetchPets(-1);
    setState(() {
      isLoading = false;
    });
    final location = await getUserCurrentLocation();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15, target: LatLng(location.latitude, location.longitude))));
    setState(() {});
  }

  Future insert(double longitude, double latitude, String title, String descr, List<String> petIDs) async {
     String jsonString = jsonEncode(tempSelectedBreed);
    try {
        final timestamp = dateTime.toIso8601String();
        await SupabaseCredentials.supabaseClient.from('meets').insert({
          'longitude': longitude,
          'latitude': latitude,
          'title': title,
          'description': descr,
          'date': timestamp,
          'host_pets': petIDs,
          'host_id': uid,
          'breed_list': tempSelectedBreed
        });
      }

    catch (e) {
      print(e);
    }
  }

  @override
  initState() {
    initUser();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error,
        stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
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
              Text("Create Meet", style: TextStyle(fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
              ),
              Text(
                  "A meet is an event where you get to meet our dog owner community!",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
              ),
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
                padding: const EdgeInsets.only(bottom: 20.0),
              ),
              Text("What would you like to call your Meet?",
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              SizedBox(
                child: TextField(
                  onChanged: (value) {
                    name = value;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Meet Name',
                  ),
                ),

              ),
              Padding(
                padding: const EdgeInsets.only(bottom:10,top: 20.0),

            child:  Text("Would you like to limit your Meet to a few breeds?",
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
              Container(
                child: Column(
                  children: <Widget>[
                    MultiSelectBottomSheetField<Breed?>(
                      initialChildSize: 0.7,
                      maxChildSize: 0.95,
                      listType: MultiSelectListType.CHIP,
                      checkColor: Colors.grey,
                      selectedColor: Colors.grey,
                      selectedItemsTextStyle: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                      unselectedColor: Colors.greenAccent[200],
                      buttonIcon: Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                      searchHintStyle: TextStyle(
                        fontSize: 20,
                      ),
                      searchable: true,
                      buttonText: Text("Dog Breeds"),
                      title: Text(
                        "Breeds",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.pink,
                        ),
                      ),                      items: _items,
                      onConfirm: (values) {
                        _selectedBreeds=values;
                        tempSelectedBreed=_selectedBreeds;
                        },
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (value) {
                          setState(() {
                            _selectedBreeds.remove(value);
                          });
},
                      ),
                    ),
                    _selectedBreeds == null || _selectedBreeds.isEmpty
                        ? Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "None selected",
                          style: TextStyle(color: Colors.black54),
                        ))
                        : Container(),
                  ],
                ),
              ),Padding(
                padding: const EdgeInsets.only(bottom:10,top: 20.0),

                child:  Text("What size dogs are allowed?",
                    style: TextStyle(fontSize: 20, color: Colors.black)),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    MultiSelectBottomSheetField<Size?>(
                      initialChildSize: 0.7,
                      maxChildSize: 0.95,
                      listType: MultiSelectListType.CHIP,
                      checkColor: Colors.grey,
                      selectedColor: Colors.grey,
                      selectedItemsTextStyle: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                      unselectedColor: Colors.greenAccent[200],
                      buttonIcon: Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                      searchHintStyle: TextStyle(
                        fontSize: 20,
                      ),
                      searchable: true,
                      buttonText: Text("Dog Sizes"),
                      title: Text(
                        "Sizes",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.pink,
                        ),
                      ),
                      items: size_items,
                      onConfirm: (values) {
                        _selectedSizes=values;
                        tempSelectedSizes=_selectedSizes;
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (value) {
                          setState(() {
                            _selectedSizes.remove(value);
                          });
                        },
                      ),
                    ),
                    _selectedSizes == null || _selectedSizes.isEmpty
                        ? Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "None selected",
                          style: TextStyle(color: Colors.black54),
                        ))
                        : Container(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
              ),
              Text("Where would you like to Meet? Tap the exact location",
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              Center(
                child: Container(
                  height: 150,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width - 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),

                    child: GoogleMap(
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(31.233334, 30.033333),
                            zoom: 13.4746),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        onTap: (LatLng latLng) {
                          lat = latLng.latitude;
                          long = latLng.longitude;
                        }
                    ),
                  ),
                ),
              ),

// option to add in coordinates or select location
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
              ),
              Text("When do you want to Meet?",
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: Text('Pick a date'),
                    onPressed: () {
                      showDatePicker();
                    },
                  ),
                  //    Text(
                  //      _timeOfDay.format(context).toString(),
                  //      style: TextStyle(fontSize: 50),
                  //    ),

                ],

              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
              ),

              Text("Tell us more about your Meet",
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              SizedBox(
                child: TextField(
                  onChanged: (value) {
                    description = value;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Meet Description',
                  ),
                ),

              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),

                  child: new Text('Create Meet', style: TextStyle(
                      color: Colors.black),
                  ),
                  onPressed: () {
                    List<String> petIDs = <String>[];
                    for (var entry in petPods) {
                      if (entry.isSelected == true) {
                        petIDs.add(entry.pet.id);
                      }
                    }

                    validate(petIDs);
                  },
                ),

              )
            ])
        ));
  }

  void validate(List<String> petIDs) {
    if (name != '') {
      if (description != '') {
        if (!petIDs.isEmpty) {
          if (dateTime != DateTime.now()) {
            if (long != 0 || lat != 0) {
              insert(long, lat, name, description, petIDs);
              explore_key.currentState
                  ?.pushNamed('/');
              setState(() {});
            }
            else {
              showSnackbar(context, 'Please tap the Meet location on the map');
            }
          }
          else {
            showSnackbar(context, "Meet date cannot be today's date");
          }
        }
        else {
          showSnackbar(context, 'Please select at least one pet');
        }
      }
      else {
        showSnackbar(context, 'Please add a description to your Meet');
      }
    }
    else {
      showSnackbar(context, 'Please name your Meet');
    }
  }

  //DatePicker Widget
  void showDatePicker() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery
                .of(context)
                .copyWith()
                .size
                .height * 0.25,
            color: Colors.white,
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    onDateTimeChanged: (value) {
                      setState(() {
                        dateTime = value;
                      });
                    },
                    initialDateTime: DateTime.now(),
                  ),
                ),
              ],
            ),
          );
        });
  }

}
