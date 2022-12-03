import 'dart:async';
import 'dart:convert';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/pages/selectmeetlocation.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../JsonObj.dart';
import '../configuration.dart';

class CreateMeet extends StatefulWidget {
  const CreateMeet({Key? key}) : super(key: key);

  @override
  State<CreateMeet> createState() => _CreateMeetState();
}

class Size {
  String size;

  Size({
    required this.size,
  });

  Map toJson() => {
    '&': size,
  };
}

class _CreateMeetState extends State<CreateMeet> {
  DateTime dateTime = DateTime.now();
  final markers = List<Marker>.empty(growable: true);
  List<PetPod> petPods = <PetPod>[];
  final uid = FirebaseAuth.instance.currentUser!.uid; // user id
  TimeOfDay _timeOfDay = TimeOfDay(hour: 12, minute: 00);
  Completer<GoogleMapController> _controller = Completer();
  double lat = 0, long = 0;
  TextEditingController meetName = TextEditingController();
  TextEditingController descName = TextEditingController();

  var isLoading = true;
  bool breedsLoading = true;
  var size = 0;
  List<Breed?> _selectedBreeds = [];
  List<Breed?> tempSelectedBreed = [];
  List<Size?> _selectedSizes = [];
  List<Size?> tempSelectedSizes = [];
  List<Breed> breeds = <Breed>[];
  static List<Size> sizes = [
    Size(size: "Small"),
    Size(size: "Medium"),
    Size(size: "Large"),
  ];

  late var _items =
  breeds.map((pet) => MultiSelectItem<Breed>(pet, pet.name)).toList();
  final size_items = sizes
      .map((petsize) => MultiSelectItem<Size>(petsize, petsize.size))
      .toList();

