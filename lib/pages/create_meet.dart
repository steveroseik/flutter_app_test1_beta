import 'dart:async';

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

import '../configuration.dart';

class CreateMeet extends StatefulWidget {

  const CreateMeet({Key? key}) : super(key: key);
  @override
  State<CreateMeet> createState() => _CreateMeetState();
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
    try {
      final timestamp = dateTime.toIso8601String();
      await SupabaseCredentials.supabaseClient.from('meets').insert({
        'longitude': longitude,
        'latitude': latitude,
        'title': title,
        'description': descr,
        'date': timestamp,
        'host_pets': petIDs,
        'host_id':uid
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
              Text("Create Meet", style: TextStyle(fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
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
              Text("Would you like to limit your Meet to a specific breed?",
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              // dropdown menu
              Text("Where would you like to Meet?",
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
                padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 50.0),
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
