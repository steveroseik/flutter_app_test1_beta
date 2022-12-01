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
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Search');
  final uid = FirebaseAuth.instance.currentUser!.uid;

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
  shortcutMarkers(String type) async{


      markers.clear();
    final data = await Display(type);

    markers.addAll(data);

    setState(() {});
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
                target:LatLng(31.233334,30.033333),zoom: 15

              //    target:LatLng(80,30),zoom: 10.4746,

            ),

            markers: Set<Marker>.of(markers),

          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 290,
            width: 200,
            offset: 50,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(30.0,0.0,30.0,50.0),
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

  int isJoined(attending_pets, joined_meet, petPods, host_id)  {
    if(host_id==uid) return -1;
    if(attending_pets==null) return 0;
    for (int i = 0;i< petPods.length;i++) {
      var temp = petPods[i].pet.id;
      for(int j = 0; j < attending_pets.length;j++) {
        if (temp == attending_pets[j]) {
          joined_meet = 1;
        }
      }
    }
    return joined_meet;
  }
  Future display_meets() async {
    final Uint8List customIcon = await getBytesFromAsset(
        "assets/images/meetmarker.png", 150);
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
       var attendees = map['no_of_attending'];
       var attending_pets = map['attending_pets'];
       var criteria = map['breed_list'];
        var joined_meet = 0;
        var size = map['size'];
        List<PetPod> petPods = <PetPod>[];
        petPods = await fetchPets(-1);
       joined_meet = isJoined(attending_pets, joined_meet,petPods, host_id);
        find_host(host_id);
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
                        height: 150,
                        width: 100,
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
                                    Container(
                                        width: 135.0,
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                    child:Stack(
                                        children:[
                                          Container(
                                              alignment: Alignment.topCenter,
                                      child:Text(
                                        'Host',
                                        style:(
                                            TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:18,
                                            )
                                        )
                                    )),
                                    Text(
                                      '\n $firstname'+' '+lastname+'\nHost pets: $pet_names',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    )])),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 15.0),
                                    ),
                                    Container(
                                        width: 140.0,
                                        height: 85.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                        child:Stack(
                                            children:[
                                              Column(
                                                  children:[
                                                    Container(
                                                        alignment: Alignment.center,

                                                        child:Text(
                                                      'About',
                                                      style:(
                                                          TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize:18,
                                                          )
                                                      )
                                                  )),


                                              Text(
                                                description+'\nAttending: $attendees owners',
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
                                              'Date: $datetime',
                                              style:
                                              Theme
                                                  .of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                color: Colors.black,
                                              ),
                                            ),
                                              ])])),
                                    size==0?Text(
                                      'Breeds allowed: $criteria',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ):
                                    Column(
                                     children: [
                                       Padding(
                                       padding: const EdgeInsets.only(bottom: 13.0),
                                     ),

                                    Container(

                                      // alignment:Alignment.bottomCenter,
                                      child:SizedBox(
                                        height: 30,
                                        width: 200,

                                        child: TextButton(
                                            onPressed:(){
                                              print('criteria: $criteria');
                                              showModalBottomSheet(
                                                  backgroundColor: Colors.transparent,
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder: (builder){

                                                    final height = MediaQuery
                                                        .of(context)
                                                        .size
                                                        .height;
                                                    final width = MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width;

                                                    return Container(
                                                        height: height * 0.5,
                                                        child: Column(
                                                        children: [
                                                        Container(
                                                            width: width*0.8,
                                                            padding: EdgeInsets.all(20),
                                                    decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(25),
                                                    color: Colors.black.withOpacity(0.8)
                                                    ),
                                                            child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                                Container(
                                                                height: 250,
                                                             child:ListView.builder(
                                                            itemCount: criteria.length,
                                                              itemBuilder: (context, index) {
                                                               var result = criteria[index];
                                                                return ListTile(
                                                                  title: Text(result,style: TextStyle(fontSize: 13.5, color:Colors.white)),
                                                                );
                                                              },
                                                            ))
                                                              ]
                                                        )

                                                        )
                                                        ]));});

                                            },
                                            child: Text("Click to see allowed breeds",style: TextStyle(fontSize: 13.5, color:Colors.white)),
                                            style:ButtonStyle(
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(18.0),
                                                      side: BorderSide(color: Colors.white)
                                                  )
                                              ),

                                            )

                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                    joined_meet==0? SizedBox( height: 30,
                                        width: 200,child:ElevatedButton(onPressed: (){
                                          explore_key.currentState
                                              ?.pushNamed('/select_pets', arguments: [criteria,id]);
                                          setState(() {});
                                        },
                                            child:  Text("Join Meet",style: TextStyle(fontSize: 13.5, color:Colors.white)),
                                        style:ButtonStyle(
                                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(18.0),
                                                  side: BorderSide(color: Colors.white)
                                              )
                                          ),

                                        )

                                    ),):
                                    joined_meet==1? Text("You are attending this Meet", style: TextStyle(fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)):
                                    Text("You are the owner of this Meet", style: TextStyle(fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))]),
                            )]),



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
                        thumbnail==''?
                        Text(
                            '',
                            style:(
                                TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:22,
                                )
                            )
                        )
                              :Container(
                                width:510,
                                height:70,
                                decoration: BoxDecoration(

                                  image:DecorationImage(
                                      image:NetworkImage(thumbnail),

                                      fit:BoxFit.fitWidth,
                                      filterQuality: FilterQuality.high
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                ),) ,
                    Column(
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
                                    Container(
                                      width: 135.0,
                                      height: 130.0,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      ),
                                      child:Stack(
                                        children:[
                                          Container(
                                              alignment: Alignment.topCenter,
                                              child:Text(

                                                type+'\n'+address
                                                    +'\n'+phone+'\n'+website,
                                                  style:(
                                                      TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize:18,
                                                      )
                                                  )
                                              ))])),

                                  ],
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

      for (var entry in data) {
        final map = Map.from(entry);
        var x = map['longitude'];
        var y = map['latitude'];
        var id = map['id'];
        var title = map['title'];
        var address = map['address'];
        var website = map['website'];
        var phone = map['phone'];
        var thumbnail = map['thumbnail'];
        var type = map['type'];
        if (type == "Veterinarian"){
          final Uint8List customIcon = await getBytesFromAsset(
              "assets/images/vetmarker.png", 150);
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
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    thumbnail==''?
                                    Text(
                                        '',
                                        style:(
                                            TextStyle(
                                            )
                                        )
                                    )
                                    : thumbnail[0]!='h'?
                                    Text(
                                        '',
                                        style:(
                                            TextStyle(
                                            )
                                        )
                                    )
                                        :Container(
                                      width:510,
                                      height:70,
                                      decoration: BoxDecoration(

                                        image:DecorationImage(
                                            image:NetworkImage(thumbnail),

                                            fit:BoxFit.fitWidth,
                                            filterQuality: FilterQuality.high
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      ),) ,
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
                                    Container(
                                      width: 130.0,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      ),
                                        child:Stack(
                                            children:[
                                              Container(
                                                  alignment: Alignment.topCenter,
                                                  child:Text(

                                                      type,
                                                      style:(
                                                          TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize:18,
                                                          )
                                                      )
                                                  ))])
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom:8.0)),
                                      Container(
                                        width: 135.0,
                                        height: 130.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                        child:Stack(
                                            children:[
                                              Container(
                                                  alignment: Alignment.topCenter,
                                                  child:Text(

                                                      address
                                                          +'\n'+phone+'\n'+website,
                                                      style:(
                                                          TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize:18,
                                                          )
                                                      )
                                                  ))])),

                                  ],
                                ),

                              ]),



                        ), LatLng(y, x)
                    );
                  }

              ));
      }
        if (type == "Pet store"){
    Uint8List customIcon = await getBytesFromAsset(
    "assets/images/petstoremarker.png", 150);
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
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    thumbnail==''?
                                    Text(
                                        '',
                                        style:(
                                            TextStyle(
                                            )
                                        )
                                    )
                                        : thumbnail[0]!='h'?
                                    Text(
                                        '',
                                        style:(
                                            TextStyle(
                                            )
                                        )
                                    )
                                        :Container(
                                      width:510,
                                      height:70,
                                      decoration: BoxDecoration(

                                        image:DecorationImage(
                                            image:NetworkImage(thumbnail),

                                            fit:BoxFit.fitWidth,
                                            filterQuality: FilterQuality.high
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      ),) ,
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
                                    Container(
                                        width: 130.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                        child:Stack(
                                            children:[
                                              Container(
                                                  alignment: Alignment.topCenter,
                                                  child:Text(

                                                      type,
                                                      style:(
                                                          TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize:18,
                                                          )
                                                      )
                                                  ))])
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom:8.0)),
                                    Container(
                                        width: 135.0,
                                        height: 130.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                        child:Stack(
                                            children:[
                                              Container(
                                                  alignment: Alignment.topCenter,
                                                  child:Text(

                                                      address
                                                          +'\n'+phone+'\n'+website,
                                                      style:(
                                                          TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize:18,
                                                          )
                                                      )
                                                  ))])),

                                  ],
                                ),

                              ]),



                        ), LatLng(y, x)
                    );
                  }
              ));
        }
        if (type == "Dog park"){
          final Uint8List customIcon = await getBytesFromAsset(
              "assets/images/parkmarker.png", 150);
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
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    thumbnail==''?
                                    Text(
                                        '',
                                        style:(
                                            TextStyle(
                                            )
                                        )
                                    )
                                        : thumbnail[0]!='h'?
                                    Text(
                                        '',
                                        style:(
                                            TextStyle(
                                            )
                                        )
                                    )
                                        :Container(
                                      width:510,
                                      height:70,
                                      decoration: BoxDecoration(

                                        image:DecorationImage(
                                            image:NetworkImage(thumbnail),

                                            fit:BoxFit.fitWidth,
                                            filterQuality: FilterQuality.high
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      ),) ,
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
                                    Container(
                                        width: 130.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                        child:Stack(
                                            children:[
                                              Container(
                                                  alignment: Alignment.topCenter,
                                                  child:Text(

                                                      type,
                                                      style:(
                                                          TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize:18,
                                                          )
                                                      )
                                                  ))])
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom:8.0)),
                                    Container(
                                        width: 135.0,
                                        height: 130.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                        child:Stack(
                                            children:[
                                              Container(
                                                  alignment: Alignment.topCenter,
                                                  child:Text(

                                                      address
                                                          +'\n'+phone+'\n'+website,
                                                      style:(
                                                          TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize:18,
                                                          )
                                                      )
                                                  ))])),

                                  ],
                                ),

                              ]),



                        ), LatLng(y, x)
                    );
                  }
              ));
        }

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

