import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:age_calculator/age_calculator.dart';
import 'package:sizer/sizer.dart';
import '../FETCH_wdgts.dart';
import '../JsonObj.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPetPage extends StatefulWidget {
  final PetProfile pod;

  const EditPetPage({Key? key, required this.pod}) : super(key: key);

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {

  final _controller = MultiSelectController();
  late DateTime petBirthDate = DateTime.now();
  DateTime tempDate = DateTime.now();
  final breedKey = GlobalKey<DropdownSearchState<Breed>>();
  final ageFieldController = TextEditingController();
  final nameField = TextEditingController();
  bool isMale = true;
  var photoUrl;
  List<Gender> genders = <Gender>[];
  bool btn_clicked = false;

  Breed? _selected;
  late Future<List<Breed>> bList;
  var bError = 5;
  final items = List<MultiSelectCard>.empty(growable: true);

  initData() {

    for (MapEntry entry in vaccineFList.entries){
      final vaccine = MultiSelectCard(value: entry.key, label: entry.value,
          selected: widget.pod.vaccines.contains(entry.key) ? true : false);
      items.add(vaccine);
    }
    petBirthDate = widget.pod.birthdate;
    nameField.text = widget.pod.name;
    isMale = widget.pod.isMale;
    updateAgeField(widget.pod.birthdate);

  }

  updateAgeField(DateTime value){
    final petAge = AgeCalculator.age(value);
    ageFieldController.text = petAge.years > 1
        ? '${petAge.years} Years'
        '${petAge.months > 1 ? ' and ${petAge.months} Months' : petAge.months == 1 ? ' and ${petAge.months} Month' : '' }'
        : petAge.years == 1 ? '${petAge.years} Year' '${petAge.months > 1 ? ' and ${petAge.months} Months' : petAge.months == 1 ? ' and ${petAge.months} Month' : '' }'
        : petAge.months > 1 ? '${petAge.months} Months' : petAge.months == 1 ? '${petAge.months} Month' : ''
    ;
  }

  updatePet({String? name, DateTime? bdate, List<String>? vaccines, bool? isMale}){
    widget.pod.name = name?? widget.pod.name;
    widget.pod.birthdate = bdate?? widget.pod.birthdate;
    widget.pod.vaccines = vaccines?? widget.pod.vaccines;
    widget.pod.isMale = isMale?? widget.pod.isMale;
  }

  @override
  void initState() {
    initData();
    bList = getBreedList(0);
    genders.add(Gender("Male", Icons.male, widget.pod.isMale ? true : false));
    genders.add(Gender("Female", Icons.female, widget.pod.isMale ? false : true));
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery
        .of(context)
        .size
        .height;
    final width = MediaQuery
        .of(context)
        .size
        .width;

    void showDatePicker() {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext builder) {
            return Container(
              margin: EdgeInsets.all(5.sp),
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.sp),
                  color: Colors.white
              ),
              height: MediaQuery
                  .of(context)
                  .copyWith()
                  .size
                  .height * 0.35,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: (){
                          Navigator.of(context).pop(false);
                            updateAgeField(petBirthDate);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))
                        ),
                        child: Text('Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),),
                      ),
                      ElevatedButton(
                        onPressed: (){
                          Navigator.of(context).pop(true);
                          petBirthDate = tempDate;
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))
                        ),
                        child: Text('Done',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 10.sp,
                          ),),
                      ),
                    ],
                  ),
                  Flexible(
                    flex: 2,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (value) {
                        setState(() {
                          if (value != petBirthDate) {
                            tempDate = value;
                            updateAgeField(value);
                          }
                        });
                      },
                      initialDateTime: petBirthDate,
                      minimumYear: DateTime
                          .now()
                          .year - 30,
                      maximumYear: DateTime
                          .now()
                          .year,
                      maximumDate: DateTime.now(),
                    ),
                  ),
                ],
              ),
            );
          }).then((value) {
        if (value == null){
            updateAgeField(petBirthDate);
        }
      });
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey
                ),
                height: 5,
                width: 100,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Edit ${widget.pod.name}'s info",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                          child: CircleAvatar(
                            radius: 31,
                            backgroundColor: Colors.grey,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(widget.pod.photoUrl),
                            ),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                              controller: nameField,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius
                                    .circular(20)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: CupertinoColors
                                        .extraLightBackgroundGray)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(20)),
                                filled: true,
                                fillColor: CupertinoColors.extraLightBackgroundGray,
                                labelStyle: TextStyle(color: Colors.grey),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.length < 2 || RegExp(r'[^a-zA-Z]').hasMatch(value)) {
                                  return "Enter a valid name";
                                }
                                return null;
                              },
                            ),

                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 15, 0, 2.5),
                                child: Text(
                                  'Birth date',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.5),
                            child: GestureDetector(
                              onTap: (){
                                showDatePicker();
                              },
                              child: TextFormField(
                                controller: ageFieldController,
                                enabled: false,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                          color: CupertinoColors
                                              .extraLightBackgroundGray)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey),
                                      borderRadius: BorderRadius.circular(20)),
                                  filled: true,
                                  fillColor: CupertinoColors
                                      .extraLightBackgroundGray,
                                  labelStyle: TextStyle(color: Colors.grey),
                                  suffixIcon: Icon(
                                    Icons.calendar_month_sharp,
                                    color: Colors.blueGrey,
                                  )
                                ),
                                validator: (value) {
                                  if (value!.length == 0) {
                                    return "Select birthdate";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 60,
                            width: 500,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Text(
                                    'Gender',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                ListView.builder(
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
                                        child: CustomRadio(genders[index]),
                                      );
                                    }),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  'Vaccines',
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  'Select all vaccines taken by your pet',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / 40),
                          MultiSelectContainer(
                              itemsDecoration: MultiSelectDecorations(
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.extraLightBackgroundGray,
                                    borderRadius: BorderRadius.circular(20),
                                  )
                              ),
                              prefix: MultiSelectPrefix(
                                  selectedPrefix: Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                  disabledPrefix: Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.do_disturb_alt_sharp,
                                      size: 14,
                                    ),
                                  )),
                              items: items,
                              controller: _controller,
                              onChange: (allSelectedItems, selectedItem) {
                              }),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                        'Update Information',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  onPressed: btn_clicked ? null : () async{
                                    setState(() {
                                      btn_clicked = true;
                                    });

                                    bool genderCheck = false;

                                    for (Gender item in genders){
                                      if (item.isSelected){
                                        genderCheck = true;
                                      }
                                    }
                                    //check variables
                                    if (nameField.text.isNotEmpty
                                        && genderCheck){
                                      var vList = _controller.getSelectedItems().toSet().toList();
                                      int value = await editPet(nameField.text.capitalize(), isMale,
                                          petBirthDate,
                                          vList, widget.pod.id, widget.pod.breed);

                                      if (value == 200){
                                        updatePet();
                                        homeNav_key.currentState?.pop(true);
                                      }else{
                                        showSnackbar(context, "Error updating pet info.");
                                      }

                                    }else{
                                      showSnackbar(context, 'Incomplete fields');
                                    }
                                    setState(() {
                                      btn_clicked = false;
                                    });

                                  },
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
          ],
        ),
      ),
    );
  }

}

