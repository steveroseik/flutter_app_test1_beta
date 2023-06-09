import 'dart:async';
import 'dart:convert';

import 'package:age_calculator/age_calculator.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'draggable_card.dart';
import 'swipe_cards.dart';

import 'JsonObj.dart';

// Global variables
var animationDuration_1 = const Duration(milliseconds: 300);

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
class BreedSearchMultiWidget extends StatefulWidget {
  final GlobalKey<DropdownSearchState<Breed>> formKey;
  const BreedSearchMultiWidget({Key? key, required this.formKey}) : super(key: key);

  @override
  State<BreedSearchMultiWidget> createState() => _BreedSearchMultiWidgetState();
}
class _BreedSearchMultiWidgetState extends State<BreedSearchMultiWidget> {
  Breed? _selected;
  late Future<List<Breed>> bList;
  var bError = 5;
  final _openDropDownProgKey = GlobalKey<DropdownSearchState<int>>();

  Breed getSelected(){
    return _selected!;
  }

  @override
  void initState() {
    super.initState();
    bList = getBreedList(0);

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: FutureBuilder<List<Breed>>(
        future: bList,
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return DropdownSearch<String>(
              items: ['...'],
              dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  )
              ),
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: CupertinoColors.extraLightBackgroundGray,
                ),
                child: DropdownSearch<Breed>.multiSelection(
                  key: widget.formKey,
                  compareFn: (i1, i2) => i1.name == i2.name,
                  items: snapshot.data!,
                  itemAsString: (Breed b) => b.name,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)
                          )
                      )
                  ),
                  popupProps: PopupPropsMultiSelection.modalBottomSheet(
                    showSearchBox: true,
                    fit: FlexFit.tight,
                    constraints: BoxConstraints.tightForFinite(height: MediaQuery.of(context).size.height * 0.7),
                    searchFieldProps: TextFieldProps(
                      enableSuggestions: true,
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
                            backgroundImage: NetworkImage(item.photoUrl)),
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
}

class BreedSearchWidget extends StatefulWidget {
  final GlobalKey<DropdownSearchState<Breed>> formKey;
  final String breedSelected;
  final bList;
  final int controller;
  const BreedSearchWidget({Key? key, required this.formKey, required this.breedSelected, required this.bList, required this.controller}) : super(key: key);

  @override
  State<BreedSearchWidget> createState() => _BreedSearchWidgetState();
}
class _BreedSearchWidgetState extends State<BreedSearchWidget> {
  Breed? _selected;
  var bError = 5;
  final _openDropDownProgKey = GlobalKey<DropdownSearchState<int>>();
  List<Breed> finalList = <Breed>[];
  bool isLoading = true;
  Breed getSelected(){
    return _selected!;
  }


  initWidget() async{
    if (widget.controller == 0){
      await genBreeds();
    }else{
      finalList.addAll(widget.bList);
    }

    if (widget.breedSelected != ''){
      for ( Breed breed in finalList){
        if (breed.name == widget.breedSelected){
          _selected = breed;
          break;
        }
      }
    }
    if (this.mounted){
      setState(() {
        isLoading = false;
      });
    }

  }
  genBreeds() async{
    final breeds = await getBreedList(0);
    finalList.addAll(breeds);
  }


  @override
  void initState() {
    super.initState();
    initWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: isLoading ?  DropdownSearch<String>(
        items: ['...'],
        dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            )
        ),
      ) : Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: CupertinoColors.extraLightBackgroundGray,
        ),
        child: DropdownSearch<Breed>(
          key: widget.formKey,
          selectedItem: _selected,
          onChanged: (Breed? b) {
            _selected = b;
          },
          compareFn: (i1, i2) => i1.name == i2.name,
          items: finalList,
          itemAsString: (Breed b) => b.name,
          dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)
                  )
              )
          ),
          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            fit: FlexFit.tight,
            constraints: BoxConstraints.tightForFinite(height: MediaQuery.of(context).size.height * 0.7),
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
                    backgroundImage: NetworkImage(item.photoUrl)),
              );
            },
          ),
          filterFn: (breed, filter) => breed.filterBreedItem(filter),
        ),
      )
    );
  }
}

Widget _customDropDownView(BuildContext context, Breed? selectedItem) {
  if (selectedItem == null) {
    return ListTile(
      title: Text(
        "No breed selected",
        style: TextStyle(color: Colors.grey),
      ),
      leading: CircleAvatar(),
    );
  }
  return ListTile(
    title: Text(selectedItem.name,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13.5, color: Colors.black)),
    leading:
    CircleAvatar(backgroundColor: CupertinoColors.extraLightBackgroundGray,
        backgroundImage: NetworkImage(selectedItem.photoUrl)),
  );
}

OverlayEntry initLoading(BuildContext context) {
  final bottomPadding = MediaQuery.of(context).padding.bottom;
  final width = MediaQuery.of(context).size.width;
  Offset offs = Offset((width / 2) - 25, bottomPadding);
  final loading = OverlayEntry(
      builder: (BuildContext context) => Positioned(
            left: offs.dx,
            bottom: bottomPadding,
            child: SizedBox(
              height: 50,
              width: 50,
              child: LoadingIndicator(
                  indicatorType: Indicator.ballPulseSync,
                  colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade300, Colors.blueGrey.shade600]),
            ),
          ));

  return loading;
}


