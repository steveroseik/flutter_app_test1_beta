import 'dart:async';
import 'dart:convert';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:age_calculator/age_calculator.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/DataPass.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../APILibraries.dart';
import '../FETCH_wdgts.dart';
import '../JsonObj.dart';
import '../cacheBox.dart';
import '../configuration.dart';
import 'dart:io' show Platform;
import 'dart:ui';



class PetProfilePage extends StatefulWidget{
  MateItem pod;
  final List<PetPod> ownerPets;
  PetProfilePage({Key? key, required this.pod, required this.ownerPets}) : super(key: key);

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
  late CacheBox cacheBox;
  int distance = -1;
  UserPod? ownerPod;
  final petState = ValueNotifier<profileState>(profileState.noFriendship);
  bool ownerVerified = false;
  bool tapped = false;
  late Timer _timer;
  int timer_counter=5;
  late OverlayEntry loading = initLoading(context);

  startTimer(){
    const interval = Duration(seconds: 1);
    _timer = Timer.periodic(interval, (timer) {
      if (timer_counter == 0){
        if (this.mounted) {
          setState(() {
            _timer.cancel();
          });
        }

      }else{
        timer_counter--;
        if ( widget.pod.pod.distance > -1){
          distance = widget.pod.pod.distance;
          if (widget.pod.pod.distance >= 1000){
            distanceText = (widget.pod.pod.distance/1000).toInt().toString() + " Kilometers";
          }else{
            distanceText = (widget.pod.pod.distance).toInt().toString() + " meters";
          }
         if (mounted){
           setState(() {
           });
         }
        }else{
          print('no distance');
        }
      }
    });

  }

