import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../FETCH_wdgts.dart';


final PanelController _pc = PanelController();
// Elevated Card
class breedSearchPage extends StatefulWidget {
  final List<PetPod> ownerPets;
  const breedSearchPage({Key? key, required this.ownerPets}) : super(key: key);

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
  int distMin=0;
  int distMax=50;
  bool allPets = false;

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
  var age_r = RangeValues(0, 20);
  var distance_r = RangeValues(0, 50);
  String _genderValue = 'Male';

  initPets() async{

    pets.addAll(await fetchResultedPets());
    breedList.addAll(await fetchBreedNameList());
    setState(() {});
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
                SizedBox(height: 10,),
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
                        Text('${distMin}',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.blueGrey.shade900
                          ),),
                        Expanded(
                          child: RangeSlider(
                            values: distance_r,
                            activeColor: Colors.blueGrey.shade900,
                            inactiveColor: Colors.blueGrey.shade100,
                            onChanged: (RangeValues n) {
                              setState((){
                                distance_r = n;
                                distMin = n.start.toInt();
                                distMax = n.end.toInt();

                              });
                            },
                            min: 0,
                            max: 50,
                            divisions: 50,
                            labels:
                            RangeLabels('${distance_r.start.ceil()} Km', '${distance_r.end.ceil()} Km'),
                          ),
                        ),
                        Text('${distMax}',style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey.shade900
                        ),),
                      ],
                    ),
                  ),
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
                        onPressed: () {
                          if (_pc.isAttached) {
                            // initPets();
                            MultiSelectChipDisplay(
                              items: breedList.map((e) => MultiSelectItem(e, e)).toList(),
                              onTap: (value) {
                                setState(() {
                                  breedList.remove(value);
                                });
                              },
                            );
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
          appBar: init_appBar(BA_key),
          body: Padding(
            padding: EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1/1.3,
                mainAxisSpacing: 10.0,
              ),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                return PetView(profile: pets[index], ownerPets: widget.ownerPets,);
              },
            ),
          ),
        ),
        borderRadius: radius,
      ),
    );
  }
}