// GENDERS RADIO BUTTON
class Gender {
  String name;
  IconData icon;
  bool isSelected;

  Gender(this.name, this.icon, this.isSelected);
}

class selectItem {
  String name;
  bool isSelected;

  selectItem(this.name, this.isSelected);
}
class MateItem{
  PetPod pod;
  MateRequest? request;
  
  MateItem({required this.pod, this.request});

  get stat => request?.status ?? requestState.undefined;
}

class CustomSelectionItem extends StatelessWidget {
  selectItem _item;

  CustomSelectionItem(this._item);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if (_item.isSelected){
          _item.isSelected = false;
        }else {
          _item.isSelected = true;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _item.isSelected ? Colors.deepOrangeAccent : Colors.black
        ),
        margin: new EdgeInsets.all(5.0),
        child: Row(
          children: [
            _item.isSelected ? Icon(Icons.check) : Container(),
            Text(_item.name, style: TextStyle(color: _item.isSelected ? Colors.white : Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}

class miniCustomRadio extends StatelessWidget {
  Gender _gender;

  miniCustomRadio(this._gender);

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: _gender.isSelected ? Colors.black : Colors.white,
        child: Container(
          width: 40*MediaQuery.of(context).size.width*0.002,
          margin: new EdgeInsets.all(5.0),
          child: Center(
            child: Icon(
              _gender.icon,
              color: _gender.isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
        ));
  }
}

class CustomRadio extends StatelessWidget {
  Gender _gender;

  CustomRadio(this._gender);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.sp)
      ),
        color: _gender.isSelected ? Color(0xFF3B4257) : Colors.white,
        child: Container(
          margin: EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _gender.icon,
                color: _gender.isSelected ? Colors.white : Colors.grey,
              ),
              SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,10,0),
                child: Text(
                  _gender.name,
                  style: TextStyle(
                    fontSize: 9.sp,
                      color: _gender.isSelected ? Colors.white : Colors.grey),
                ),
              )
            ],
          ),
        ));
  }
}
class CustomRadioRound extends StatelessWidget {
  Gender _gender;

  CustomRadioRound(this._gender);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: _gender.isSelected ? Color(0xFF3B4257) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Container(
          margin: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _gender.icon,
                color: _gender.isSelected ? Colors.white : Colors.grey,
              ),
              SizedBox(width: 1.w),
              Padding(
                padding: EdgeInsets.fromLTRB(0,0,1.w,0),
                child: Text(
                  _gender.name,
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: _gender.isSelected ? Colors.white : Colors.grey),
                ),
              )
            ],
          ),
        ));
  }
}
class GeoLocation{
  double lat;
  double long;
  GeoLocation(this.lat, this.long);

  Lat(){
    return lat;
  }
  Long(){
    return long;
  }
}


class PetPod {
  PetProfile pet;
  bool isSelected = false;
  bool hasLocation = false;
  bool foreign = false;
  int distance = -1;
  PetPod({required this.pet, required this.isSelected, bool? foreign, int? distance}){
    this.foreign = foreign?? false;
    hasLocation = (pet.location.longtitude != 0.0 && pet.location.latitude != 0.0);
  }

  PetPod copyWith({
    PetProfile? pet,
    bool? isSelected,
    bool? foreign,
    int? distance
  }) {
    return PetPod(pet: pet ?? this.pet,
      isSelected: isSelected ?? this.isSelected, foreign: foreign?? this.foreign, distance: distance?? this.distance);
  }

  // @override
  // int compareTo(other) {
  //   if (distance < other.getDistance()) {
  //     return -1;
  //   } else if (distance > other.getDistance()) {
  //     return 1;
  //   } else {
  //     return 0;
  //   }
  // }
}

class CustomPetMatch extends StatelessWidget {
  final PetProfile pod;
  const CustomPetMatch({Key? key, required this.pod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final petAge = AgeCalculator.age(pod.birthdate);
    String petText = (petAge == 0 ? '' : petAge.years == 1 ? "${petAge.years} year" : "${petAge.years} years") +
        (petAge.months == 0 ? '' : petAge.months == 1 ? " and ${petAge.months} month" : " and ${petAge.months} months");

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey.shade900,
        border: Border.all(width: 5, color:  CupertinoColors.extraLightBackgroundGray),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3),
                        child: Text(
                          pod.name,
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(petText,
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                          icon: Icon(Icons.notes, size: 20, color: Colors.blueGrey),
                          label: Text('Documents',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey),), onPressed: () {  },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: CircleAvatar(
                    radius: width * 0.15,
                    backgroundColor: Colors.white ,
                    child: CircleAvatar(
                      backgroundColor: CupertinoColors.extraLightBackgroundGray,
                      radius: width * 0.15 - 2,
                      backgroundImage: NetworkImage(pod.photoUrl),
                    )
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              CircleAvatar(
                  backgroundColor: Colors
                      .white,
                  child: Icon(Icons.vaccines,
                      color: Colors.black)),
              Flexible(
                flex: 1,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 5.0),
                  child: LinearPercentIndicator(
                    lineHeight: 5.0,
                    percent: pod.vaccines.length /
                        8,
                    barRadius: Radius.circular(20),
                    backgroundColor: Colors.grey,
                    progressColor: Colors.white,
                    trailing: Text(
                      '${(pod.vaccines.length / 8 * 100).toInt()}%',
                      style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.pin_drop_rounded, color: Colors.white),
              Text('2.6 km', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }
}

class CustomPet extends StatelessWidget {
  final PetPod pod;
  const CustomPet({Key? key, required this.pod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.sp),
        color: pod.isSelected ? Colors.blueGrey.shade900 : CupertinoColors.extraLightBackgroundGray,
        border: Border.all(width: 1, color:  pod.isSelected ? CupertinoColors.extraLightBackgroundGray : Colors.blueGrey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: CircleAvatar(
              radius: 22.sp,
              backgroundColor: pod.isSelected ? Colors.white : Colors.blueGrey,
              child: CircleAvatar(
                radius: 21.5.sp,
                backgroundColor: CupertinoColors.extraLightBackgroundGray,
                backgroundImage: NetworkImage(pod.pet.photoUrl),
              )
            ),
          ),
          Flexible(
            flex: 1,
            child: Text(
              pod.pet.name,
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  color: pod.isSelected ? Colors.white : Colors.blueGrey, overflow: TextOverflow.fade),
            ),
          )
        ],
      ),
    );
  }
}

