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

class petRegPage extends StatefulWidget {
  final File recFile;
  final String breedSelected;
  const petRegPage({Key? key, required this.recFile, required this.breedSelected}) : super(key: key);

  @override
  State<petRegPage> createState() => _petRegPageState();
}

class _petRegPageState extends State<petRegPage> {

  final _controller = MultiSelectController();

  DateTime? petBirthDate;
  DateTime tempDate = DateTime.now();
  final breedKey = GlobalKey<DropdownSearchState<Breed>>();
  final ageFieldController = TextEditingController();
  final nameField = TextEditingController();
  bool? isMale;
  String? photoUrl;
  List<Gender> genders = <Gender>[];
  bool btn_clicked = false;
  DateDuration petAge = AgeCalculator.age(DateTime.now());

  Breed? _selected;
  late Future<List<Breed>> bList;
  var bError = 5;


  @override
  void initState() {
    super.initState();
    bList = getBreedList(0);
    genders.add(Gender("Male", Icons.male, false));
    genders.add(Gender("Female", Icons.female, false));
  }

  updateAgeField(DateTime value){
    petAge = AgeCalculator.age(value);
    ageFieldController.text = petAge.years > 1
        ? '${petAge.years} Years'
        '${petAge.months > 1 ? ' and ${petAge.months} Months' : petAge.months == 1 ? ' and ${petAge.months} Month' : '' }'
        : petAge.years == 1 ? '${petAge.years} Year' '${petAge.months > 1 ? ' and ${petAge.months} Months' : petAge.months == 1 ? ' and ${petAge.months} Month' : '' }'
        : petAge.months > 1 ? '${petAge.months} Months' : petAge.months == 1 ? '${petAge.months} Month' : ''
    ;
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

    //DatePicker Widget
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
                          if (petBirthDate != null){
                            updateAgeField(petBirthDate!);
                          }
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
                      initialDateTime: petBirthDate ?? DateTime.now(),
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
              if (petBirthDate != null){
                updateAgeField(petBirthDate!);
              }
            }
      });
    }

    return Scaffold(
      appBar: init_appBar(homeNav_key),
      resizeToAvoidBottomInset: false,
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
                  Text(
                    'Continue Pet Registration',
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
                        backgroundImage: FileImage(widget.recFile),
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: TextFormField(
                        controller: nameField,
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
                          if (value!.length < 2) {
                            return "Enter your dog's full name";
                          }
                          return null;
                        },
                      ),

                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
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
                    GestureDetector(
                      onTap: (){
                        showDatePicker();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: TextFormField(
                          controller: ageFieldController,
                          enabled: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: CupertinoColors
                                        .extraLightBackgroundGray)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey),
                                borderRadius: BorderRadius.circular(20)),
                            filled: true,
                            fillColor: CupertinoColors
                                .extraLightBackgroundGray,
                            labelStyle: TextStyle(color: Colors.grey),
                            suffixIcon: const Icon(
                              Icons.calendar_month_sharp,
                              color: Colors.blueGrey,
                            )
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Select birthdate";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Breed',
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
                    Visibility(
                      visible: true,
                      child: Row(
                        children: [
                          Expanded(
                            child: BreedSearchWidget(formKey: breedKey, breedSelected: widget.breedSelected, bList: [], controller: 0,),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
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
                        items: [
                          MultiSelectCard(value: 'rabies', label: 'Rabies'),
                          MultiSelectCard(
                              value: 'parvoVirus', label: 'ParvoVirus'),
                          MultiSelectCard(
                              value: 'distemper', label: 'Distemper'),
                          MultiSelectCard(
                              value: 'hepatitis', label: 'Hepatitis'),
                          MultiSelectCard(
                              value: 'parainfluenza', label: 'Parainfluenza'),
                          MultiSelectCard(
                              value: 'dhpp1', label: 'DHPP first shot'),
                          MultiSelectCard(
                              value: 'dhpp2', label: 'DHPP second shot'),
                          MultiSelectCard(
                              value: 'dhpp3', label: 'DHPP third shot'),
                        ],
                        controller: _controller,
                        onChange: (allSelectedItems, selectedItem) {
                        }),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'Next',
                                style: TextStyle(color: Colors.white)),
                            ),
                            onPressed: btn_clicked ? null : () async{
                              setState(() {
                                btn_clicked = true;
                              });
                              final String dogBreed;
                              if (breedKey.currentState!.getSelectedItem != null){
                                dogBreed = breedKey.currentState!.getSelectedItem!.name;
                              }else {
                                dogBreed = '';
                              }
                              //check variables
                              if (dogBreed != ''
                                  && nameField.text.isNotEmpty
                                  && petBirthDate != null && isMale != null){

                                photoUrl = await uploadPhoto(widget.recFile);
                                if (photoUrl != '-100'){
                                  print(photoUrl);
                                  final vaccines = List<String>.from(_controller.getSelectedItems());
                                  homeNav_key.currentState?.pushNamed('/petDocument', arguments: [nameField.text.capitalize(),
                                                dogBreed, isMale!,
                                                petBirthDate,
                                                photoUrl, FirebaseAuth.instance.currentUser!.uid, vaccines]);

                                }else{
                                  showSnackbar(context, 'Photo upload issue! Try again.');
                                }

                              }else{
                                showSnackbar(context, 'Please complete all fields.');
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
    );
  }

}

