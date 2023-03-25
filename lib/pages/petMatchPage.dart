import 'dart:async';
import 'dart:ffi';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:csc_picker/model/select_status_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/DataPass.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../cacheBox.dart';
import '../draggable_card.dart';
import '../swipe_cards.dart';


import '../JsonObj.dart';

enum matchesStat{empty, good, refill}

class PetMatchPage extends StatefulWidget {
  final PetPod senderPet;
  final List<PetPod> pets;
  List<MateRequest> petRequests;
  List<MateRequest> sentRequests;
  PetMatchPage({Key? key, required this.pets, required this.senderPet, required this.petRequests, required this.sentRequests}) : super(key: key);

  @override
  State<PetMatchPage> createState() => _PetMatchPageState();
}

class _PetMatchPageState extends State<PetMatchPage> with TickerProviderStateMixin {

   List<PetPod> petMatches = <PetPod>[];
   List<SwipeItem> petItems = <SwipeItem>[];
   List<SwipeItem> visiblePetItems = <SwipeItem>[];
   MatchEngine? _matchEngine;
   late List<Widget> petDialogs;
   bool petsReady = false;
   int swipeBool = 1;

   late AnimationController animControl;
   late AnimationController rewindAnimation;
   late Animation animation;
   late CacheBox cacheBox;
   bool miniRewind = false;
   bool rewindPressed = false;
   bool stackFinished = false;
   bool sendBool = false;
   bool likePressed = false;
   bool freezeStack = false;
   Completer<bool> sendCompleter = Completer();
   StreamController<bool> sendingRequest = StreamController();
   late Stream sendStream;
   void completeListener;
   ValueNotifier<SlideRegion> currentRegion = ValueNotifier<SlideRegion>(SlideRegion.frozen);

   ValueNotifier<matchesStat> petListStat = ValueNotifier<matchesStat>(matchesStat.empty);

   final emptyMateRequest = MateRequest(id: "-1",
       senderId: 'senderId', receiverId: 'receiverId',
       senderPet: 'senderPet', receiverPet: 'receiverPet', status: requestState.undefined, ts: DateTime.now(), lastModified: DateTime.now(), );


   @override
   void initState() {
     sendStream = sendingRequest.stream.asBroadcastStream();
     animControl = AnimationController(duration: Duration(seconds: 1), vsync: this);
     animation = CurvedAnimation(parent: animControl, curve: Curves.easeIn);
     rewindAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
     initPets();
     super.initState();
   }

   @override
   void dispose(){
     animControl.dispose();
     rewindAnimation.dispose();
     super.dispose();
   }

   Future<bool> sendCompleted() async{
    await for (bool v in sendStream){
      if (!v) return v;
    }
    print('stream shutdown');
    return false;
   }

   initPets() async{
     petMatches = widget.pets;
    generateSwipeItems(petMatches);
    visiblePetItems.addAll(petItems);
     _matchEngine = MatchEngine(swipeItems: visiblePetItems);
    setState(() {
      petsReady = true;
      if (petItems.isNotEmpty){
        petListStat.value = matchesStat.good;
      }
    });
    animControl.forward();
  }