class PetConfirmDialog extends StatelessWidget {
  final PetProfile pod;
  final PetPod sender;
  const PetConfirmDialog({Key? key, required this.pod, required this.sender}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final petAge = AgeCalculator.age(pod.birthdate);
    String petText = (petAge == 0 ? '' : petAge.years == 1 ? "${petAge.years} year" : "${petAge.years} years") +
        (petAge.months == 0 ? '' : petAge.months == 1 ? " and ${petAge.months} month" : " and ${petAge.months} months");

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.blueGrey,
        border: Border.all(width: 5, color:  CupertinoColors.extraLightBackgroundGray),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: CircleAvatar(
                    radius: width * 0.15,
                    backgroundColor: Colors.white ,
                    child: CircleAvatar(
                      backgroundColor: CupertinoColors.extraLightBackgroundGray,
                      radius: width * 0.15 - 2,
                      backgroundImage: NetworkImage(pod.photoUrl),
                    )
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          Text(
            'Send Mating Request?',
            style: TextStyle(
                fontWeight:
                FontWeight.w900,
                fontSize: 20,
                color: Colors.white),
          ),
          SizedBox(height: 10,),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0))),
            icon: Icon(CupertinoIcons.heart, size: 20, color: Colors.blueGrey),
            label: Text('Confirm',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey),), onPressed: () async{
              final resp = await sendMateRequest(sender.pet.ownerId, pod.ownerId, sender.pet.id, pod.id);
              if (resp == 200){
                print('request sent');
              }else{
                print('failed to send request');
              }
          },
          )
        ],
      ),
    );
  }
}


class MultiPetRequestBanner extends StatefulWidget {
  final MateItem pod;
  final int count;
  final PetPod receiverPet;

  const MultiPetRequestBanner({Key? key, required this.pod, required this.count, required this.receiverPet}) : super(key: key);

  @override
  State<MultiPetRequestBanner> createState() => _MultiPetRequestBannerState();
}

