import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../APILibraries.dart';
import '../routesGenerator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map userData = Map<String, dynamic>();
  List<Marker> markers = <Marker>[];
  Completer<GoogleMapController> _controller = Completer();

  initUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    userData = await fetchUserData(uid);
    final prefs = await SharedPreferences.getInstance();
    double? long = prefs.getDouble('long');
    double? lat = prefs.getDouble('lat');
    if (long != null && lat != null){
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          zoom: 15,target: LatLng(lat, long))));
      setState(() {});
    }

  }
  @override
  void initState() {
    initUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            elevation: 8,
            shadowColor: Colors.cyanAccent[70],
            title: const Text(
              "FETCH",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            leadingWidth: 0,
            backgroundColor: Colors.white70,
            actions: const []),
        body: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .3,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.elliptical(
                                MediaQuery.of(context).size.width * 0.5, 100.0),
                            bottomRight: Radius.elliptical(
                                MediaQuery.of(context).size.width * 0.5, 100.0),
                          ),
                          color: Colors.blue[200],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Stack(
                        children: [],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage:
                            AssetImage('assets/images/Avatar.png'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 15),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    userData == ''
                        ? ''
                        : '${userData['firstName']} ${userData['lastName']}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          shape: const BeveledRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(3))),
                        ),
                        onPressed: () async {
                          settingsNav_key.currentState
                              ?.pushNamed('/editProfile', arguments: userData);
                        },
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width - 100,
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
                      markers: Set<Marker>.of(this.markers),
                      initialCameraPosition: CameraPosition(
                          target:LatLng(31.233334,30.033333),zoom: 13.4746),
                      onMapCreated: (GoogleMapController controller){
                        _controller.complete(controller);
                      },
                    ),
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              shape: const BeveledRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
                            ),
                            onPressed: () async {
                              settingsNav_key.currentState?.pushNamed(
                                  '/editPass',
                                  arguments: userData);
                            },
                            child: const Text('Change Email',
                                style: TextStyle(
                                  fontSize: 15,
                                )))),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              shape: const BeveledRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
                            ),
                            onPressed: ()  {

                            },
                            child: const Text('Change Password',
                                style: TextStyle(
                                  fontSize: 15,
                                ))))
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: const BeveledRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(3))),
                      ),
                      onPressed: ()  async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.clear();
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text('Logout',
                          style: TextStyle(
                            fontSize: 15,
                          ))))
            ],
          ),
        ),
      ),
    );
  }
}