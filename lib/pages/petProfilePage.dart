import 'dart:convert';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:age_calculator/age_calculator.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../APILibraries.dart';
import '../FETCH_wdgts.dart';
import '../JsonObj.dart';
import '../configuration.dart';

class PetProfilePage extends StatefulWidget{
  MateItem pod;
  final int senderState;
  final List<PetPod> ownerPets;
  PetProfilePage({Key? key, required this.pod, required this.ownerPets, required this.senderState}) : super(key: key);

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> with TickerProviderStateMixin {

  String distanceText = "N/A";
  String petAge = "";
  String rating = "No Rating";
  final _controller = MultiSelectController();
  List<MultiSelectCard> items = <MultiSelectCard>[];
  bool pdfReady = false;
  late AnimationController animController;
  late Animation animation;
  late PDFDocument document;
  UserPod? ownerPod;
  int petState = 0;

  initPet() async{
    if (widget.pod.status == -1){
      petState = 1;
    }else{
      petState = widget.pod.status;
    }

    if (widget.pod.sender_pet.distance >= 1000){
      distanceText = (widget.pod.sender_pet.distance/1000).toInt().toString() + " Kilometers";
    }else{
      distanceText = (widget.pod.sender_pet.distance).toInt().toString() + " meters";
    }

    final age = AgeCalculator.age(widget.pod.sender_pet.pet.birthdate);
    if (age.years > 1){
      petAge += age.years.toString() + " Years\n";
    }else if (age.years == 1){
      petAge += age.years.toString() + " Year\n";
    }
    if (age.months > 1){
      petAge += age.months.toString() + " Months";
    }else if (age.months == 1){
      petAge += age.months.toString() + " Month\n";
    }

    for (MapEntry entry in vaccineFList.entries){
      final vaccine = MultiSelectCard(value: entry.key, label: entry.value,
          selected: widget.pod.sender_pet.pet.vaccines.contains(entry.key) ? true : false);
      items.add(vaccine);
    }

    if (widget.pod.sender_pet.pet.rateCount > 0){
      rating = (widget.pod.sender_pet.pet.rateSum/widget.pod.sender_pet.pet.rateCount).toStringAsFixed(1) + " / 5";
    }
    setState(() {

    });
  }
  initPDF() async{
    if (widget.pod.sender_pet.pet.passport != ""){
      document = await PDFDocument.fromURL(widget.pod.sender_pet.pet.passport);
      setState(() {
        pdfReady = true;
      });
      animController.forward();
    }

  }

  @override
  void initState() {
    initPet();
    animController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = CurvedAnimation(parent: animController, curve: Curves.easeIn);
    initPDF();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: init_appBar(BA_key),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10,10,10,0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(widget.pod.sender_pet.pet.name, style: TextStyle(
                            fontSize: width*0.06,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey.shade900
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: FittedBox(child:  Row(
                          children: [
                            Icon(Icons.location_pin, color: Colors.blueGrey.shade700,),
                            Text(distanceText,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.blueGrey.shade700
                                )),
                          ],
                        )),
                      ),
                      if (petState == 2) GestureDetector(
                        onTap: ()async{
                         if (ownerPod == null){
                           try{
                             final resp = jsonEncode(await SupabaseCredentials.supabaseClient
                                 .from('users')
                                 .select('*').eq('id', widget.pod.sender_pet.pet.ownerId).single() as Map);
                             ownerPod = userPodFromJson(resp);
                           }catch (e){

                           }
                         }
                         _ownerInfo();

                        },
                        child: Container(
                          height: height*0.054,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.circle_outlined, color: Colors.redAccent,),
                                SizedBox(width: 10,),
                                Text("Owner Information",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blueGrey
                                    )),
                                SizedBox(width: 15,),
                                Icon(CupertinoIcons.arrowshape_turn_up_right, size: width*0.04, color: Colors.blueGrey,)
                              ],
                            ),
                          ),
                        ),
                      ) else if (petState == 0) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: ()async {
                              final resp = await updateMateRequest(widget.pod.request_id, 2);
                              if (resp == 200){
                                widget.pod.status = 2;
                                petState = 2;
                                setState(() {

                                });

                              }else{
                                showSnackbar(context, "Failed to communicate with server, try again.");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                )
                            ),
                            icon:  Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: width*0.03,),
                            label: Text('Accept', style: TextStyle(
                                color: Colors.white,
                                fontSize: width*0.024
                            ),),
                          ),
                          // SizedBox(width: width*0.02,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.blueGrey, radius: width*0.04,
                              child: CircleAvatar(radius: width*0.04-1,
                                backgroundImage: NetworkImage(widget.ownerPets[0].pet.photoUrl),),),
                          ),
                          ElevatedButton.icon(
                            onPressed: ()async {
                              final resp = await updateMateRequest(widget.pod.request_id, 1);
                              if (resp == 200){
                                widget.pod.status = 1;
                                petState = 1;
                                setState(() {

                                });
                              }else{
                                showSnackbar(context, "Failed to communicate with server, try again.");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                )
                            ),
                            icon:  Icon(CupertinoIcons.xmark, color: Colors.black, size: width*0.03,),
                            label: Text('Decline', style: TextStyle(
                                color: Colors.black,
                                fontSize: width*0.024
                            ),),
                          ),
                        ],
                      ) else ElevatedButton.icon(
                        onPressed: ()async {
                          // _customSheet();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade300,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0)
                            )
                        ),
                        icon:  Icon(CupertinoIcons.heart_fill, color: Colors.white, size: width*0.03,),
                        label: Text('Ask to Mate', style: TextStyle(
                            color: Colors.white,
                            fontSize: width*0.024
                        ),),
                      )
                    ],
                  ),
                  Spacer(),
                  ColumnSuper(
                    innerDistance: -19,
                    children: [
                      CircleAvatar(
                        radius: height*0.06,
                        backgroundColor: CupertinoColors.extraLightBackgroundGray,
                        child: CircleAvatar(
                          radius: height*0.052,
                          backgroundImage: NetworkImage(widget.pod.sender_pet.pet.photoUrl)
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.extraLightBackgroundGray,
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(Icons.verified_user_rounded, size: 18, color: Colors.blueGrey.shade600,),
                        ),
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: height*0.02,),
            Container(

              height: height*0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: width*0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Breed",
                          style: TextStyle(
                              fontSize: width*0.028,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade500
                          ),),
                        SizedBox(height: height*0.008,),
                        Text(widget.pod.sender_pet.pet.breed,
                          style: TextStyle(
                              fontSize: width*0.028,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueGrey.shade700
                          ), maxLines: 2, overflow: TextOverflow.visible, textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                  Container(
                    width: width*0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Gender",
                          style: TextStyle(
                              fontSize: width*0.028,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade500
                          ),),
                        SizedBox(height: height*0.008,),
                        Text(widget.pod.sender_pet.pet.isMale ? "Male" : "Female",
                          style: TextStyle(
                              fontSize: width*0.028,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueGrey.shade700
                          ), maxLines: 2, overflow: TextOverflow.visible,),
                      ],
                    ),
                  ),
                  Container(
                    width: width*0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Age",
                          style: TextStyle(
                              fontSize: width*0.028,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade500
                          ),),
                        SizedBox(height: height*0.008,),
                        Text(petAge,
                          style: TextStyle(
                              fontSize: width*0.028,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueGrey.shade700
                          ), maxLines: 2, overflow: TextOverflow.visible,  textAlign: TextAlign.center),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        alignment: Alignment.topLeft,
                        child: Text("Vaccinations",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: width*0.03,
                              color: Colors.blueGrey.shade700,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: IgnorePointer(
                            ignoring: true,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:MultiSelectContainer(
                                  itemsDecoration: MultiSelectDecorations(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      selectedDecoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(colors: [
                                          Colors.blueGrey.shade600,
                                          Colors.blueGrey.shade900
                                        ])),
                                      ),
                                  prefix: MultiSelectPrefix(
                                      selectedPrefix: Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                      ),
                                  items: items,
                                  controller: _controller,
                                  onChange: (allSelectedItems, selectedItem) {
                                  }),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          pdfReady ? Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(10,10,10,10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Passport",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: width*0.04,
                                          color: Colors.blueGrey.shade700,
                                        )),
                                    Spacer(),
                                    Icon(Icons.star_rounded, color: Colors.orange,),
                                    SizedBox(width: 5,),
                                    Text(rating,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: width*0.03,
                                        color: Colors.blueGrey.shade700,
                                      ), textAlign: TextAlign.end,),


                                  ],
                                ),
                              ),
                              Container(
                                height: 500,
                                child: FadeTransition(
                                    opacity: animController,
                                    child: PDFViewer(document: document)),
                              ),
                            ],
                          ) :
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10,0,10,10),
                            child: Row(
                              children: [
                                Icon(Icons.cancel_outlined, color: Colors.blueGrey,),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(5,0,0,0),
                                  child: Text('Passport Unavailable', style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w700
                                  ),),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ownerInfo(){
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
          final ownerData = ownerPod!;
          return Container(height: height * 0.5,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: CupertinoColors.extraLightBackgroundGray,
                              child: CircleAvatar(
                                backgroundColor: CupertinoColors.extraLightBackgroundGray,
                                child:  ownerData.photoUrl == "" ? Icon(Icons.account_circle_rounded) : null,
                                backgroundImage: ownerData.photoUrl == "" ? null : NetworkImage(ownerData.photoUrl),
                              ),
                            ),
                            Text("${ownerData.firstName} ${ownerData.lastName}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: width*0.04,
                                  color: Colors.blueGrey.shade100,
                                )),
                          ],
                        ),
                        SizedBox(height: height*0.02,),
                        Container(
                          height: height*0.15,
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        }
    ).then((value) async{

    });
  }
}