class _MultiPetRequestBannerState extends State<MultiPetRequestBanner> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: GlassContainer(
            height: height * 0.09,
            width: width,
            blur: 10,
            color: Colors.black.withOpacity(0.8),
            border: Border.fromBorderSide(BorderSide.none),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blueGrey.shade900, Colors.black]),
            child: Center(
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                        radius: width * 0.07,
                        backgroundColor: CupertinoColors.extraLightBackgroundGray ,
                        child: CircleAvatar(
                          backgroundColor: CupertinoColors.extraLightBackgroundGray,
                          radius: width * 0.07 - 2,
                          backgroundImage: NetworkImage(widget.pod.pod.pet.photoUrl),
                        )
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                          radius: width * 0.035,
                          backgroundColor: CupertinoColors.extraLightBackgroundGray ,
                          child: CircleAvatar(
                            backgroundColor: CupertinoColors.extraLightBackgroundGray,
                            radius: width * 0.035 - 2,
                            backgroundImage: NetworkImage(widget.receiverPet.pet.photoUrl),
                          )
                      ),
                    ),
                  ],
                ),
                title: Text(
                  '${widget.pod.pod.pet.name} has requested ${widget.receiverPet.pet.name} to mate '
                      'and ${widget.count} more requests.',
                  style: TextStyle(
                      fontWeight:
                      FontWeight.w500,
                      fontSize: 15,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class PetRequestBanner extends StatefulWidget {
  final MateItem pod;
  final PetPod receiverPet;
  const PetRequestBanner({Key? key, required this.pod, required this.receiverPet}) : super(key: key);

  @override
  State<PetRequestBanner> createState() => _PetRequestBannerState();
}

class _PetRequestBannerState extends State<PetRequestBanner> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: GlassContainer(
            height: height * 0.09,
            width: width,
            blur: 10,
            color: Colors.black.withOpacity(0.8),
            border: Border.fromBorderSide(BorderSide.none),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blueGrey.shade900, Colors.black]),
            child: Center(
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                        radius: width * 0.07,
                        backgroundColor: CupertinoColors.extraLightBackgroundGray ,
                        child: CircleAvatar(
                          backgroundColor: CupertinoColors.extraLightBackgroundGray,
                          radius: width * 0.07 - 2,
                          backgroundImage: NetworkImage(widget.pod.pod.pet.photoUrl),
                        )
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                          radius: width * 0.035,
                          backgroundColor: CupertinoColors.extraLightBackgroundGray ,
                          child: CircleAvatar(
                            backgroundColor: CupertinoColors.extraLightBackgroundGray,
                            radius: width * 0.035 - 2,
                            backgroundImage: NetworkImage(widget.receiverPet.pet.photoUrl),
                          )
                      ),
                    ),
                  ],
                ),
                title: Text(
                      '${widget.pod.pod.pet.name} has requested ${widget.receiverPet.pet.name} to mate.',
                      style: TextStyle(
                          fontWeight:
                          FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PetRequestCard extends StatefulWidget {
  final MateItem request;
  const PetRequestCard({Key? key, required this.request}) : super(key: key);

  State<PetRequestCard> createState() => _PetRequestCardState();
}

class _PetRequestCardState extends State<PetRequestCard> {

  final _controller = MultiSelectController();

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final petAge = AgeCalculator.age(widget.request.pod.pet.birthdate);
    String petText = (petAge == 0 ? '' : petAge.years == 1 ? "${petAge.years} yr\n" : "${petAge.years} yrs\n") +
        (petAge.months == 0 ? '' : petAge.months == 1 ? "${petAge.months} month" : "${petAge.months} months");


    final vaccinesItems = List<MultiSelectCard>.generate(8, (index) {
      final key = vaccineFList.entries.elementAt(index).key;
      final value = vaccineFList.entries.elementAt(index).value;
      return MultiSelectCard(value: key, label: value, selected: widget.request.pod.pet.vaccines.contains(key) ? true : false);
    });
    return ColumnSuper(innerDistance: -height/2.8 - 50,
      children: [
      Container(
        padding: EdgeInsets.fromLTRB(10,10,10,0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    icon: Icon(Icons.location_pin, size: 15, color: Colors.black,),
                    onPressed: () {
                      showSnackbar(context, 'Need to accept request in order to view location');
                    },
                    label: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('1.3 km',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    icon: Icon(Icons.article_rounded, size: 15, color: Colors.black,),
                    onPressed: () {
                    },
                    label: Text('Documents',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  )
                ],
              )
            ),
            Text('${widget.request.pod.pet.name}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            SizedBox(height: 5),
            Text('${widget.request.pod.pet.breed}',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Text('Age', style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600
                        ),),
                        Divider(),
                        Text(petText,textAlign: TextAlign.center, style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600
                        ),)
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Column(
                      children: [
                        Text('Gender', style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600
                        ),),
                        Divider(),
                        Icon(widget.request.pod.pet.isMale ? Icons.male_rounded : Icons.female_rounded, color: widget.request.pod.pet.isMale ? Colors.blue : Colors.pinkAccent,)
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Column(
                      children: [
                        Text('Mates', style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600
                        ),),
                        Divider(),
                        Text('0',textAlign: TextAlign.center, style: TextStyle(
                          color: Colors.black,fontWeight: FontWeight.w600
                        ),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: ()async{
                await showDialog(
                  context: context,
                  builder: (ctx) {
                    return  Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        height: 300,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child:   Column(
                            children: [
                              Text("${widget.request.pod.pet.name}'s Vaccinations List",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,

                                ),),
                              Divider(),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Container(
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: MultiSelectContainer(
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
                                              enabledPrefix: Padding(
                                                padding: EdgeInsets.only(right: 5),
                                                child: Icon(
                                                  Icons.close,
                                                  size: 14,
                                                ),
                                              )),
                                          items: vaccinesItems,
                                          onChange: (allSelectedItems, selectedItem) {
                                          }),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.vaccines_rounded),
                    Flexible(
                      child: LinearPercentIndicator(
                        lineHeight: 5.0,
                        percent: widget.request.pod.pet.vaccines.length / 8,
                        barRadius: Radius.circular(20),
                        backgroundColor: CupertinoColors.extraLightBackgroundGray,
                        progressColor: Colors.black,
                        trailing: Text(
                          '${(widget.request.pod.pet.vaccines.length / 8 * 100).toInt()}%',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    icon: Icon(Icons.close_rounded, size: 15, color: Colors.black,),
                    onPressed: () async{
                      final resp = await updateMateRequest(widget.request.request!.id, 2);
                      if (resp == 200){
                        homeNav_key.currentState?.pop(true);
                      }else{
                        showSnackbar(context, "Failed to communicate with server, try again.");
                      }
                    },
                    label: Text('DECLINE',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ),
                  VerticalDivider(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    icon: Icon(Icons.check_rounded, size: 15),
                    onPressed: () async{

                      final resp = await updateMateRequest(widget.request.request!.id, 1);
                      if (resp == 200){
                        homeNav_key.currentState?.pop(true);
                      }else{
                        showSnackbar(context, "Failed to communicate with server, try again.");
                      }
                    },
                    label: Text('ACCEPT',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 49,
            backgroundColor: CupertinoColors.extraLightBackgroundGray,
            backgroundImage: NetworkImage(widget.request.pod.pet.photoUrl),
          ),
        ),
    ],

    );


  }

}



// appBar initializer

AppBar init_appBar(GlobalKey<NavigatorState> navKey) {
  return AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
              color: Colors.black
          ),
          elevation: 0,
          title: Text(
            'FETCH',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
  );
}

AppBar init_appBarBreed(GlobalKey<NavigatorState> navKey) {
  return AppBar(
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(
        color: Colors.black
    ),
    elevation: 0,
    title: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Align(
          child: Text(
          'FETCH',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
      ),
        ),
        Positioned(right: 0, top:-5, child:
        ColumnSuper(
          alignment: Alignment.topRight,
          innerDistance: -40,
          invert: true,
          children: [
            IconButton(icon: Icon(Icons.chat_rounded), onPressed: (){print('hello');},),
            Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),)
    ]
    ),
    centerTitle: true,
  );
}

void showSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(content: Text(message),
      backgroundColor: Colors.red);

  // Find the Scaffold in the Widget tree and use it to show a SnackBar!
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showNotification(BuildContext context, String message) {
  final snackBar = SnackBar(content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.green);

  // Find the Scaffold in the Widget tree and use it to show a SnackBar!
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}



Future<void> _showMyDialog(BuildContext context, petName) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Request'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(' ${petName}')
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0))),
            onPressed: () async{

            },child: Text('Confirm'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0))),
            onPressed: () async{
              Navigator.of(context).pop();
            },child: Text('Cancel'),
          )
        ],
      );
    },
  );
}