   void fetchNewPetMatches() async{
     List<PetPod> newPets = await cacheBox.fetchPetQuery(pet: widget.senderPet.pet, reset: false);

     visiblePetItems.removeWhere((pet) => pet.decision == Decision.liked);

     if (newPets.isNotEmpty){

       visiblePetItems.addAll(generateSwipeItems(newPets));
       final startingIndex = visiblePetItems.length - newPets.length;

       setState(() {
         _matchEngine!.setStartingIndex(startingIndex);
         petListStat.value = matchesStat.good;

       });
     }else{
       setState(() {
         petListStat.value = matchesStat.empty;
       });
     }
   }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
     cacheBox = DataPassWidget.of(context);
    return Center(
        child: Scaffold(
          appBar: init_appBar(homeNav_key),
          body: !petsReady ? LoadingPage() : FadeTransition(
            opacity: animControl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.h),
                Container(
                  width: 55.w,
                  padding: EdgeInsets.all(5.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.sp),
                    color: Colors.blueGrey.shade900
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.senderPet.pet.photoUrl),
                      ),
                      Text("${widget.senderPet.pet.name}'s Mate Choices",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,color: Colors.blueGrey.shade50),
                      )
                    ],
                  ),
                ),
                SizedBox(height: height*0.05,),
                petsReady ? Center(
                  child: IgnorePointer(
                    ignoring: freezeStack,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: petListStat.value == matchesStat.refill ? Center(
                        key: const Key('refill_m'),
                        child: SizedBox(
                              height: 100,
                              width: 100,
                              child: LoadingPage(notPage: true))
                      ) :
                        petListStat.value == matchesStat.good ? SizedBox(
                          child: Column(
                            key: const Key('good_m'),
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SwipeCards(
                                likeTag: buildStamp(color: Colors.green.shade600, text: 'SEND'),
                                nopeTag: buildStamp(color: Colors.redAccent, text: 'SKIP'),
                                matchEngine: _matchEngine!,
                                itemBuilder: (BuildContext context, int index) {
                                  return visiblePetItems[index].content;
                                },
                                itemChanged: (item, index){
                                  if (sendBool){
                                    print('end animation');
                                    sendBool = false;
                                    sendingRequest.add(sendBool);
                                  }
                                },
                                onStackFinished: () async{
                                  if (!sendBool){
                                    setState(() {
                                      petListStat.value = matchesStat.refill;
                                    });
                                    fetchNewPetMatches();
                                  }else{
                                    stackFinished = true;
                                    sendBool = false;
                                    sendingRequest.add(sendBool);
                                  }

                                },
                                onNewAction: (direction, index) async{
                                  print(direction);
                                  if (!likePressed){
                                    if (direction == SlideDirection.right){
                                      sendBool = true;
                                      sendingRequest.add(sendBool);
                                      sendRequest(_matchEngine!.currentItem!);
                                    }
                                  }else{
                                    print('no exec');
                                    likePressed = false;
                                  }

                                },
                                regionChanged: (SlideRegion region){
                                 if (currentRegion.value != region){
                                   setState(() {
                                     currentRegion.value = region;
                                   });
                                 }
                                },
                                upSwipeAllowed: false,
                                fillSpace: false,
                              ),
                            ],
                          ),
                        ) :
                        Column(
                          key: const Key('empty_m'),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Text(
                                "Sorry, we couldn't find more matches for ${widget.senderPet.pet.name} at the mean time. "
                                    "${visiblePetItems.isNotEmpty ? 'You can go over skipped pets' : 'You can try later'}",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,color: CupertinoColors.systemGrey2),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 20,),
                            visiblePetItems.isNotEmpty ? ElevatedButton.icon(
                              onPressed: (){
                                setState(() {
                                  _matchEngine!.refreshEngine();
                                  petListStat.value = matchesStat.good;
                                });
                                // BA_key.currentState?.pop(true);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0)
                                  )
                              ),
                              icon:  Icon(CupertinoIcons.paw, color: Colors.black, size: width*0.045,),
                              label: Text('View Skipped Pets', style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width*0.035
                              ),),
                            ) : Container(),
                          ],
                        )
                    ),
                  ),
                ) : LoadingPage(),
                Spacer(),
                IgnorePointer(
                  ignoring: petListStat.value == matchesStat.empty ? true : false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    child: AnimatedOpacity(
                        opacity: petListStat.value != matchesStat.empty ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (child ,animation) =>
                              RotationTransition(turns: currentRegion.value ==  SlideRegion.inNopeRegion ?
                              Tween<double>(begin: 0, end: 1).animate(animation) :
                              Tween<double>(begin: 1, end: 0).animate(animation),
                                  child: ScaleTransition(scale: animation, child: child)),
                          child: currentRegion.value ==  SlideRegion.inNopeRegion  ? FloatingActionButton(
                            key: Key('nopeBtn1'),
                            onPressed: _nopePress,
                            backgroundColor: Colors.redAccent,
                            child:Icon(CupertinoIcons.xmark, color: Colors.white),
                          ) :
                          FloatingActionButton(
                              key: Key('nopeBtn2'),
                              onPressed: _nopePress,
                              backgroundColor: Colors.white,
                              child: Icon(CupertinoIcons.xmark, color: Colors.redAccent)
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (child ,animation) =>
                              RotationTransition(turns: miniRewind ? Tween<double>(begin: 0, end: 0.25).animate(animation) :
                                  Tween<double>(begin: 0.75, end: 1).animate(animation),
                              child: FadeTransition(opacity: animation, child: child)),
                          child: !miniRewind ? FloatingActionButton(
                            key: Key('RewindIcon1'),
                            onPressed: rewindPressed ? null : _rewindPress,
                            backgroundColor: CupertinoColors.white,
                            child:Icon(Icons.restart_alt_rounded, color: Colors.blueGrey.shade900),
                          ) :
                          FloatingActionButton(
                              key: Key('RewindIcon2'),
                              onPressed: rewindPressed ? null :  _rewindPress,
                              backgroundColor: Colors.blueGrey,
                              child: Icon(Icons.restart_alt_rounded, color: Colors.white)
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (child ,animation) =>
                              RotationTransition(turns: currentRegion.value ==  SlideRegion.inLikeRegion ?
                                  Tween<double>(begin: 0, end: 1).animate(animation) :
                              Tween<double>(begin: 1, end: 0).animate(animation),
                                  child: ScaleTransition(scale: animation, child: child)),
                          child: currentRegion.value ==  SlideRegion.inLikeRegion  ? FloatingActionButton(
                            key: Key('likeBtn1'),
                            onPressed: _likePress,
                            backgroundColor: Colors.greenAccent,
                            child:Icon(CupertinoIcons.heart_fill, color: Colors.white),
                          ) :
                          FloatingActionButton(
                              key: Key('likeBtn2'),
                              onPressed: _likePress,
                              backgroundColor: Colors.white,
                              child: Icon(CupertinoIcons.heart, color: Colors.greenAccent)
                          ),
                        ),
                      ],
                    )),
                  ),
                )
              ],
            ),
          ),
        )
    );

  }

  void _rewindPress({bool? liked}){
    setState(() {
      miniRewind = !miniRewind;
      rewindPressed = true;
    });
    if (petListStat.value != matchesStat.good) {
      setState(() {
        petListStat.value = matchesStat.good;
      });
    }
    final didRewind = _matchEngine!.rewindMatch(liked: liked);
    if (!didRewind){
      setState(() {
        petListStat.value = matchesStat.refill;
        fetchNewPetMatches();
      });
    }

    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      setState(() {
        miniRewind = !miniRewind;
        rewindPressed = false;
      });
    });
  }

  void _likePress(){
     likePressed = true;
     sendBool = true;
     sendingRequest.add(sendBool);
     sendRequest(_matchEngine!.currentItem!);
     _matchEngine!.currentItem!.decision = Decision.like;
     _matchEngine!.notifyListeners();
  }

  void _nopePress(){
    _matchEngine!.currentItem!.nope();
  }


   List<SwipeItem> generateSwipeItems(List<PetPod> matches){
     final newPets = <SwipeItem>[];
     for (PetPod pod in matches){

       final petView = PetMatchCard(pod: pod, sender: widget.senderPet);
       newPets.add(SwipeItem(
           content: petView,
           onSlideUpdate: (SlideRegion? region) async {

           }));
     }
     petItems.addAll(newPets);
     return newPets;
   }

   void sendRequest(SwipeItem item) async{
     setState(() {
       freezeStack = true;
     });
     bool failed = true;
     final pet = (item.content as PetMatchCard).pod.pet;
     int sentFind = widget.sentRequests.indexWhere((e) => (e.receiverPet == pet.id && e.senderPet == widget.senderPet.pet.id));
     int receivedFind = widget.petRequests.indexWhere((e) => (e.senderPet == pet.id && e.receiverPet == widget.senderPet.pet.id));
     if (receivedFind != -1){
       if (widget.sentRequests[receivedFind].status == requestState.pending){
         showSnackbar(context, "A MATCH");
         failed = false;
       }else{
         // do other checks
       }
     }else if (sentFind != -1){
       showSnackbar(context, "Already sent a request");
     }else{
       final uid = FirebaseAuth.instance.currentUser!.uid;
       MateRequest? newRequest = await sendMateRequest(uid, pet.ownerId, widget.senderPet.pet.id, pet.id);
       if (newRequest != null){
         failed = false;
         // widget.sentRequests.add(newRequest);
         if (mounted) showSnackbar(context, "Request sent");
       }else{
         if (mounted) showSnackbar(context, "Failed to send request");
       }
     }

     await sendCompleted();
     await Future.delayed(const Duration(milliseconds: 50));
     if (failed){
       _rewindPress(liked: true);
     }else{
       if (stackFinished){
         setState(() {
           petListStat.value = matchesStat.refill;
         });
         fetchNewPetMatches();
       }
     }
     setState(() {
       freezeStack = false;
     });
   }
}
