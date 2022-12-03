import 'dart:async';
import 'dart:typed_data';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui' as ui;
import 'package:flutter_app_test1/pages/meets_selectpets.dart';

import '../configuration.dart';


class SelectLocation extends StatefulWidget {

  const SelectLocation({Key? key}) : super(key: key);

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  Completer<GoogleMapController> _controller = Completer();
  final markers = List<Marker>.empty(growable: true);
  int id= 1;
  double lat=0,long=0;
  initMarkers() async{
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
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }
  @override
  void initState() {
    initUser();
    initMarkers();
    super.initState();
  }
  void initUser() async{
    final location = await getUserCurrentLocation();
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15, target: LatLng(location.latitude, location.longitude))));
    setState(() {});
  }

  Future getdata() async{
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*') as List<dynamic>;
      return data;
    }
    on PostgrestException catch (error) {
      print(error.message);
    }
    catch (e){
      print(e);
    }
  }
  Future initializeMarkers() async {
    int ret = -100;
    final  markers = List<Marker>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*') as List<dynamic>;

      for (var entry in data){
        final map = Map.from(entry);
        var x = map['longitude'];
        var y =map['latitude'];
        var id = map['id'];
        var title = map['title'];
        var address = map['address'];
        var website = map['website'];
        var phone = map['phone'];
        var thumbnail = map['thumbnail'];
        var type = map['type'];
        markers.add(
            Marker(
                markerId: MarkerId(id.toString()),
                position: LatLng(y, x),
                onTap: () {
                }
            ));
      }
      return markers;
    }
    on PostgrestException catch (error) {
      print(error.message);
    }
    catch (e){
      print(e);
    }
    return List<Marker>.empty();
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FETCH",
          style: TextStyle(
              color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold),        ),
        actions: [
          IconButton(
            onPressed: () async {
              final alldata = await getdata();

              // method to show the search bar
              GeoLocation selectedLocation = await showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate(alldata: alldata)

              );

              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  zoom: 15, target: LatLng(selectedLocation.Lat(), selectedLocation.Long()))));

            },
            icon: const Icon(Icons.search, color:Colors.black),
          )
        ],
        backgroundColor: Color(0xFFEEEEEE),

      ),

      body: Stack(
        children:
        [

          GoogleMap(
            onTap: (LatLng latLng) async{
              markers.clear();
              lat = latLng.latitude;
              long = latLng.longitude;
              final Uint8List customIcon = await getBytesFromAsset(
                  "assets/images/meetmarker.png", 150);
              Marker newmarker = Marker(

                  markerId: MarkerId(id.toString()),
              position: LatLng(lat, long),
              icon: BitmapDescriptor.fromBytes(customIcon),
              );

              markers.add(newmarker);
              id+=1;
              setState(() {});
              },
            onCameraMove: (position) {
            },
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
                target:LatLng(31.233334,30.033333),zoom: 15

              //    target:LatLng(80,30),zoom: 10.4746,

            ),

            markers: Set<Marker>.of(markers),

          ),
          Container(

            alignment:Alignment.bottomCenter,
            child:SizedBox(
              height: 45,
              width: 150,

            child: new ElevatedButton(
              onPressed:(){ Navigator.of(context).pop(GeoLocation(lat, long));

              setState(() {});
              },
            style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueGrey[600],
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0))),
            child: new Text(
            'Done',
            style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            ),



              ),
            ),


        ],

      ),


    );
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
