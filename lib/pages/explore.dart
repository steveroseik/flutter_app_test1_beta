import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../configuration.dart';



class ListButtons extends StatefulWidget {
  const ListButtons({Key? key}) : super(key: key);

  @override
  State<ListButtons> createState() => _ListButtonsState();
}
class MapsPage extends StatelessWidget {//Edited
  const MapsPage({Key? key}) : super(key: key);
 
  // This is the root widget
  // of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GFG(),
    );
  }
}
class GFG extends StatefulWidget {//Edited
  const GFG({Key? key}) : super(key: key);
 
  @override
  State<GFG> createState() => _GFGState();
}
 
class _GFGState extends State<GFG> {//Edit
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
class _ListButtonsState extends State<ListButtons> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
class GFG extends StatefulWidget {//Edit
  const GFG({Key? key}) : super(key: key);
 
  @override
  State<GFG> createState() => _GFGState();
}
 
class _GFGState extends State<GFG> {//Edited
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GeeksForGeeks",
        ),
        actions: [
          IconButton(
            onPressed: () {
              // method to show the search bar
              showSearch(
                context: context,
                // delegate to customize the search bar
                delegate: CustomSearchDelegate()
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
    );
  }
}//Last edit

int _selectedIndex = 0;
class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // late BitmapDescriptor customIcon;
  String review = "";
  TextEditingController _searchController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  final markers = List<Marker>.empty(growable: true);
  double rating = 0;
  CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();


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

  @override
  void initState() {
    initMarkers();
    super.initState();
  }
  shortcutMarkers(String type) async{
    markers.clear();
    final data = await Display(type);
    markers.addAll(data);
    setState(() {});
  }

  Widget shortcuts() {
    return ButtonBar(
      mainAxisSize: MainAxisSize.min, // this will take space as minimum as posible(to center)
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
          onPressed: (){},
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: init_appBar(rootNav_key), // CHANGE KEY!!!
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
                _customInfoWindowController.googleMapController = controller;
              },
              initialCameraPosition: CameraPosition(
                  target:LatLng(31.233334,30.033333),zoom: 5.4746

                //    target:LatLng(80,30),zoom: 10.4746,

              ),
              markers: Set<Marker>.of(markers),

            ),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 190,
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
                    onPressed: (){},
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
                onPressed:(){},
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
  void _onTap(int index)
  {
    _selectedIndex = index;
    setState(() {

      // explore_key.currentState?.pushNamed('/newr');
    });
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
                                height:50,
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
                                          +'\n'+phone+'\n'+website+'\nRating: $rating',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Wrap(
                                        spacing:0,
                                        children:[
                                          RatingBar.builder(

                                            minRating:1,
                                            itemSize:20,
                                            itemBuilder:(context, _)=>Icon(Icons.star,color:Colors.amber),
                                            updateOnDrag:true,
                                            onRatingUpdate:(rating)=> setState((){
                                              this.rating = rating;

                                            }),
                                          ),
                                          SizedBox(
                                            width: 200.0,
                                            height: 20,
                                            child: TextField(
                                              controller: reviewController,
                                              onChanged: (value){
                                                setState((){
                                                  review = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Review',
                                              ),
                                            ),

                                          ),
                                          Container(
                                              child:SizedBox(
                                                  height: 25,
                                                  width: 50,
                                                  child:ElevatedButton(onPressed: (){
                                                    insert(review);

                                                  },
                                                      child: Icon(
                                                          Icons.send_rounded
                                                      )
                                                  )
                                              )
                                          )
                                        ]
                                    )

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
    int ret = -100;
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
                              height:50,
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
                                          +'\n'+phone+'\n'+website+'\nRating: $rating',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Wrap(
                                        spacing:0,
                                        children:[
                                          RatingBar.builder(

                                            minRating:1,
                                            itemSize:20,
                                            itemBuilder:(context, _)=>Icon(Icons.star,color:Colors.amber),
                                            updateOnDrag:true,
                                            onRatingUpdate:(rating)=> setState((){
                                              this.rating = rating;

                                            }),
                                          ),
                                          SizedBox(
                                            width: 200.0,
                                            height: 20,
                                            child: TextField(
                                              controller: reviewController,
                                              onChanged: (value){
                                                setState((){
                                                  review = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Review',
                                              ),
                                            ),

                                          ),
                                          Container(
                                              child:SizedBox(
                                                  height: 25,
                                                  width: 50,
                                                  child:ElevatedButton(onPressed: (){
                                                    insert(review);

                                                  },
                                                      child: Icon(
                                                          Icons.send_rounded
                                                      )
                                                  )
                                              )
                                          )
                                        ]
                                    )

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
Future insert(String review) async {
  if (review != "") {
    try {
      final data = await SupabaseCredentials.supabaseClient.from('locations')
          .insert({
        "review": review
      }
      );
    }
    catch (e) {
      print(e);
    }
  }
}
}