ShimmerOwnerPetCard(){
  return ListView.builder(
    itemCount: 3,
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 80,
          height: 10,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade300
          ),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Shimmer(
                gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey]),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: CupertinoColors.extraLightBackgroundGray,
                ),
              ),
              SizedBox(height: 20,),
              Shimmer(
                gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey]),
                child: Container(
                  height: 5,
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: CupertinoColors.extraLightBackgroundGray
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

ShimmerPetRequestBanner(BuildContext context){
  return ListView.builder(
    itemCount: 3,
    itemBuilder: (context, index){
      return Container(
        height: MediaQuery.of(context).size.height * 0.09,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: CupertinoColors.extraLightBackgroundGray,
        ),
        child: Row(
            children: [
              Shimmer(
              gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer(
                  gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                  child: Container(
                    height: 5,
                    width:  MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Shimmer(
                  gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                  child: Container(
                    height: 5,
                    width:  MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white
                    ),
                  ),
                ),
              ],
            )
      ]
        ),
      );
    },
  );
}

class PetMatchCard extends StatefulWidget {
  final PetPod pod;
  final PetPod sender;
  const PetMatchCard({Key? key, required this.pod, required this.sender}) : super(key: key);

  State<PetMatchCard> createState() => _PetMatchCardState();
}

class _PetMatchCardState extends State<PetMatchCard> {
  int distance = 0;
  String distanceText = "";
  String rating = "n/a";
  bool distanceLoading = true;

  calculateDistance(Location first, Location second){
    try {
      if ((first.latitude != 0.0) && (first.longtitude != 0.0)){
        if (second.latitude != 0.0 && second.longtitude != 0.0) {
          distance = Geolocator.distanceBetween(first.latitude, first.longtitude, second.latitude, second.longtitude).toInt();
        }else{
          distance = -1;
        }
      } else {
        distance = -1;

      }
      return distance;
    } catch (e) {
      print(e);
      distance = -1;
      return -1;
    }
  }

  generateDistance() async {
    calculateDistance(widget.pod.pet.location, widget.sender.pet.location);
    if (mounted) {
      setState(() {
        distanceLoading = false;
      });
    }
    if (distance != -1) {
      if (distance >= 1000) {
        distanceText = (distance / 1000).toInt().toString() + " km";
      } else {
        distanceText = distance.toInt().toString() + " m";
      }
    } else {
      distanceText = "not available";
    }
  }

  convertAgeToText(DateDuration petAge){
   return petAge.years > 1
        ? '${petAge.years} Years'
        '${petAge.months > 1 ? ' and ${petAge.months} Months' : petAge.months == 1 ? ' and ${petAge.months} Month' : '' }'
        : petAge.years == 1 ? '${petAge.years} Year' '${petAge.months > 1 ? ' and ${petAge.months} Months' : petAge.months == 1 ? ' and ${petAge.months} Month' : '' }'
        : petAge.months > 1 ? '${petAge.months} Months' : petAge.months == 1 ? '${petAge.months} Month' : ''
    ;
  }