  initUser() async {
    petPods = await fetchPets(-1);

    breeds = await getBreedList(0);
    _items =
        breeds.map((pet) => MultiSelectItem<Breed>(pet, pet.name)).toList();
    setState(() {
      isLoading = false;
    });
    setState(() {
      breedsLoading = false;
    });

    final location = await getUserCurrentLocation();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15, target: LatLng(location.latitude, location.longitude))));
    setState(() {});
  }

  Future getsizes(sizelist) async {
    final breednames = List<String>.empty(growable: true);
    if (sizelist.contains('Medium')) print('yes');
    var x = sizelist[0];
    label:
    try {
      if (sizelist.length == 3) {
        breednames.add('All breeds welcome');
        break label;
      }
      if (sizelist.contains('Small')) {
        final data = await SupabaseCredentials.supabaseClient
            .from('breed')
            .select('*')
            .lte('height', 34) as List<dynamic>;
        for (var entry in data) {
          final map = Map.from(entry);
          breednames.add(map['name']);
        }
      }
      if (sizelist.contains('Medium')) {
        final data = await SupabaseCredentials.supabaseClient
            .from('breed')
            .select('*')
            .lte('height', 49)
            .gte('height', 35) as List<dynamic>;
        for (var entry in data) {
          final map = Map.from(entry);
          breednames.add(map['name']);
        }
      }

      if (sizelist.contains('Large')) {
        final data = await SupabaseCredentials.supabaseClient
            .from('breed')
            .select('*')
            .gte('height', 50) as List<dynamic>;
        for (var entry in data) {
          final map = Map.from(entry);
          breednames.add(map['name']);
        }
      }
    } on PostgrestException catch (error) {
      print(error.message);
    } catch (e) {}
    return breednames;
  }

  Future insert_breeds(double longitude, double latitude, String title,
      String descr, List<String> petIDs) async {
    String jsonString = jsonEncode(tempSelectedBreed);
    // String jsonSize = jsonEncode(tempSelectedSizes);
    List<String> attending_pets = [];
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
        'no_of_attending': 0,
        'breed_list': jsonString,
        'size': size,
        'attending_pets': attending_pets
      });
    } catch (e) {
      print(e);
    }
  }

  Future insert_sizes(double longitude, double latitude, String title,
      String descr, List<String> petIDs, breednames) async {
    if (breednames[0] != 'All breeds welcome') size = 1;
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
        'no_of_attending': 0,
        'size': size,
        'breed_list': breednames
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  initState() {
    initUser();
    initMarkers();
  }

  initMarkers() async {
    // BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(5, 5)),
    //     'assets/icon_male.png')
    //     .then((d) {
    //   customIcon = d;
    // });

    markers.clear();
    final data = await initializeMarkers();
    markers.addAll(data);
    setState(() {});
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  Future getdata() async {
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*') as List<dynamic>;
      return data;
    } on PostgrestException catch (error) {
      print(error.message);
    } catch (e) {
      print(e);
    }
  }

  Future initializeMarkers() async {
    int ret = -100;
    final markers = List<Marker>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*') as List<dynamic>;

      for (var entry in data) {
        final map = Map.from(entry);
        var x = map['longitude'];
        var y = map['latitude'];
        var id = map['id'];
        markers.add(Marker(
            markerId: MarkerId(id.toString()),
            position: LatLng(y, x),
            onTap: () {}));
      }
      return markers;
    } on PostgrestException catch (error) {
      print(error.message);
    } catch (e) {
      print(e);
    }
    return List<Marker>.empty();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: init_appBar(rootNav_key), // CHANGE KEY!!!
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15),
                child: Column(children: <Widget>[
                    Text("Create Meet",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 15,
                ),
                Align(
                  child: Text(
                      "A meet is an event where you get to meet our dog owner community!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                  height: height / 6,
                  width: width * 0.9,
                  padding: EdgeInsets.all(10),
                  child: isLoading
                      ? ShimmerOwnerPetCard()
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
                              } else
                                petPods[index].isSelected = true;
                            });
                          },
                          child: CustomPet(pod: petPods[index]),
                        );
                      })),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: TextFormField(
                  controller: meetName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: Colors.blueGrey, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(20)),
                    filled: true,
                    fillColor: CupertinoColors.extraLightBackgroundGray,
                    labelStyle: const TextStyle(color: Colors.grey),
                    labelText: 'Name your meet',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return null;
                    } else {
                      return 'Meet name empty';
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.only(bottom: 10, left: 5, top: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Breeds allowed (optional)",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontFamily: "poppins")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: breedsLoading
                    ? Container()
                    : Container(
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
                        buttonText: Text(
                          "Dog Breeds",
                          //style: TextStyle(color: Colors.grey)
                        ),
                        title: Text(
                          "Breeds",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.pink,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.all(Radius.circular(15)),
                          border: Border.all(
                            color: Colors.blueGrey,
                            width: 2,
                          ),
                        ),
                        items: _items,
                        onConfirm: (values) {
                          _selectedBreeds = values;
                          tempSelectedBreed = _selectedBreeds;
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
                            style: TextStyle(color: Colors.grey),
                          ))
                          : Container(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.only(bottom: 10, left: 5, top: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Dog sizes allowed (optional)",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontFamily: "poppins")),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
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
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          border: Border.all(
                            color: Colors.blueGrey,
                            width: 2,
                          ),
                        ),
                        buttonIcon: Icon(
                          Icons.add,
                          color: Colors.grey,
                        ),
                        searchHintStyle: TextStyle(
                          fontSize: 20,
                        ),
                        searchable: true,
                        buttonText: Text(
                          "Dog Sizes",
                          //style: TextStyle(color: Colors.grey)
                        ),
                        title: Text(
                          "Sizes",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.pink,
                          ),
                        ),
                        items: size_items,
                        onConfirm: (values) {
                          _selectedSizes = values;
                          tempSelectedSizes = _selectedSizes;
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
              ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, top: 20.0),
                    child: new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey[600],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      child: new Text(
                        'Select Meet Location',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        GeoLocation result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectLocation()),
                        );
                        lat = result.Lat();
                        long = result.Long();


//                        explore_key.currentState?.pushNamed('/select_location');
                        setState(() {});
                      },
                    ),
                  ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 20, left: 5, top: 20.0, right: 5),
                child: Row(
                  children: [
                    Text("When is your Meet?",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontFamily: "poppins")),
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      child: Text('Pick a date'),
                      onPressed: () {
                        showDatePicker();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: TextFormField(
                  controller: descName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: Colors.blueGrey, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(20)),
                    filled: true,
                    fillColor: CupertinoColors.extraLightBackgroundGray,
                    labelStyle: const TextStyle(color: Colors.grey),
                    labelText: 'Tell us more about your Meet',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey[600],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  child: new Text(
                    'Create Meet',
                    style: TextStyle(color: Colors.white, fontSize: 20),
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
            ]))
        ])));
  }

  validate(List<String> petIDs) async {
    String tempstring = jsonEncode(tempSelectedSizes);
    String stringsize = '';
    for (int i = 0; i < tempstring.length; i++) {
      if (tempstring[i] != '"' &&
          tempstring[i] != "[" &&
          tempstring[i] != "}" &&
          tempstring[i] != "&" &&
          tempstring[i] != ":" &&
          tempstring[i] != "]" &&
          tempstring[i] != "{") {
        stringsize = stringsize + tempstring[i];
      }
    }
    List<String> listsize = stringsize.split(',');
    final breednames = await getsizes(listsize);

    if (meetName.text != '') {
      if (descName.text != '') {
        if (!petIDs.isEmpty) {

          if (dateTime != DateTime.now()) {
            if (long != 0 || lat != 0) {
              if (tempSelectedBreed.length > 0)
                insert_breeds(long, lat, meetName.text, descName.text, petIDs);
              else
                insert_sizes(long, lat, meetName.text, descName.text,
                    petIDs, breednames);
              explore_key.currentState?.pushNamed('/');
              setState(() {});
              showNotification(context, 'You have created a Meet!');
            } else {
              showSnackbar(context, 'Please tap the Meet location on the map');
            }
          } else {
            showSnackbar(context, "Meet date cannot be today's date");
          }
        }
        else {
          showSnackbar(context, 'Please select at least one pet');
        }

      } else {
        showSnackbar(context, 'Please add a description to your Meet');
      }
    } else {
      showSnackbar(context, 'Please name your Meet');
    }
  }

  //DatePicker Widget
  void showDatePicker() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
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

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate({
    required this.alldata,
  });

  final alldata;
  final lat = List<double>.empty(growable: true);
  final long = List<double>.empty(growable: true);
  double longit = 0.0, latit = 0.0;

  Set<Marker> markersList = {};

  final placenames = List<String>.empty(growable: true);

  initState() {
    initUser();
  }

  initUser() async {
    lat.clear();
    long.clear();
    placenames.clear();
    final data = await getLocations();
    placenames.addAll(data);
  }

  Future getLocations() async {
    final placenames = List<String>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*') as List<dynamic>;

      for (var entry in data) {
        final map = Map.from(entry);
        var title = map['title'];
        placenames.add(title);
      }
    } on PostgrestException catch (error) {
      print(error.message);
    } catch (e) {
      print(e);
    }
    return placenames;
  }

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    initUser();
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in placenames) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in placenames) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return ListView.builder(
            itemCount: matchQuery.length,
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              return ListTile(
                onTap: () async {
                  //Here where I would like to go to new screen
                  int add = 0;
                  int addlong = 0;
                  var temp = '';
                  var z;
                  for (int i = 0; i < placenames.length; i++) {
                    if (placenames[i] == result) {
                      var plc = placenames[i];
                      print('res: $result');
                      print('places: $placenames');

                      z = i;
                      break;
                    }
                  }
                  for (var entry in alldata) {
                    final map = Map.from(entry);
                    lat.add(map['latitude']);
                    long.add(map['longitude']);
                  }
                  latit = lat[z];
                  longit = long[z];

                  setState(() {});
                  close(context, GeoLocation(latit, longit));
                },
                title: Text(result),
              );
            },
          );
        });
  }
}