class NewWidget extends StatefulWidget {
  final criteria;

  NewWidget({Key? key, required this.criteria}) : super(key:key);
  @override
  _NewWidgetState createState() => _NewWidgetState();


}

class _NewWidgetState extends State<NewWidget> {
  @override
  void initState() {
    print('da5alt');

  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.criteria.length,
      itemBuilder: (context, index) {
        var result = widget.criteria[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }


}
class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate({
    required this.alldata,
  });

  final alldata;
  final  lat = List<double>.empty(growable: true);
  final  long = List<double>.empty(growable: true);
  double longit = 0.0, latit = 0.0;

  Set<Marker> markersList = {};

  final  placenames = List<String>.empty(growable: true);
  initState(){
    initUser();
  }
  initUser()async{
    lat.clear();
    long.clear();
    placenames.clear();
    final data = await getLocations();
    placenames.addAll(data);
    /*final latdata = await getlat();
    lat.addAll(latdata);
    final longdata = await getlong();
    long.addAll(longdata);*/
  }
  /*Future getlat() async {
    final  lati = List<double>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*') as List<dynamic>;
      for (var entry in data) {
        final map = Map.from(entry);
        lati.add(map['latitude']);
      }
      return lati;

    }
    on PostgrestException catch (error) {
      print(error.message);
    }
    catch (e) {
      print(e);
    }
  }
  Future getlong() async {
    final  longi = List<double>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*') as List<dynamic>;
      for (var entry in data) {
        final map = Map.from(entry);
        longi.add(map['longitude']);
      }
      return longi;

    }
    on PostgrestException catch (error) {
      print(error.message);
    }
    catch (e) {
      print(e);
    }
  }*/
  Future getLocations() async {
    final  placenames = List<String>.empty(growable: true);
    try {
      final data = await SupabaseCredentials.supabaseClient
          .from('locations')
          .select('*') as List<dynamic>;

      for (var entry in data) {
        final map = Map.from(entry);
        var title = map['title'];
        placenames.add(title);
      }
    }
    on PostgrestException catch (error) {
      print(error.message);
    }
    catch (e) {
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
              onTap: () async{
                //Here where I would like to go to new screen
                int add = 0;
                int addlong = 0;
                var temp='';
                var z;
                for(int i = 0; i < placenames.length; i++){
                  if(placenames[i]==result){
                    var plc = placenames[i];
                    print('res: $result');
                    print('places: $placenames');

                    z = i;
                    break;
                  }
                }
                for(var entry in alldata){
                  final map = Map.from(entry);
                  lat.add(map['latitude']);
                  long.add(map['longitude']);
                }
                latit = lat[z];
                longit = long[z];

                setState(() {});
                close(context, GeoLocation(latit, longit));


              }


                ,title: Text(result),
                );
                },
            );});

    }

}