  @override
  void initState() {
    generateDistance();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final petAge = AgeCalculator.dateDifference(fromDate: widget.pod.pet.birthdate, toDate: DateTime.now());
    final petVaccines = widget.pod.pet.vaccines.length/8;
    String petAgeText = convertAgeToText(petAge);
    if (widget.pod.pet.rateCount > 0){
      rating = (widget.pod.pet.rateSum/widget.pod.pet.rateCount).toStringAsFixed(1) + " / 5";
    }
    return GlassContainer(
      width: 65.w,
      height: 45.h,
      blur: 10,
      color: Colors.blueGrey.shade300,
      border: Border.fromBorderSide(BorderSide.none),
      borderRadius: BorderRadius.circular(30.sp),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(29.sp),
                child: Image.network(
                    widget.pod.pet.photoUrl,
                  height: 19.85.h,
                  width: double.infinity,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 19.85.h,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  }, fit: BoxFit.cover),
              ),
            ),
            // SizedBox(height: 1.5.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                        child: Text(
                          widget.pod.pet.name,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Spacer(),
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.sp),
                            color: Colors.blueGrey
                        ),
                        message: !widget.pod.pet.verified ? "Pet's owner is not verified." : "Pet's owner is verified." ,
                        child: Icon(widget.pod.pet.verified ?CupertinoIcons.checkmark_shield_fill : CupertinoIcons.exclamationmark_shield_fill,
                            color: widget.pod.pet.verified ? Colors.teal.shade900 : Colors.deepOrange.shade900),
                      ),
                      SizedBox(width: 2.w,),
                      Tooltip(
                        enableFeedback: true,
                        triggerMode: TooltipTriggerMode.tap,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.sp),
                            color: Colors.blueGrey
                        ),
                        message: widget.pod.pet.passport == "" ? 'Pet has no passport.' : 'Pet has passport.' ,
                        child: SizedBox(width: 5.w, height: 5.5.w,
                            child: Image(image: AssetImage("assets/verifiedDocuments.png",),
                              color: widget.pod.pet.passport == "" ? Colors.deepOrange.shade900:
                              Colors.teal.shade900, fit: BoxFit.fill,)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                    child: Text(
                      petAgeText,
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  CircleAvatar(
                      radius: 13.sp,
                      backgroundColor: Colors.blueGrey.shade100,
                      child: CircularPercentIndicator(
                          radius: 13.sp,
                          lineWidth: 3,
                          percent: petVaccines,
                          backgroundColor: Colors.blueGrey.shade300,
                          progressColor: Colors.blueGrey.shade700,
                          circularStrokeCap: CircularStrokeCap.round,

                          center: ImageIcon(AssetImage("assets/vaccineIcon.png"), color: Colors.black, size: 18.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Text(
                      '${widget.pod.pet.vaccines.length} ''${(widget.pod.pet.vaccines.length > 1 ? 'vaccines' : 'vaccine')}',
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                          onPressed: (){},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey.shade500,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0))),
                          icon: Icon(Icons.info_rounded),
                          label: Text('View full profile')
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_rounded, color: Colors.white60,),
                  distanceLoading ? Padding(
                    padding: const EdgeInsets.all(8*Checkbox.width*0.05),
                    child: SizedBox(height: 10, width: 10, child: CircularProgressIndicator()),
                  ) : Padding(
                    padding: const EdgeInsets.all(8*Checkbox.width*0.05),
                    child: Text(distanceText, style: TextStyle( fontFamily: "Poppins", fontWeight: FontWeight.w900, color: Colors.white60,
                        fontSize: 11*width*0.0027)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );;
  }
}

class PetView extends StatefulWidget {
  final PetPod profile;
  final List<PetPod> ownerPets;
  int? location;
  List<PetPod> rootPets;
  PetView({Key? key, required this.profile, required this.ownerPets, this.location, required this.rootPets}) : super(key: key);

  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> {
  int distance = 0;
  String distanceText = "";
  bool distanceLoading = true;
  bool tapped = false;

  generateDistance() async{
    if (distance >= 1000){
      distanceText = (distance/1000).toInt().toString() + " km";
    }else if (distance != -1){
      distanceText = distance.toInt().toString() + " m";
    }else{
      distanceText = "not available";
    }
    if (this.mounted){
      setState(() {
        distanceLoading = false;
      });
    }

  }
  @override
  void initState(){
    generateDistance();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final petAge = AgeCalculator.dateDifference(fromDate: widget.profile.pet.birthdate, toDate: DateTime.now());
    final petVaccines = widget.profile.pet.vaccines.length/8;
    String ratingText;
    if (widget.profile.pet.rateCount > 0){
      ratingText = (widget.profile.pet.rateSum ~/ widget.profile.pet.rateCount).toString() + ' / 5';
    }else{
      ratingText = 'n/a';
    }

    String petText = "";
    if (petAge.years > 0){
      petText = petText + petAge.years.toString() + "";
      if (petAge.months > 0){
        petText = petText +"."+ petAge.months.toString() + " years";
      }else{
        petText = petText + " years";
      }
    }else{
      if (petAge.months > 0){
        petText = petText + petAge.months.toString() + " months";
      }
    }
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.blueGrey.shade900,
      ),
      child: Column(

        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            height: height*0.215,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: CupertinoColors.extraLightBackgroundGray,
              border: Border.all(width: 2, color:  CupertinoColors.extraLightBackgroundGray),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius : 10*width*0.007,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(widget.profile.pet.photoUrl),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            widget.profile.pet.name,
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w800,
                                color: Colors.blueGrey.shade900),
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.star_rate_rounded, color: CupertinoColors.activeOrange),
                            Padding(
                              padding: const EdgeInsets.all(3),
                              child: Text(
                                ratingText,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w800,
                                    color: Colors.blueGrey.shade600),
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3*Checkbox.width*0.05),
                          child: Text(petText, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.blueGrey.shade700,
                              fontSize: 11*width*0.0027)),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 3*height*0.005,),
                FittedBox(
                  child: Text(
                    widget.profile.pet.breed,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: height*0.008,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blueGrey.shade900,
                        ),
                        child:  Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ImageIcon(AssetImage("assets/vaccineIcon.png"), color: Colors.white, size: 18),
                                SizedBox(width: 5),
                                CircularPercentIndicator(
                                  radius: 9,
                                  lineWidth: 2,
                                  percent: petVaccines,
                                  backgroundColor: Colors.blueGrey.shade900,
                                  progressColor: Colors.white,
                                )
                              ]),
                        )
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(widget.profile.pet.isMale ? Icons.male_rounded : Icons.female_rounded,
                            color: widget.profile.pet.isMale ? Colors.blue : Colors.pink),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      distanceLoading ? Padding(
                        padding: const EdgeInsets.all(8*Checkbox.width*0.05),
                        child: SizedBox(height: 10, width: 10, child: CircularProgressIndicator()),
                      ) : Padding(
                        padding: const EdgeInsets.all(8*Checkbox.width*0.05),
                        child: Text(distanceText, style: TextStyle( fontFamily: "Poppins", fontWeight: FontWeight.w900, color: Colors.blueGrey.shade900,
                            fontSize: 11*width*0.0027)),
                      ),
                      Spacer(),
                      widget.profile.pet.verified ? Icon(Icons.verified_user_sharp, color: Colors.green,) : Icon(CupertinoIcons.xmark_shield_fill, color: Colors.redAccent,),
                      SizedBox(width: 10*Checkbox.width*0.05,),
                      Container(width: 20, height: 20,
                          child: Image(image: AssetImage("assets/verifiedDocuments.png"),
                            fit: BoxFit.fill, color: widget.profile.pet.passport == "" ? Colors.redAccent : Colors.green,)),
                    ],
                  ),
                )
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: CupertinoColors.extraLightBackgroundGray,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0))),
            onPressed:(){
            },
            icon: Icon(CupertinoIcons.heart_fill, color: Colors.black, size: 9*width*0.003,),
            label: Text('Send Request', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 8*width*0.003),),
          ),
        ],
      ),
    );
  }
  Future<int> _customSheet(BuildContext context) async{
    int resp = -1;
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder){
          List<PetPod> goodPets = <PetPod>[];

          for (PetPod p in widget.ownerPets) {
            // if (p.pet.breed == mateItem.sender_pet.pet.breed) {
            goodPets.add(p);
            // }
          }
          final height = MediaQuery
              .of(context)
              .size
              .height;
          final width = MediaQuery
              .of(context)
              .size
              .width;
          return goodPets.length > 0 ? Container(height: height * 0.5,
                child: Column(
                  children: [
                    Text("Choose a pet \nto send the request",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: width*0.04,
                        color: Colors.white,
                      ), textAlign: TextAlign.center,),
                    SizedBox(height: height*0.02,),
                    Container(
                      height: height*0.15,
                      alignment: Alignment.center,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: goodPets.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            PetPod temPet = goodPets[index].copyWith(isSelected: false);
                            return InkWell(
                                onTap: (){
                                  homeNav_key.currentState?.pop(index);
                                },
                                child: CustomPet(pod: temPet));
                          }),
                    ),
                  ],
                )) : Container(
            height: height*0.6,
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.9)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sorry",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: width*0.04,
                            color: Colors.blueGrey.shade900.withOpacity(0.9),
                          ), textAlign: TextAlign.center,),
                        SizedBox(height: 10,),
                        Text("Your pets don't share same breed",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: width*0.035,
                            color: Colors.blueGrey.shade900.withOpacity(0.9),
                          ), textAlign: TextAlign.center,),
                        SizedBox(height: 20,),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade300.withOpacity(0.9),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                )
                            ),
                            onPressed: (){
                              homeNav_key.currentState?.pop();
                            }, child: Text('I understand'))
                      ],
                    ),
                  )
                ],
              ),
            );
        }
    ).then((value) async{
     if (value != null){
       resp =  value;
     }else{
       resp = -1;
     }

    });
    return resp;
  }
}


