import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:age_calculator/age_calculator.dart';

import '../FETCH_wdgts.dart';
import '../JsonObj.dart';
import 'APILibraries.dart';

class petRegPage extends StatefulWidget {
  final File recFile;
  const petRegPage({Key? key, required this.recFile}) : super(key: key);


  @override
  State<petRegPage> createState() => _petRegPageState();
}

class _petRegPageState extends State<petRegPage> {



  var rabies = false;
  var parvoVirus = false;
  var distemper = false;
  var dhpp_1 = false;
  var dhpp_2 = false;
  var dhpp_3 = false;
  var parainfluenza = false;
  var hepatitis = false;

  double ageNumber = 0;
  DateTime petBirthDate = DateTime.now();
  final openDropDownProgKey = GlobalKey<DropdownSearchState<Breed>>();
  final TextEditingController ageFieldController = TextEditingController();
  List<Gender> genders = <Gender>[];

  Breed? _selected;
  late Future<List<Breed>> bList;
  var bError = 5;

  @override
  void initState(){
    super.initState();
    bList = getBreedList(0);
    genders.add(new Gender("Male", Icons.male, false));
    genders.add(new Gender("Female", Icons.female, false));

  }

  @override
  Widget build(BuildContext context) {
    DateDuration petAge = AgeCalculator.age(petBirthDate);

    //DatePicker Widget
    void showDatePicker()
    {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext builder) {
            return Container(
              height: MediaQuery.of(context).copyWith().size.height*0.25,
              color: Colors.white,
              child: Column(
                children: [
                  Flexible(
                    flex: 2,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (value) {
                        setState(() {
                          if (value != null && value != petBirthDate) {
                            petBirthDate = value;
                            petAge = AgeCalculator.age(value);
                            ageFieldController.text = petAge.years > 0 ? petAge.years.toString() + ' Years' + (petAge.months > 0 ? ' and '  + petAge.months.toString() + ' Months' : '') :
                            (petAge.months > 0 ? petAge.months.toString() + ' Months' : '');
                          }
                        });


                      },
                      initialDateTime: petBirthDate,
                      minimumYear: DateTime.now().year - 30,
                      maximumYear: DateTime.now().year,
                      maximumDate: DateTime.now(),
                    ),
                  ),
                ],
              ),
            );
          }
      );

    }


    return Scaffold(
      appBar: init_appBar(BA_key),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Continue Pet Registration',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700

                    ),
                  ),
                  Spacer(),
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.teal,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: FileImage(widget.recFile),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Name',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,

                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: CupertinoTextField(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CupertinoColors.extraLightBackgroundGray,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    placeholder: 'Teddy',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 0, 2.5),
                      child: Text('Birth date',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,

                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: ageFieldController,
                          readOnly: true,
                          placeholder: 'Select birth date',
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CupertinoColors.extraLightBackgroundGray,
                            borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ),
                      IconButton(
                          color: Colors.teal.shade100,
                          onPressed: (){
                            showDatePicker();
                          },
                          icon: Icon(Icons.calendar_month,
                      color: Colors.grey.shade900)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Breed',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,

                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: true,
                  child: Row(
                    children: [Expanded(child: BetaTest()),],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 100,
                  width: 300,
                  alignment: Alignment.center,
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
                            });
                          },
                          child: CustomRadio(genders[index]),
                        );
                      }),
                ),
                SizedBox(height: 20),
                Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Vaccinations',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,

                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [

                        Flexible(
                            flex: 1,
                            child: SizedBox(
                              child: CheckboxListTile(
                                activeColor: Colors.teal.shade300,
                                title: Text("Rabies",
                                style: TextStyle(
                                  color: Colors.grey.shade600
                                ),),
                                value: rabies,
                                onChanged: (newValue) {
                                  setState(() {
                                    rabies = newValue!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                              ),
                            )
                        ),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            child: CheckboxListTile(
                              activeColor: Colors.teal.shade300,
                              title: Text("ParvoVirus",
                                style: TextStyle(
                                    color: Colors.grey.shade600
                                ),),
                              value: parvoVirus,
                              onChanged: (newValue) {
                                setState(() {
                                  parvoVirus = newValue!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                            ),
                          )
                        ),
                      ],
                    ),

                    Row(
                      children: [

                        Flexible(
                            flex: 1,
                            child: SizedBox(
                              child: CheckboxListTile(
                                activeColor: Colors.teal.shade300,
                                title: Text("Distemper",
                                  style: TextStyle(
                                      color: Colors.grey.shade600
                                  ),),
                                value: distemper,
                                onChanged: (newValue) {
                                  setState(() {
                                    distemper = newValue!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                              ),
                            )
                        ),
                        Flexible(
                            flex: 1,
                            child: SizedBox(
                              child: CheckboxListTile(
                                activeColor: Colors.teal.shade300,
                                title: Text("Hepatitis",
                                  style: TextStyle(
                                      color: Colors.grey.shade600
                                  ),),
                                value: hepatitis,
                                onChanged: (newValue) {
                                  setState(() {
                                    hepatitis = newValue!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                              ),
                            )
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                            flex: 1,
                            child: SizedBox(
                              child: CheckboxListTile(
                                activeColor: Colors.teal.shade300,
                                title: Text("Parainfluenza",
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      color: Colors.grey.shade600
                                  ),),
                                value: parainfluenza,
                                onChanged: (newValue) {
                                  setState(() {
                                    parainfluenza = newValue!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                              ),
                            )
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                            flex: 1,
                            child: SizedBox(
                              child: CheckboxListTile(
                                activeColor: Colors.teal.shade300,
                                title: Text("DHPP 1st shot",
                                  style: TextStyle(
                                      color: Colors.grey.shade600
                                  ),),
                                value: dhpp_1,
                                onChanged: (newValue) {
                                  setState(() {
                                    dhpp_1 = newValue!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                              ),
                            )
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                            flex: 1,
                            child: SizedBox(
                              child: CheckboxListTile(
                                activeColor: Colors.teal.shade300,
                                title: Text("DHPP 2nd shot",
                                  style: TextStyle(
                                      color: Colors.grey.shade600
                                  ),),
                                value: dhpp_2,
                                onChanged: (newValue) {
                                  setState(() {
                                    dhpp_2 = newValue!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                              ),
                            )
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                            flex: 1,
                            child: SizedBox(
                              child: CheckboxListTile(
                                activeColor: Colors.teal.shade300,
                                title: Text("DHPP 3rd shot",
                                  style: TextStyle(
                                      color: Colors.grey.shade600
                                  ),),
                                value: dhpp_3,
                                onChanged: (newValue) {
                                  setState(() {
                                    dhpp_3 = newValue!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                              ),
                            )
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.teal.shade100, backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)

                            )
                        ),
                        onPressed: () {
                          BA_key.currentState?.pushNamed('/pet_adopt');
                        },
                        child: Text('FINISH',
                          style: TextStyle(
                              color: Colors.black
                          ),),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            ],
          ),
        ),
        
      ),
    );
  }

  Widget BetaTest(){
    return Container(
      width: 100,
      child: FutureBuilder<List<Breed>>(
        future: bList,
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return DropdownSearch<String>(
              items: ['...'],
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Container(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownSearch<Breed>(
                  key: openDropDownProgKey,
                  selectedItem: _selected,
                  onChanged: (Breed? b) {
                    _selected = b;
                  },
                  compareFn: (i1, i2) => i1.name == i2.name,
                  items: snapshot.data!,
                  itemAsString: (Breed b) => b.name,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration()
                  ),
                  dropdownBuilder: _customDropDownView,
                  popupProps: PopupProps.modalBottomSheet(
                    showSearchBox: true,
                    fit: FlexFit.tight,
                    constraints: BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: 500
                    ),
                    searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Type breed name',
                        )),
                    itemBuilder: (ctx, item, isSelected) {
                      return ListTile(
                        title: Text(item.name,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13.5, color: Colors.black)),
                        leading: CircleAvatar(
                            backgroundImage: NetworkImage(item.image.url)),
                      );
                    },
                  ),
                  filterFn: (breed, filter) => breed.filterBreedItem(filter),
                ),
              );
            default:
              return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _customDropDownView(
      BuildContext context, Breed? selectedItem) {
    if (selectedItem == null) {
      return ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text("No breed selected",
        style: TextStyle(
          color: Colors.grey
        ),),
        leading: CircleAvatar(),
      );
    }
    return ListTile(
        title: Text(selectedItem.name,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
        fontSize: 13.5, color: Colors.black)),
    leading: CircleAvatar(
    backgroundImage: NetworkImage(selectedItem.image.url)),
    );
  }

}
