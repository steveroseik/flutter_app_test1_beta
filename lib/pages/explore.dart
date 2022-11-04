import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../configuration.dart';

class Category {
  String name;
  Category({required this.name});
}


class CategoryRenderingService {
  List<Category> categories;
  int selectedIndex = 0;
  CategoryRenderingService({required this.categories});

  List<Widget> render() {
    return categories.map((category) {
      bool selected = categories.indexOf(category) == selectedIndex;

      TextStyle style = selected ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.normal);
      return Text(category.name, style: style);
    }).toList();
  }
}

class ListButtons extends StatefulWidget {
  const ListButtons({Key? key}) : super(key: key);

  @override
  State<ListButtons> createState() => _ListButtonsState();
}

class _ListButtonsState extends State<ListButtons> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


int _selectedIndex = 0;
class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // late BitmapDescriptor customIcon;
  TextEditingController _searchController = TextEditingController();
  final markers = List<Marker>.empty(growable: true);
  CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();

  List<Category> categories = [
    Category(name: 'Vets'),
    Category(name: 'Parks'),
    Category(name: 'Pet Stores'),
  ];
  Future coordinates(double long, double lat) async {
    Expanded(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          //      target:LatLng(31.233334,30.033333),zoom: 5.4746,

          target:LatLng(long,lat),zoom: 10.4746,
        ),
      ),
    );

  }

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
            backgroundColor: Colors.grey,
          ),
          child: new Text('Vets'),
          onPressed: ()  =>  shortcutMarkers('Veterinarian'),
        ),
        new ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),child: new Text('Parks'),
          onPressed: ()  =>  shortcutMarkers('Dog park'),
        ),
        new ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),child: new Text('Pet Stores'),
          onPressed: ()  =>  shortcutMarkers('Pet store'),
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
              height: 100,
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
              padding: const EdgeInsets.all(50.0),
              child: shortcuts(),
            ),
          ],

        ),


    );
  }
  void _onTap(int index)
  {
    _selectedIndex = index;
    setState(() {

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
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_circle,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
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
                                    )
                                  ],
                                ),
                              ),
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),

                        ],
                      ), LatLng(y, x)
                  );
                }));
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
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_circle,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
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
                                    )
                                  ],
                                ),
                              ),
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),

                        ],
                      ), LatLng(y, x)
                  );
                }));
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
