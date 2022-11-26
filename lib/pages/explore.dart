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


class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  TextEditingController _searchController = TextEditingController();
  final markers = List<Marker>.empty(growable: true);
  CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();
  Completer<GoogleMapController> _controller = Completer();
  String firstname='', lastname='';
  //var pet_list = List<String>;
  List<PetPod> petPods = <PetPod>[];
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
  initMeets() async {
    markers.clear();
    final data = await display_meets();
    markers.addAll(data);
    final uid = await FirebaseAuth.instance.currentUser!.uid;
    setState(() {});
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
  shortcutMarkers(String type) async{
    markers.clear();
    if(type == "Veterinarian"){
      final data = await display_vets(type);
      markers.addAll(data);
    }
    if(type == "Pet store"){
      final data = await display_stores(type);
      markers.addAll(data);
    }
    if(type == "Dog park"){
      final data = await display_parks(type);
      markers.addAll(data);
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: init_appBar(rootNav_key),// CHANGE KEY!!!
      body: Stack(
        children:
        [
          GoogleMap(
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              _customInfoWindowController.googleMapController = controller;
            },
               myLocationButtonEnabled: false,
              myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
                target:LatLng(31.233334,30.033333),zoom: 5.4746

              //    target:LatLng(80,30),zoom: 10.4746,

            ),

            markers: Set<Marker>.of(markers),

          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 212,
            width: 510,
            offset: 50,
          ),
          TextFormField (
            controller: _searchController,
            onChanged: (value){
              print(value);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Search',
            ),),

          Padding(
            padding: const EdgeInsets.fromLTRB(30.0,50.0,30.0,50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: new Text('Vets',style: TextStyle(
                      color: Colors.black),
                  ),
                  onPressed: ()  =>  shortcutMarkers('Veterinarian'),
                ),
                new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),child: new Text('Parks',style: TextStyle(
                    color: Colors.black),
                ),
                  onPressed: ()  =>  shortcutMarkers('Dog park'),
                ),
                new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),child: new Text('Pet Stores',style: TextStyle(
                    color: Colors.black),
                ),
                  onPressed: ()  =>  shortcutMarkers('Pet store'),
                ),
                new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: new Text('Meets',style: TextStyle(
                      color: Colors.black),
                  ),
                  onPressed: ()=>{
                   initMeets(),
                  }
                ),
              ],
            ),
          ),

          Container(

            alignment:Alignment.bottomCenter,
            child:SizedBox(
              height: 45,
              width: 150,

              child: TextButton(
                  onPressed:(){
                    explore_key.currentState
                        ?.pushNamed('/create_meet');
                    setState(() {});
                  },
                  child: Text("+",style: TextStyle(fontSize: 25, color:Colors.white)),
                  style:ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),

                    shape:MaterialStateProperty.all<CircleBorder>(

                        CircleBorder(
                            side: BorderSide(color:Colors.red)
                        )
                    ),

                  )

              ),
            ),
          ),
        ],

      ),


    );
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
  Future find_host(String host_id) async {
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('users')
          .select('*').eq('id', host_id) as List<dynamic>;

      for (var entry in data) {
        final map = Map.from(entry);
        firstname = map['firstName'];
        lastname = map['lastName'];
}
    }
    on PostgrestException catch (error) {
      print(error.message);
    }
    catch (e) {
      print(e);
    }
  }
  Future find_host_pets(var pet, List<String>pet_names)async{
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('pets')
          .select('name').eq('id', pet) as List<dynamic>;

      for (var entry in data) {
        final map = Map.from(entry);
        pet_names.add(map['name']);
      }
    }
    on PostgrestException catch (error) {
      print(error.message);
    }
    catch (e) {
      print(e);
    }
  }