// OCR Result Parser
IdResponse idResponseFromJson(String str) => IdResponse.fromJson(json.decode(str));

String idResponseToJson(IdResponse data) => json.encode(data.toJson());

class IdResponse {
  IdResponse({
    required this.parsedResults,
    required this.ocrExitCode,
    required this.isErroredOnProcessing,
    required this.processingTimeInMilliseconds,
    required this.searchablePdfurl,
  });

  List<ParsedResult> parsedResults;
  int ocrExitCode;
  bool isErroredOnProcessing;
  String processingTimeInMilliseconds;
  String searchablePdfurl;

  factory IdResponse.fromJson(Map<String, dynamic> json) => IdResponse(
    parsedResults: List<ParsedResult>.from(json["ParsedResults"].map((x) => ParsedResult.fromJson(x))),
    ocrExitCode: json["OCRExitCode"],
    isErroredOnProcessing: json["IsErroredOnProcessing"],
    processingTimeInMilliseconds: json["ProcessingTimeInMilliseconds"],
    searchablePdfurl: json["SearchablePDFURL"],
  );

  Map<String, dynamic> toJson() => {
    "ParsedResults": List<dynamic>.from(parsedResults.map((x) => x.toJson())),
    "OCRExitCode": ocrExitCode,
    "IsErroredOnProcessing": isErroredOnProcessing,
    "ProcessingTimeInMilliseconds": processingTimeInMilliseconds,
    "SearchablePDFURL": searchablePdfurl,
  };
}

