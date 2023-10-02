import 'dart:async';
import 'dart:convert';
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
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../APILibraries.dart';
import '../FETCH_wdgts.dart';
import '../JsonObj.dart';
import '../cacheBox.dart';
import '../configuration.dart';
import 'dart:io' show Platform;
import 'package:pdfx/pdfx.dart';



class PetProfilePage extends StatefulWidget{
  final PetPod pod;
  final MateRequest? request;
  final PetProfile? receiverPet;
  final String? tag;
  const PetProfilePage({Key? key, required this.pod, this.request, this.receiverPet, this.tag}) : super(key: key);

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> with TickerProviderStateMixin {

  String distanceText = "N/A";
  String petAge = "";
  String rating = "0";
  final _controller = MultiSelectController();
  List<MultiSelectCard> items = <MultiSelectCard>[];
  bool pdfReady = false;
  late AnimationController animController;
  late AnimationController scrollAnimator;
  late Animation animation;
  late Animation scrollAnimation;
  final ScrollController controller = ScrollController();

  late CacheBox cacheBox;
  List<PetPod> ownerPets = [];
  int distance = -1;
  UserPod? ownerPod;
  final petState = ValueNotifier<profileState>(profileState.noFriendship);
  bool ownerVerified = false;
  bool tapped = false;

  final uid = FirebaseAuth.instance.currentUser!.uid;
  late Timer _timer;
  int timer_counter = 5;

  int petIndex = 0;
  
  MateRequest? request;

  List<MateRequest> relatedRequests = [];

  List<MateRequest> recRequests = [];
  List<MateRequest> sentRequests = [];

  late OverlayEntry loading = initLoading(context);

  List<PetProfile> receiverPets = [];
  PetProfile? receiverPet;

  @override
  void initState() {
    animController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = CurvedAnimation(parent: animController, curve: Curves.easeIn);

    scrollAnimator =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    scrollAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(scrollAnimator);
    scrollAnimator.animateTo(1);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initPet();
    });
    super.initState();
  }
  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      scrollAnimator.animateTo((30.h - scrollInfo.metrics.pixels) / 30.h);
      return true;
    }
    return false;
  }


  startTimer(){
    const interval = Duration(seconds: 1);
    _timer = Timer.periodic(interval, (timer) {
      if (timer_counter == 0){
        if (mounted) {
          setState(() {
            _timer.cancel();
          });
        }

      }else{
        timer_counter--;
        if ( widget.pod.distance > -1){
          distance = widget.pod.distance;
          if (widget.pod.distance >= 1000){
            distanceText = (widget.pod.distance/1000).toInt().toString() + " Kilometers";
          }else{
            distanceText = (widget.pod.distance).toInt().toString() + " meters";
          }
          if (mounted){
            setState(() {
            });
          }
        }else{
          // print('no distance');
        }
      }
    });

  }


  initPetState({PetProfile? rcvrPet}){
    requestState? state;
    String? receiverPetId;

    request = widget.request;

    relatedRequests = cacheBox.getPetRelations(widget.pod.pet.id);

    if (rcvrPet == null){
      if (widget.receiverPet != null){
        receiverPet = widget.receiverPet!;
      }else{
        if (relatedRequests.isNotEmpty) receiverPet = relatedRequests.first.receiverPet!;
      }
    }else{
      receiverPet = rcvrPet;
      request = relatedRequests.firstWhere((e)
      => (e.receiverPetId == receiverPet!.id) || (e.senderPetId == receiverPet!.id));
    }

    request ??= (receiverPet != null) ? relatedRequests.firstWhere((e) => e.receiverPetId == receiverPet!.id)
    : null;

    state = request?.status;
    receiverPetId = request?.receiverPetId;

    if (state != null && receiverPetId != null){
      switch(state){

        case requestState.pending:
          if (receiverPetId == widget.pod.pet.id){
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
      if (ownerPets.indexWhere((e) => e.pet.id == widget.pod.pet.id) != -1){
        petState.value = profileState.owner;
      }else{
        petState.value = profileState.noFriendship;
      }

    }

  }
  initPet() async{
    
    ownerPets = await cacheBox.getUserPets();

    initPetState();
    
    distance = widget.pod.distance;
    if ( distance > -1){
      if (widget.pod.distance >= 1000){
        distanceText = (widget.pod.distance/1000).toInt().toString() + " Kilometers";
      }else{
        distanceText = (widget.pod.distance).toInt().toString() + " meters";
      }
    }else{
      startTimer();
    }


    final age = AgeCalculator.age(widget.pod.pet.birthdate);
    petAge = '';
    if (age.years > 1){
      petAge += "${age.years} Years ";
    }else if (age.years == 1){
      petAge += "${age.years} Year ";
    }
    if (age.months > 0) petAge += 'and ';

    if (age.months > 1){
      petAge += "${age.months} Months";
    }else if (age.months == 1){
      petAge += "${age.months} Month ";
    }

    for (MapEntry entry in vaccineFList.entries){
      final vaccine = MultiSelectCard(value: entry.key, label: entry.value,
          selected: widget.pod.pet.vaccines.contains(entry.key) ? true : false);
      items.add(vaccine);
    }

    if (widget.pod.pet.rateCount > 0){
      rating = "${(widget.pod.pet.rateSum/widget.pod.pet.rateCount).toStringAsFixed(1)} / 5";
    }

    ownerVerified = widget.pod.pet.type == 1;
    initPDF();
    setState(() {});
  }
  initPDF() async{
    if (widget.pod.pet.passport != ""){
      pdfReady = true;
      animController.forward();
    }

  }

  @override
  void dispose() {
    animController.dispose();
    scrollAnimator.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    cacheBox = context.watch<CacheBox>();
    recRequests = relatedRequests.where((e) => (e.receiverId == uid && e.status == requestState.pending)).toList();
    sentRequests =  relatedRequests.where((e) => (e.senderId == uid && e.status == requestState.pending)).toList();
    final eligiblePets = ownerPets.isEmpty ? <PetPod>[] : ownerPets.where((e) => e.pet.breed == widget.pod.pet.breed);
    bool eligible = eligiblePets.length > 1 && receiverPet != null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      //for status bar color
      value: SystemUiOverlayStyle.dark,
      child: NotificationListener<ScrollNotification>(
        onNotification: _scrollListener,
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              controller: controller,
              child: Stack(
                children: [
                  Hero(
                    tag: widget.tag?? '',
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(15.sp), topLeft: Radius.circular(15.sp)),
                      child: SizedBox(
                        height: 35.h,
                        width: double.infinity,
                        child: ShaderMask(
                          blendMode: BlendMode.multiply,
                          shaderCallback: (Rect bounds) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.5),Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.5)],
                          ).createShader(bounds),
                          child: ClipRRect(
                            child: Image.network(widget.pod.pet.photoUrl, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Column(
                      children: [
                        SizedBox(height: 29.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: distance == -1,
                              child: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_pin, color: Colors.white,),
                                    SizedBox(width: 2.w),
                                    Text(distance == -1 ? "Not available" : distanceText == '' ? 'Not available' : distanceText,
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon( ownerVerified ?
                            Icons.verified_user_rounded : CupertinoIcons.exclamationmark_shield_fill,
                                color: CupertinoColors.white, size: 21.sp,),
                            SizedBox(width: 1.w),
                            Icon(widget.pod.pet.passport == '' ? CupertinoIcons.doc : CupertinoIcons.doc_text_fill,
                                color: Colors.white, size: 19.sp),
                          ],
                        ),
                      ],
                    ),
                  ).animate().slide(begin: const Offset(0,1), end: const Offset(0,0), delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 500)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 33.h),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10,15,10,0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.sp), topRight: Radius.circular(15.sp)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(widget.pod.pet.name, style: TextStyle(
                                              fontSize: width*0.06,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.blueGrey.shade900
                                          ),),
                                          Text(petAge, style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.blueGrey.shade900
                                          ), maxLines: 2, overflow: TextOverflow.visible,  textAlign: TextAlign.center)

                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(widget.pod.pet.breed, style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w800,
                                              color: widget.pod.pet.isMale ? Colors.blue.shade600 : Colors.pink.shade600
                                          ), maxLines: 2, overflow: TextOverflow.visible,  textAlign: TextAlign.center),
                                          Icon(widget.pod.pet.isMale ? Icons.male_rounded : Icons.female_rounded,
                                              color: widget.pod.pet.isMale ? Colors.blue.shade600 : Colors.pink.shade600,
                                              size: 5.w),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ValueListenableBuilder<profileState>(
                                        valueListenable: petState,
                                        builder: (BuildContext context, profileState value, Widget? widget){
                                          switch(value){
                                            case profileState.pendingApproval: {
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: tapped ? null : ()async {

                                                        setState(() {
                                                          tapped = true;
                                                        });

                                                        if (recRequests.length > 1){
                                                          selectPet();
                                                        }else{
                                                          final req = request!;
                                                          final updated = await cacheBox.updateMateRequest(
                                                              sender: req.senderPetId, receiver: req.receiverPetId, state:requestState.accepted);
                                                          if (updated){
                                                            request!.status = requestState.accepted;
                                                            petState.value = profileState.friend;
                                                            setState(() {
                                                            });
                                                          }else{
                                                            showSnackbar(context, "Failed to communicate with server, try again.");
                                                          }
                                                        }
                                                        setState(() {
                                                          tapped = false;
                                                        });

                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.green.shade300,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(9.sp)
                                                          )
                                                      ),
                                                      icon:  Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 5.w,),
                                                      label: const Text('Accept', style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600
                                                      ),),
                                                    ),
                                                  ),
                                                  // SizedBox(width: width*0.02,),
                                                  Container(
                                                    constraints: BoxConstraints(maxWidth: 20.w, maxHeight: 20.w),
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Stack(
                                                      children: [
                                                        Center(
                                                          child: CircleAvatar(
                                                            backgroundColor: Colors.blueGrey, radius: 8.w,
                                                            child: CircleAvatar(radius: 7.5.w,
                                                              backgroundImage: NetworkImage(receiverPet!.photoUrl),),),
                                                        ),
                                                        recRequests.length > 1 ? Align(
                                                          alignment: Alignment.bottomRight,
                                                          child: CircleAvatar(
                                                            backgroundColor: Colors.blueGrey, radius: 5.w,
                                                            child: CircleAvatar(radius: 4.5.w,
                                                              backgroundImage: NetworkImage(recRequests.firstWhere((e)
                                                              => e.receiverPetId != receiverPet!.id).receiverPet!.photoUrl),),),
                                                        )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: tapped ? null : ()async {
                                                        setState(() {
                                                          tapped = true;
                                                        });
                                                        final updated = await cacheBox.updateMateRequest(
                                                            sender: request!.senderPetId, receiver: request!.receiverPetId, state: requestState.denied);
                                                        if (updated){
                                                          request!.status = requestState.denied;
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
                                                              borderRadius: BorderRadius.circular(9.sp)
                                                          )
                                                      ),
                                                      icon:  Icon(CupertinoIcons.xmark, color: Colors.black, size: 5.w,),
                                                      label: const Text('Decline', style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w600
                                                      ),),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            case profileState.requested: {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 0.w),
                                                child: ElevatedButton.icon(
                                                  onPressed:tapped ? null :  ()async {
                                                    setState(() {
                                                      tapped = true;
                                                    });
                                                    final resp = await cacheBox.updateMateRequest(
                                                        sender: request!.senderPetId,
                                                        receiver: request!.receiverPetId,
                                                        state: requestState.undefined);
                                                    if (resp){
                                                      print('petState?: ${request!.status}');
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
                                                          borderRadius: BorderRadius.circular(9.sp)
                                                      )
                                                  ),
                                                  icon:  Icon(CupertinoIcons.heart_slash_fill, color: Colors.white, size: 5.w),
                                                  label: const Text('Cancel Request', style: TextStyle(
                                                      color: Colors.white,
                                                    fontWeight: FontWeight.w600
                                                  ),),
                                                ),
                                              );
                                            }
                                            case profileState.friend: {
                                              return Row(
                                                children: [
                                                  Flexible(
                                                    flex: 3,
                                                    child: ElevatedButton(
                                                      onPressed: () {
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
                                                              borderRadius: BorderRadius.circular(9.sp)
                                                          )
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text('Mates', style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w600
                                                          ),),
                                                          Icon(Icons.more_horiz_rounded, size: 5.w)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Expanded(
                                                    flex: 7,
                                                    child:  ElevatedButton.icon(
                                                      onPressed: tapped ? null : () async
                                                    {
                                                      if (ownerPod == null) {
                                                        if (!loading.mounted) {
                                                          OverlayState? overlay =
                                                          Overlay.of(context);
                                                          overlay.insert(loading);
                                                          setState(() {

                                                          });
                                                        }
                                                        try {
                                                          ownerPod = await cacheBox.getPetOwnerInfo(this.widget.pod.pet.ownerId);
                                                        } catch (e) {
                                                         showSnackbar(context, 'Could not load owner info, try again!');
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
                                                          backgroundColor: Colors.green.shade300,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(9.sp)
                                                          )
                                                      ),
                                                      icon:  Icon(Icons.account_circle_sharp, size: 5.w),
                                                      label: Text('Contact Owner', style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600
                                                      ),),
                                                    ),
                                                  )
                                                ],
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
                                                  if (uid == ownerPets[petInd].pet.ownerId){
                                                    final state = await cacheBox.getPetState(
                                                        ownerPetId: ownerPets[petInd].pet.id, petId: this.widget.pod.pet.id);
                                                    switch(state[0]){
                                                      case profileState.requested:
                                                        petState.value = profileState.requested;
                                                        break;
                                                      case profileState.pendingApproval:
                                                        final req = request!;
                                                        final updated = await cacheBox.updateMateRequest(
                                                            sender: req.senderPetId, receiver: req.receiverPetId, state:requestState.accepted);
                                                        if (updated){
                                                          request!.status = requestState.accepted;
                                                          petState.value = profileState.friend;
                                                          setState(() {
                                                          });
                                                        }else{
                                                          request = cacheBox
                                                              .getSinglePetRelation(this.widget.pod.pet.id, ownerPet: ownerPets[petInd].pet.id);
                                                          petState.value = profileState.pendingApproval;
                                                          showSnackbar(context, "Failed to communicate with server, try again.");
                                                        }
                                                        break;
                                                      case profileState.friend:
                                                        petState.value = profileState.friend;
                                                        break;
                                                      default:
                                                        if (state[0] == profileState.undefined){
                                                          await cacheBox.removeNotification(id: state[1]);
                                                        }
                                                        final newRequest = await sendMateRequest(ownerPets[petInd].pet.ownerId,
                                                            this.widget.pod.pet.ownerId,
                                                            ownerPets[petInd].pet.id,
                                                            this.widget.pod.pet.id);
                                                        if (newRequest != null){
                                                          request = newRequest;
                                                          petState.value = profileState.requested;
                                                          cacheBox.addNewNotifications(items: [newRequest]);
                                                          showNotification(context, 'Request sent successfully!');
                                                        }else{
                                                          showSnackbar(context, 'Failed to send request');
                                                        }
                                                        break;
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
                                                      borderRadius: BorderRadius.circular(9.sp)
                                                  )
                                              ),
                                              icon:  Icon(CupertinoIcons.heart_fill, color: Colors.white, size: 5.w,),
                                              label: Text('Send Request', style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600
                                              ),),
                                            );
                                            default: return ElevatedButton.icon(
                                              onPressed:tapped ? null :  ()async {
                                                setState(() {
                                                  tapped = true;
                                                });



                                                setState(() {
                                                  tapped = false;
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blueGrey.shade800,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(9.sp)
                                                  )
                                              ),
                                              icon:  Icon(Icons.edit, color: Colors.white, size: 5.w,),
                                              label: const Text('Edit info', style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600
                                              ),),
                                            );
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Text("Vaccinations",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.blueGrey.shade700,
                                        )),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(2.w),
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
                                  SizedBox(height: 4.h),
                                  Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("Passport",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: width*0.04,
                                                  color: Colors.blueGrey.shade700,
                                                )),


                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      widget.pod.pet.passport != '' ? Container(
                                        padding: EdgeInsets.all(3.w),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [
                                              Colors.blueGrey.shade600,
                                              Colors.blueGrey.shade900
                                            ]),
                                          borderRadius: BorderRadius.circular(9.sp)
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(9.sp),
                                          onTap: (){
                                            homeNav_key.currentState?.pushNamed('/petPassport', arguments: widget.pod.pet);
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(widget.pod.pet.rateCount > 0 ?
                                                  CupertinoIcons.star_fill : CupertinoIcons.star_slash_fill, color: Colors.orange,
                                                    size: 15.sp,),
                                                  SizedBox(width: 1.w),
                                                  widget.pod.pet.rateCount > 0 ? Text(rating,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.white
                                                    ), textAlign: TextAlign.end,) : Container(),
                                                ],
                                              ),
                                              Text('View passport', style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10.sp,
                                                color: Colors.white,
                                              )),
                                              const Icon(CupertinoIcons.right_chevron, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ) : petState.value == profileState.owner ? InkWell(
                                        borderRadius: BorderRadius.circular(9.sp),
                                        highlightColor: Colors.blue,
                                        splashColor: Colors.green,
                                        onTap: (){
                                          print('hey');
                                        },
                                        child: Container(
                                            padding: EdgeInsets.all(3.w),
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: [
                                                  Colors.blueGrey.shade900,
                                                  Colors.blueGrey.shade900,
                                                  Colors.red.shade900,
                                                ]),
                                                borderRadius: BorderRadius.circular(9.sp)
                                            ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Icon(CupertinoIcons.doc, color: Colors.white),
                                              Text('Upload passport', style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10.sp,
                                                color: Colors.white,
                                              )),
                                              const Icon(Icons.upload_rounded, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ) : Container(
                                        padding: EdgeInsets.all(3.w),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [
                                              Colors.blueGrey.shade900,
                                              Colors.blueGrey.shade900,
                                              Colors.red.shade900,
                                            ]),
                                            borderRadius: BorderRadius.circular(20.sp)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(CupertinoIcons.doc, color: Colors.white),
                                            Text('No passport available', style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10.sp,
                                              color: Colors.white,
                                            )),
                                            const Icon(CupertinoIcons.xmark, color: Colors.white),
                                          ],
                                        ),),
                                    ],

                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().slide(begin: const Offset(0,0.5), end: const Offset(0,0), delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 300)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            child: Container(
              width: double.infinity,
              height: 5.h,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: Icon(CupertinoIcons.back)),
                  const Spacer(),
                  !eligible ? Container() : AnimatedBuilder(
                    builder: (context, child) {
                      return Opacity(
                        opacity: scrollAnimator.value,
                        child: ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFB288C0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.sp)
                                )
                            ),
                            child: Row(
                              children: [
                                Text('Viewing as   '),
                                CircleAvatar(
                                    radius: 1.5.h,
                                    backgroundImage: NetworkImage(receiverPet!.photoUrl))
                              ],
                            )),
                      );
                    }, animation: scrollAnimation,
                  )
                ],
              ),
            ),
          )
              .animate().slide(begin: const Offset(0,-1), end: const Offset(0,0), delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 500)),
        ),
      ),
    );
  }

  void selectPet(){

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context, builder: (_) {
      return StatefulBuilder(
        builder: (context, setter) {
          List<PetProfile> petsToShow = List<PetProfile>.generate(recRequests.length, (index) => recRequests[index].receiverPet!);
          if (petsToShow.isEmpty) Navigator.of(context).pop();
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 4.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.sp), topRight: Radius.circular(15.sp)),
                color: Colors.blueGrey.shade100
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("${widget.pod.pet.name}'s requests (${petsToShow.length})",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12.sp),),
                SizedBox(height: 3.h),
                Expanded(
                  child: ListView.separated(
                      itemCount: petsToShow.length,
                      shrinkWrap: true,
                      itemBuilder: (context, k){
                        final pet = petsToShow[k];
                        return Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.sp)
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              SizedBox(
                                height: 7.h,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blueGrey.shade600,
                                          radius: 3.5.h,
                                          child: CircleAvatar(
                                            radius: 3.2.h,
                                              backgroundImage: NetworkImage(widget.pod.pet.photoUrl),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.blueGrey.shade600,
                                            radius: 2.h,
                                            child: CircleAvatar(
                                              radius: 1.7.h,
                                              backgroundImage: NetworkImage(pet.photoUrl),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(width: 2.w),
                                    Text('${pet.name}', style:TextStyle(color: Colors.blueGrey.shade600,
                                    fontWeight: FontWeight.w700),),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async{
                                        final req = recRequests.firstWhere((e) => e.receiverPetId == pet.id);
                                        final updated = await cacheBox.updateMateRequest(
                                            sender: req.senderPetId, receiver: req.receiverPetId, state:requestState.accepted);
                                        if (updated){
                                          if (receiverPet != null && (req.receiverPetId == receiverPet!.id)) petState.value = profileState.friend;
                                          setter((){});
                                          showNotification(context, "${req.senderPet!.name} is now friends with ${req.receiverPet!.name}");
                                        }else{
                                          showSnackbar(context, "Failed to communicate with server, try again.");
                                        }

                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade300,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(9.sp)
                                          )
                                      ),
                                      child: Text('Accept', style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white
                                      ),),
                                    ),
                                    SizedBox(width: 2.w),
                                    ElevatedButton(
                                      onPressed: () async{
                                        final req = recRequests.firstWhere((e) => e.receiverPetId == pet.id);
                                        final updated = await cacheBox.updateMateRequest(
                                            sender: req.senderPetId, receiver: req.receiverPetId, state:requestState.denied);
                                        if (updated){
                                          if (recRequests.indexWhere((e) => e.status == requestState.accepted) == -1){
                                            if (recRequests.indexWhere((e) => e.status == requestState.pending) == -1){
                                              
                                            }
                                          }
                                          setter((){});
                                        }else{
                                          showSnackbar(context, "Failed to communicate with server, try again.");
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(9.sp)
                                          )
                                      ),
                                      child: Text('Decline', style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red
                                      ),),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }, separatorBuilder: (BuildContext context, int index) => const Divider(),),
                )
              ],
            ),
          );
        }
      );
    }).then((value) {
      if (value is List){
        return value;
      }else{
        return null;
      }
    });
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
              if (uLat > 0.0 && uLong > 0 && ownerData.location.latitude > 0 && ownerData.location.longitude > 0 ){
                distance = Geolocator.distanceBetween(uLat, uLong, ownerData.location.latitude, ownerData.location.longitude).toInt();
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

          for (PetPod p in ownerPets) {
            if ((p.pet.breed == widget.pod.pet.breed)
                && (p.pet.isMale != widget.pod.pet.isMale)){

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
                              child: CustomPet(pod: temPet, tag: '0'));
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
