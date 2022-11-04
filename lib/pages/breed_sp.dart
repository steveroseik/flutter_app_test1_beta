import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../FETCH_wdgts.dart';


final PanelController _pc = PanelController();
// Elevated Card
class breedSearchPage extends StatefulWidget {
  const breedSearchPage({Key? key}) : super(key: key);

  @override
  State<breedSearchPage> createState() => _breedSearchPageState();
}



class _breedSearchPageState extends State<breedSearchPage> {
  final breedKey = GlobalKey<DropdownSearchState<Breed>>();
  List<Gender> genders = <Gender>[];
  bool isMale = true;

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
  var age_r = RangeValues(1, 20);
  String _genderValue = 'Male';

  @override
  void initState() {
    genders.add(Gender('male', Icons.male, false));
    genders.add(Gender('female', Icons.female, false));
    super.initState();
    // _pc.open();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SlidingUpPanel(
        backdropEnabled: true,
        minHeight: 50,
        maxHeight: 300,
        controller: _pc,

        panel: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Breed',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: BreedSearchWidget(formKey: breedKey)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Age Range',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                      fontWeight: FontWeight.w800),
                ),
              ),
              RangeSlider(
                values: age_r,
                activeColor: Colors.teal,
                inactiveColor: Colors.teal[100],
                onChanged: (RangeValues n) {
                  setState(() => age_r = n);
                },
                min: 1,
                max: 20,
                divisions: 19,
                labels:
                    RangeLabels('${age_r.start.ceil()}', '${age_r.end.ceil()}'),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gender ',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    VerticalDivider(),
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
                                  if (genders[index].name == "Male"){
                                    isMale = true;
                                  }else{
                                    isMale = false;
                                  }
                                });
                              },
                              child: miniCustomRadio(genders[index]),
                            );
                          }),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_pc.isAttached) {
                                _pc.close();
                              } else {}
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.teal,
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
              )
            ],
          ),
        ),
        collapsed: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Colors.grey[50],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
            ],
          ),
        ),
        body: Scaffold(
          appBar: init_appBar(BA_key),
          body: Center(
            child: Text("This is the Widget behind the sliding panel"),
          ),
        ),
        borderRadius: radius,
      ),
    );
  }
}