class ParsedResult {
  ParsedResult({
    required this.textOverlay,
    required this.textOrientation,
    required this.fileParseExitCode,
    required this.parsedText,
    required this.errorMessage,
    required this.errorDetails,
  });

  TextOverlay textOverlay;
  String textOrientation;
  int fileParseExitCode;
  String parsedText;
  String errorMessage;
  String errorDetails;

  factory ParsedResult.fromJson(Map<String, dynamic> json) => ParsedResult(
    textOverlay: TextOverlay.fromJson(json["TextOverlay"]),
    textOrientation: json["TextOrientation"],
    fileParseExitCode: json["FileParseExitCode"],
    parsedText: json["ParsedText"],
    errorMessage: json["ErrorMessage"],
    errorDetails: json["ErrorDetails"],
  );

  Map<String, dynamic> toJson() => {
    "TextOverlay": textOverlay.toJson(),
    "TextOrientation": textOrientation,
    "FileParseExitCode": fileParseExitCode,
    "ParsedText": parsedText,
    "ErrorMessage": errorMessage,
    "ErrorDetails": errorDetails,
  };
}

class TextOverlay {
  TextOverlay({
    required this.lines,
    required this.hasOverlay,
    required this.message,
  });

  List<Line> lines;
  bool hasOverlay;
  String message;

  factory TextOverlay.fromJson(Map<String, dynamic> json) => TextOverlay(
    lines: List<Line>.from(json["Lines"].map((x) => Line.fromJson(x))),
    hasOverlay: json["HasOverlay"],
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "Lines": List<dynamic>.from(lines.map((x) => x.toJson())),
    "HasOverlay": hasOverlay,
    "Message": message,
  };
}

class Line {
  Line({
    required this.lineText,
    required this.words,
    required this.maxHeight,
    required this.minTop,
  });

  String lineText;
  List<Word> words;
  int maxHeight;
  int minTop;

  factory Line.fromJson(Map<String, dynamic> json) => Line(
    lineText: json["LineText"].toString(),
    words: List<Word>.from(json["Words"].map((x) => Word.fromJson(x))),
    maxHeight: json["MaxHeight"],
    minTop: json["MinTop"],
  );

  Map<String, dynamic> toJson() => {
    "LineText": lineText,
    "Words": List<dynamic>.from(words.map((x) => x.toJson())),
    "MaxHeight": maxHeight,
    "MinTop": minTop,
  };
}

class Word {
  Word({
    required this.wordText,
    required this.left,
    required this.top,
    required this.height,
    required this.width,
  });

  String wordText;
  int left;
  int top;
  int height;
  int width;

  factory Word.fromJson(Map<String, dynamic> json) => Word(
    wordText: json["WordText"],
    left: json["Left"],
    top: json["Top"],
    height: json["Height"],
    width: json["Width"],
  );

  Map<String, dynamic> toJson() => {
    "WordText": wordText,
    "Left": left,
    "Top": top,
    "Height": height,
    "Width": width,
  };
}


Future scanID() async {
  String imagePath = "";

  try {
    //Make sure to await the call to detectEdge.
    await EdgeDetection.detectEdge(imagePath, canUseGallery: false);
    return imagePath;
  } catch (e) {
    print(e);
    imagePath = '';
    return imagePath;
  }
}

final kTitleTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final IconData icon2;
  final String text;
  final bool hasNavigation;

  const ProfileListItem({
    required this.icon,
    required this.text,
    required this.icon2,
    this.hasNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey.shade200,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              this.icon,
              size: 25,
              color: Color.alphaBlend(Colors.black, Colors.black),
            ),
            SizedBox(width: 15),
            Text(
              this.text,
              style: kTitleTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: Colors.black),
            ),
            Spacer(),
            if (this.hasNavigation)
              Icon(
                this.icon2,
                size: 25,
                color: Color.alphaBlend(Colors.black, Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}


Widget buildStamp({double angle = 0, required Color color, required String text}){
  final HW = 100.h*100.w;
  return Container(
    width: 20.w,
    height: 5.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15.sp),
      border: Border.all(color: color, width: 5)
    ),
    margin: EdgeInsets.all(5),
    child: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );


}

Widget buildStamps({required ValueNotifier<sliderStatus> notifier}){

  return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (BuildContext context, sliderStatus value, Widget? widget){
        switch(value){
          case sliderStatus.up:
            return Container();
          case sliderStatus.left:
            return buildStamp(color: Colors.redAccent, text: "Nope");
          case sliderStatus.right:
            return buildStamp(color: Colors.redAccent, text: "Like");
          case sliderStatus.none:
            return Container();
        }
      });
}