find_criteria( breed_list, breed_test, criteria){
    print('breeds: $breed_list');
    var str;
  for(int i =0;i<breed_list.length;i++){
    str = breed_list[i];
    for(int i=0;i < str.length;i++){
      if(i>16 && str[i]!='"' && str[i]!='}'){
        breed_test = breed_test + str[i];
      }
    }
    if(i<breed_list.length-1)
      breed_test=breed_test+',';
  }
  criteria.add(breed_test);
  print('criteria: $criteria');
  return criteria;
}
  Future display_meets() async {
    final Uint8List customIcon = await getBytesFromAsset(
        "assets/images/meetmarker.png", 150);
    var breed_list;
    var breed_test ='';
    int ret = -100;
    final  markers = List<Marker>.empty(growable: true);
    try {

      final data = await SupabaseCredentials.supabaseClient
          .from('meets')
          .select('*') as List<dynamic>;

      for (var entry in data){
        final map = Map.from(entry);
        var x = map['longitude'];
        var y =map['latitude'];
        var id = map['id'];
        var title = map['title'];
        var description = map['description'];
        var datetime = map['date'];
        var host_id = map['host_id'];
       var pet_list = map['host_pets'];
       breed_list = map['breed_list'];
        find_host(host_id);
        List<String> criteria = [];
         criteria = find_criteria(breed_list,breed_test,criteria);
        print('returned: $criteria');
        List<String>pet_names = [];
        for(int i =0; i <pet_list.length;i++){
          var pet = pet_list[i];
          find_host_pets(pet, pet_names);
        }

        markers.add(
            Marker(

                markerId: MarkerId(id.toString()),
                position: LatLng(y, x),
                icon: BitmapDescriptor.fromBytes(customIcon),
                onTap: () {
                  _customInfoWindowController.addInfoWindow!(
                      Container(
                        decoration:BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                        title,
                                      style:(
                                      TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:22,
                                      )
                                      )
                                    ),
                                    Text(
                                        'Host',
                                        style:(
                                            TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:18,
                                            )
                                        )
                                    ),
                                    Text(
                                      firstname+' '+lastname+'\nHost pets: $pet_names',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                        'About',
                                        style:(
                                            TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:18,
                                            )
                                        )
                                    ),
                                    Text(
                                        description+'\nBreeds allowed: $criteria',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Date: '+datetime,
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),

                                     new ElevatedButton(onPressed: (){
                                       explore_key.currentState
                                           ?.pushNamed('/select_pets', arguments: criteria);
                                       setState(() {});
                                        },
                                        child:new Text('Join Meet')
                                    ),
                                  ],
                                ),
                              ),
                            ]),



                      ), LatLng(y, x)
                  );
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
                  _customInfoWindowController.addInfoWindow!(
                      Container(
                        decoration:BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width:510,
                                height:70,
                                decoration: BoxDecoration(

                                  image:DecorationImage(
                                      image:NetworkImage(thumbnail),

                                      fit:BoxFit.fitWidth,
                                      filterQuality: FilterQuality.high
                                  ),  ),),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      title+'\n'+type+'\n'+address
                                          +'\n'+phone+'\n'+website,
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                        child:SizedBox(
                                          height: 30,

                                          child: new ElevatedButton(onPressed: (){
                                            explore_key.currentState
                                                ?.pushNamed('/location_review');

                                          },
                                              child:new Text('Rate and Review')

                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ]),



                      ), LatLng(y, x)
                  );
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
  Future Display(String type) async {
        final  markers = List<Marker>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*').eq('type', type) as List<dynamic>;

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

                  _customInfoWindowController.addInfoWindow!(
                      Container(
                        decoration:BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width:510,
                                height:70,
                                decoration: BoxDecoration(

                                  image:DecorationImage(
                                      image:NetworkImage(thumbnail),

                                      fit:BoxFit.fitWidth,
                                      filterQuality: FilterQuality.high
                                  ),  ),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      title+'\n'+type+'\n'+address
                                          +'\n'+phone+'\n'+website+'\n',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                        child:SizedBox(
                                          height: 30,

                                          child: new ElevatedButton(onPressed: (){
                                            explore_key.currentState
                                                ?.pushNamed('/location_review');

                                          },
                                              child:new Text('Rate and Review')

                                          ),
                                        )),

                                  ],
                                ),
                              ),
                            ]),



                      ), LatLng(y, x)
                  );
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
  Future display_parks(String type) async {

    final Uint8List customIcon = await getBytesFromAsset(
        "assets/images/parkmarker.png", 150);

    final  markers = List<Marker>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*').eq('type', type) as List<dynamic>;

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
                icon: BitmapDescriptor.fromBytes(customIcon),
                onTap: () {

                  _customInfoWindowController.addInfoWindow!(
                      Container(
                        decoration:BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width:510,
                                height:70,
                                decoration: BoxDecoration(

                                  image:DecorationImage(
                                      image:NetworkImage(thumbnail),

                                      fit:BoxFit.fitWidth,
                                      filterQuality: FilterQuality.high
                                  ),  ),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      title+'\n'+type+'\n'+address
                                          +'\n'+phone+'\n'+website+'\n',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                        child:SizedBox(
                                          height: 30,

                                          child: new ElevatedButton(onPressed: (){
                                            explore_key.currentState
                                                ?.pushNamed('/location_review');

                                          },
                                              child:new Text('Rate and Review')

                                          ),
                                        )),

                                  ],
                                ),
                              ),
                            ]),



                      ), LatLng(y, x)
                  );
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
  Future display_stores(String type) async {

    final Uint8List customIcon = await getBytesFromAsset(
        "assets/images/petstoremarker.png", 150);

    final  markers = List<Marker>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*').eq('type', type) as List<dynamic>;

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
                icon: BitmapDescriptor.fromBytes(customIcon),
                onTap: () {

                  _customInfoWindowController.addInfoWindow!(
                      Container(
                        decoration:BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width:510,
                                height:70,
                                decoration: BoxDecoration(

                                  image:DecorationImage(
                                      image:NetworkImage(thumbnail),

                                      fit:BoxFit.fitWidth,
                                      filterQuality: FilterQuality.high
                                  ),  ),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      title+'\n'+type+'\n'+address
                                          +'\n'+phone+'\n'+website+'\n',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                        child:SizedBox(
                                          height: 30,

                                          child: new ElevatedButton(onPressed: (){
                                            explore_key.currentState
                                                ?.pushNamed('/location_review');

                                          },
                                              child:new Text('Rate and Review')

                                          ),
                                        )),

                                  ],
                                ),
                              ),
                            ]),



                      ), LatLng(y, x)
                  );
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
  Future display_vets(String type) async {

    final Uint8List customIcon = await getBytesFromAsset(
        "assets/images/vetmarker.png", 150);

    final  markers = List<Marker>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*').eq('type', type) as List<dynamic>;

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
                icon: BitmapDescriptor.fromBytes(customIcon),
                onTap: () {

                  _customInfoWindowController.addInfoWindow!(
                      Container(
                        decoration:BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width:510,
                                height:70,
                                decoration: BoxDecoration(

                                  image:DecorationImage(
                                      image:NetworkImage(thumbnail),

                                      fit:BoxFit.fitWidth,
                                      filterQuality: FilterQuality.high
                                  ),  ),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      title+'\n'+type+'\n'+address
                                          +'\n'+phone+'\n'+website+'\n',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                        child:SizedBox(
                                          height: 30,

                                          child: new ElevatedButton(onPressed: (){
                                            explore_key.currentState
                                                ?.pushNamed('/location_review');

                                          },
                                              child:new Text('Rate and Review')

                                          ),
                                        )),

                                  ],
                                ),
                              ),
                            ]),



                      ), LatLng(y, x)
                  );
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
}