  initPetState(){
    requestState? state = widget.pod.request?.status;
    String? receiverPet = widget.pod.request?.receiverPet;
    print('${state}, ${receiverPet}, ${widget.pod.pod.pet.name}');


    if (state != null && receiverPet != null){
      switch(state){

        case requestState.pending:
          if (receiverPet == widget.pod.pod.pet.id){
            petState.value = profileState.requested;
          }else{
            petState.value = profileState.pendingApproval;
          }
          break;
        case requestState.denied:
          petState.value = profileState.noFriendship;
          break;
        case requestState.accepted:
          petState.value = profileState.friend;
          break;
        case requestState.undefined:
          petState.value = profileState.noFriendship;
          break;
      }
    }else{
      petState.value = profileState.noFriendship;
    }

  }
  initPet() async{

    initPetState();
    distance = widget.pod.pod.distance;
    if ( distance > -1){
      if (widget.pod.pod.distance >= 1000){
        distanceText = (widget.pod.pod.distance/1000).toInt().toString() + " Kilometers";
      }else{
        distanceText = (widget.pod.pod.distance).toInt().toString() + " meters";
      }
    }else{
      startTimer();
    }


    final age = AgeCalculator.age(widget.pod.pod.pet.birthdate);
    if (age.years > 1){
      petAge += age.years.toString() + " Years ";
    }else if (age.years == 1){
      petAge += age.years.toString() + " Year ";
    }
    if (age.months > 1){
      petAge += age.months.toString() + " Months";
    }else if (age.months == 1){
      petAge += age.months.toString() + " Month ";
    }

    for (MapEntry entry in vaccineFList.entries){
      final vaccine = MultiSelectCard(value: entry.key, label: entry.value,
          selected: widget.pod.pod.pet.vaccines.contains(entry.key) ? true : false);
      items.add(vaccine);
    }

    if (widget.pod.pod.pet.rateCount > 0){
      rating = (widget.pod.pod.pet.rateSum/widget.pod.pod.pet.rateCount).toStringAsFixed(1) + " / 5";
    }

    ownerVerified = widget.pod.pod.pet.verified;
    setState(() {

    });
  }
  initPDF() async{
    if (widget.pod.pod.pet.passport != ""){
      document = await PDFDocument.fromURL(widget.pod.pod.pet.passport);
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
    cacheBox = DataPassWidget.of(context);
    return Scaffold(
      appBar: init_appBar(homeNav_key),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10,10,10,0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(widget.pod.pod.pet.name, style: TextStyle(
                                fontSize: width*0.06,
                                fontWeight: FontWeight.w800,
                                color: Colors.blueGrey.shade900
                            ),),
                          ),
                          SizedBox(height: 1.h,),
                          ValueListenableBuilder<profileState>(
                              valueListenable: petState,
                              builder: (BuildContext context, profileState value, Widget? widget){
                                switch(value){
                                  case profileState.pendingApproval: {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: tapped ? null : ()async {
                                            setState(() {
                                              tapped = true;
                                            });

                                            final resp = await updateMateRequest(this.widget.pod.request!.id, requestState.accepted.index);
                                            if (resp == 200){
                                              this.widget.pod.request!.status = requestState.accepted;
                                              petState.value = profileState.friend;
                                              List<MateRequest> c = cacheBox.cachedReceivedNotif;
                                              print(c.firstWhere((e) => e.id == this.widget.pod.request!.id).status);
                                              addNewPetFriend(this.widget.pod.request!, cacheBox);
                                              setState(() {
                                              });
                                            }else{
                                              showSnackbar(context, "Failed to communicate with server, try again.");
                                            }
                                            setState(() {
                                              tapped = false;
                                            });
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
                                              backgroundImage: NetworkImage(this.widget.ownerPets[0].pet.photoUrl),),),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: tapped ? null : ()async {
                                            setState(() {
                                              tapped = true;
                                            });
                                            final resp = await updateMateRequest(this.widget.pod.request!.id, requestState.denied.index);
                                            if (resp == 200){
                                              this.widget.pod.request!.status = requestState.denied;
                                              petState.value = profileState.noFriendship;
                                              setState(() {
                                              });
                                            }else{
                                              showSnackbar(context, "Failed to communicate with server, try again.");
                                            }
                                            setState(() {
                                              tapped = false;
                                            });
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
                                    );
                                  }
                                  case profileState.requested: {
                                    return ElevatedButton.icon(
                                      onPressed:tapped ? null :  ()async {
                                        setState(() {
                                          tapped = true;
                                        });
                                        final resp = await updateMateRequest(this.widget.pod.request!.id, requestState.undefined.index);
                                        if (resp == 200){
                                          this.widget.pod.request!.status = requestState.undefined;
                                          petState.value = profileState.noFriendship;
                                          setState(() {
                                          });
                                        }else{
                                          showSnackbar(context, "Failed to communicate with server, try again.");
                                        }
                                        setState(() {
                                          tapped = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey.shade800,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0)
                                          )
                                      ),
                                      icon:  Icon(CupertinoIcons.heart_slash_fill, color: Colors.white, size: width*0.03,),
                                      label: Text('Cancel Request', style: TextStyle(
                                          color: Colors.white,
                                          fontSize: width*0.024
                                      ),),
                                    );
                                  }
                                  case profileState.friend: {
                                    return ElevatedButton(onPressed: () {
                                      showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                          context: context, builder: (_) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(25.sp), topRight: Radius.circular(25.sp)),
                                            color: Colors.blueGrey.shade900
                                          ),
                                          height: 10.h,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 1.h),
                                              ListTile(
                                                onTap: (){
                                                  // REMOVEEE
                                                },
                                                leading: Icon(Icons.remove_circle_rounded, color: Colors.blueGrey.shade400),
                                                title: Text('Remove from my circle', style: TextStyle(
                                                  color: Colors.red.shade200,
                                                  fontWeight: FontWeight.w500
                                                ),),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                    },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey.shade700,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0)
                                          )
                                      ),
                                      child: Row(
                                        children: [
                                          Text('Mates', style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp
                                          ),),
                                          SizedBox(width: 3.w),
                                          Icon(CupertinoIcons.chevron_down, size: 10.sp)
                                        ],
                                      ),
                                    );
                                  }
                                  case profileState.noFriendship: return ElevatedButton.icon(
                                    onPressed:tapped ? null :  ()async {
                                      setState(() {
                                        tapped = true;
                                      });

                                      final petInd = await _customSheet(context);
                                      final uid = FirebaseAuth.instance.currentUser!.uid;
                                      if (petInd != -1){
                                        if (uid == this.widget.ownerPets[petInd].pet.ownerId){
                                          final newRequest = await sendMateRequest(this.widget.ownerPets[petInd].pet.ownerId,
                                              this.widget.pod.pod.pet.ownerId,
                                              this.widget.ownerPets[petInd].pet.id,
                                              this.widget.pod.pod.pet.id);
                                          if (newRequest != null){
                                            this.widget.pod.request = newRequest;
                                            petState.value = profileState.requested;
                                            showNotification(context, 'Request sent successfully');
                                          }else{
                                            showSnackbar(context, 'Failed to send request');
                                          }
                                        }else{
                                          showSnackbar(context, 'Unexpected behavior!');
                                        }
                                      }

                                      setState(() {
                                        tapped = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade300,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0)
                                        )
                                    ),
                                    icon:  Icon(CupertinoIcons.heart_fill, color: Colors.white, size: width*0.03,),
                                    label: Text('Send Request', style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width*0.024
                                    ),),
                                  );
                                }
                              }),
                        ],
                      ),
                      Spacer(),
                      ColumnSuper(
                        innerDistance: -19,
                        children: [
                          CircleAvatar(
                            radius: height*0.06,
                            backgroundColor: CupertinoColors.extraLightBackgroundGray,
                            child: InkWell(
                              onTap: (){
                                homeNav_key.currentState?.push(
                                    PageRouteBuilder(
                                        opaque: true,
                                        pageBuilder: (BuildContext context, _, __) {
                                          return InkWell(
                                            onTap: (){
                                              homeNav_key.currentState?.pop();
                                            },
                                            child: Scaffold(
                                              body: InteractiveViewer(
                                                child: Center(
                                                  child: Hero(
                                                    tag: "petProfileTagUnique",
                                                    child: Image.network(widget.pod.pod.pet.photoUrl),
                                                  ),
                                                ),
                                              ),
                                            )
                                          );
                                        },
                                      transitionsBuilder: (BuildContext context,  Animation<double> anim, Animation<double> anim2, Widget child){
                                          return FadeTransition(
                                              opacity: anim,
                                              child: child);
                                      }
                                    )
                                );
                              },
                              child: Hero(
                                tag: 'petProfileTagUnique',
                                child: CircleAvatar(
                                    radius: height*0.052,
                                    backgroundImage: NetworkImage(widget.pod.pod.pet.photoUrl)
                                ),
                              ),
                            ),
                          ),
                          ownerVerified ? Container(
                            decoration: BoxDecoration(
                                color: CupertinoColors.extraLightBackgroundGray,
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(Icons.verified_user_rounded, size: 18, color: Colors.green,),
                            ),
                          ) :  Container(
                            decoration: BoxDecoration(
                                color: CupertinoColors.extraLightBackgroundGray,
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(CupertinoIcons.exclamationmark_shield_fill, size: 18, color: Colors.orange,),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Visibility(
                    visible: distance == -1,
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_pin, color: Colors.blueGrey.shade700,),
                          SizedBox(width: 2.w),
                          Text(distance == -1 ? "Not available" : distanceText == '' ? 'Not available' : distanceText,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blueGrey.shade700
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ValueListenableBuilder(
                      valueListenable: petState,
                      builder: (BuildContext context, profileState value, Widget? widget){
                        return Visibility(
                            visible: value == profileState.friend,
                            child: Container(
                              width: double.infinity,
                              height: 5.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.sp),
                                gradient: LinearGradient(
                                  colors: [Colors.greenAccent.shade700, Colors.blueGrey.shade600]
                                )
                              ),
                              child: ElevatedButton.icon(onPressed: tapped ? null : () async
                              {
                                if (ownerPod == null) {
                                  if (!loading.mounted) {
                                    OverlayState? overlay =
                                    Overlay.of(context);
                                    overlay.insert(loading);
                                    setState(() {

                                    });
                                  }
                                  // Fix
                                  try {
                                    final resp = await FirebaseFirestore
                                        .instance.collection('users')
                                        .doc(
                                        this.widget.pod.pod.pet.ownerId)
                                        .get();
                                    ownerPod = userPodFromDoc(resp);
                                  } catch (e) {
                                    print('petPageError: $e');
                                  }
                                }
                                if (loading.mounted) {
                                  loading.remove();
                                }
                                setState(() {

                                });
                                _ownerInfo();
                              },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.sp)
                                    )
                                ),
                                icon:  Icon(Icons.account_circle_sharp),
                                label: Text('Contact Owner', style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp
                                ),),
                              ),
                            ));
                      }
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 2.w,
                            runSpacing: 2.w,
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade100]),
                                    borderRadius:
                                    BorderRadius.circular(
                                        20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(1, 1), // changes position of shadow
                                    ),
                                  ],),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(widget.pod.pod.pet.isMale ? Icons.male_rounded : Icons.female_rounded, color: widget.pod.pod.pet.isMale ? Colors.blue.shade600 : Colors.pink.shade600),
                                    SizedBox(width: 2.w),
                                    Text(widget.pod.pod.pet.breed, style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.blueGrey.shade700
                                    ), maxLines: 2, overflow: TextOverflow.visible,  textAlign: TextAlign.center)
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade100]),
                                  borderRadius:
                                  BorderRadius.circular(
                                      20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(1, 1), // changes position of shadow
                                    ),
                                  ],),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(CupertinoIcons.calendar_circle_fill, color: Colors.white),
                                    SizedBox(width: 2.w),
                                    Text(petAge, style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.blueGrey.shade700
                                    ), maxLines: 2, overflow: TextOverflow.visible,  textAlign: TextAlign.center)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
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

  void _ownerInfo() async{
    final prefs = await SharedPreferences.getInstance();
    double? uLat = prefs.getDouble('lat');
    double? uLong = prefs.getDouble('long');
    int distance = -1;
    if (mounted){
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
            if (uLat != null && uLong != null){
              if (uLat > 0.0 && uLong > 0 && ownerData.location.latitude > 0 && ownerData.location.longtitude > 0 ){
                distance = Geolocator.distanceBetween(uLat, uLong, ownerData.location.latitude, ownerData.location.longtitude).toInt();
              }
            }

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
                          Row(
                            children: [
                              CircleAvatar(
                                radius: width*0.05,
                                backgroundColor: CupertinoColors.extraLightBackgroundGray,
                                child: CircleAvatar(
                                  radius: width*0.5,
                                  backgroundColor: CupertinoColors.extraLightBackgroundGray,
                                  backgroundImage: ownerData.photoUrl == "" ? null : NetworkImage(ownerData.photoUrl),
                                  child:  ownerData.photoUrl == "" ? LayoutBuilder(builder: (context, constraint) {
                                    return Icon(Icons.account_circle_rounded, size: constraint.biggest.height);
                                  }) : null,
                                ),
                              ),
                              SizedBox(width: width*0.02,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${ownerData.firstName.capitalize()} ${ownerData.lastName.capitalize()}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: width*0.04,
                                        color: Colors.blueGrey.shade50,
                                      )),
                                  Text("${ownerData.city.capitalize()}, ${ownerData.country.capitalize()}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: width*0.035,
                                        color: Colors.blueGrey.shade100,
                                      )),
                                ],
                              ),
                              Spacer(),
                              ownerData.type == 1 ? Icon(CupertinoIcons.shield_fill, color: Colors.green,) : Icon(CupertinoIcons.exclamationmark_shield_fill, color: Colors.orange,),
                            ],
                          ),

                        ],
                      ),
                    ),
                    Container(
                      width: width*0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: tapped ? null : () async{
                              setState(() {
                                tapped = true;
                              });
                              ClipboardData data = ClipboardData(text: '+20${ownerData.phone}');
                              await Clipboard.setData(data);
                              showNotification(context, 'Copied!');
                              setState(() {
                                tapped = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade200,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                )
                            ),
                            icon:  Icon(Icons.copy_rounded, color: Colors.blueGrey.shade800, size: width*0.040,),
                            label: Text('Copy', style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: width*0.03
                            ),),
                          ),
                          ElevatedButton.icon(
                            onPressed: tapped ? null : ()async {
                              setState(() {
                                tapped = true;
                              });
                              launchUrl(Uri.parse("tel://+20${ownerData.phone}"));
                              setState(() {
                                tapped = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                )
                            ),
                            icon:  Icon(CupertinoIcons.phone_solid, color: Colors.blueGrey.shade800, size: width*0.040,),
                            label: Text('Phone call', style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: width*0.03
                            ),),
                          ),
                          ElevatedButton.icon(
                            onPressed: tapped ? null : () async{
                              setState(() {
                                tapped = true;
                              });
                              if (Platform.isAndroid){
                                await launchUrl(Uri.parse("whatsapp://send?phone=+20${ownerData.phone}"));
                              }else if (Platform.isIOS){
                                await launchUrl(Uri.parse("whatsapp://send?phone=+20${ownerData.phone}"));
                              }
                              setState(() {
                                tapped = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                )
                            ),
                            icon:  Icon(CupertinoIcons.text_bubble_fill, color: Colors.blueGrey.shade900, size: width*0.040,),
                            label: Text('Whatsapp', style: TextStyle(
                                color: Colors.blueGrey.shade900,
                                fontSize: width*0.03
                            ),),
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
  Future<int> _customSheet(BuildContext context) async{
    int resp = -1;
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder){
          List<PetPod> goodPets = <PetPod>[];

          for (PetPod p in widget.ownerPets) {
            if ((p.pet.breed == widget.pod.pod.pet.breed)
                && (p.pet.isMale != widget.pod.pod.pet.isMale)){

              goodPets.add(p);
            }
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
