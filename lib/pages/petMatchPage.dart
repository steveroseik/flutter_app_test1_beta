import 'dart:async';
import 'dart:math';
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
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../cacheBox.dart';
import '../draggable_card.dart';
import '../swipe_cards.dart';


import '../JsonObj.dart';

enum matchesStat{empty, good, refill}

class PetMatchPage extends StatefulWidget {
  final PetPod senderPet;
  final List<PetPod> pets;
  PetMatchPage({Key? key, required this.pets, required this.senderPet}) : super(key: key);

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
   late List<MateRequest> sentRequests;
   late List<MateRequest> recRequests;
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
       senderPetId: 'senderPet', receiverPetId: 'receiverPet', status: requestState.undefined, createdAt: DateTime.now(), lastModified: DateTime.now(), );


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

     visiblePetItems.forEach((e) => print((e.content as PetMatchCard).pod.pet.id));

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
    sentRequests = cacheBox.sentRequests;
    recRequests = cacheBox.receivedRequests;
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
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  padding: EdgeInsets.all(5.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.sp),
                    color: Colors.blueGrey.shade900
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text("${widget.senderPet.pet.name}'s Mate Choices",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,color: Colors.blueGrey.shade50),
                          maxLines: 2,
                        ),
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
                                  if (!likePressed){
                                    if (direction == SlideDirection.right){
                                      sendBool = true;
                                      sendingRequest.add(sendBool);
                                      sendRequest(_matchEngine!.currentItem!);
                                    }
                                  }else{
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
                              key: Key('constKey1dd9323'),
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child ,animation) =>
                                  RotationTransition(turns: currentRegion.value == SlideRegion.inNopeRegion ?
                                  Tween<double>(begin: 0, end: 1).animate(animation) :
                                  Tween<double>(begin: 1, end: 0).animate(animation),
                                      child: ScaleTransition(scale: animation, child: child)),
                              child: currentRegion.value == SlideRegion.inNopeRegion  ? InkWell(
                                key: Key('nopeBtn1'),
                                onTap: _nopePress,
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),

                                  child: const Icon(CupertinoIcons.xmark, color: Colors.white),
                                ),
                              ) :
                              InkWell(
                                key: Key('nopeBtn2'),
                                onTap: _nopePress,
                                child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: const Icon(CupertinoIcons.xmark, color: Colors.redAccent)
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child ,animation) =>
                                  RotationTransition(turns: miniRewind ? Tween<double>(begin: 0, end: 0.25).animate(animation) :
                                  Tween<double>(begin: 0.75, end: 1).animate(animation),
                                      child: FadeTransition(opacity: animation, child: child)),
                              child: !miniRewind ? InkWell(
                                key: Key('RewindIcon1'),
                                onTap: rewindPressed ? null : _rewindPress,
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child:Icon(Icons.restart_alt_rounded, color: Colors.blueGrey.shade900),
                                ),
                              ) :
                              InkWell(
                                  key: Key('RewindIcon2'),
                                onTap: rewindPressed ? null :  _rewindPress,
                                child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blueGrey,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.restart_alt_rounded, color: Colors.white)
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              key: Key('constKey272khj234'),
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child ,animation) =>
                                  RotationTransition(turns: currentRegion.value ==  SlideRegion.inLikeRegion ?
                                  Tween<double>(begin: 0, end: 1).animate(animation) :
                                  Tween<double>(begin: 1, end: 0).animate(animation),
                                      child: ScaleTransition(scale: animation, child: child)),
                              child: currentRegion.value ==  SlideRegion.inLikeRegion  ? InkWell(
                                key: Key('likeBtn1'),
                                onTap: _likePress,
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child:const Icon(CupertinoIcons.heart_fill, color: Colors.white),
                                ),
                              ) :
                              InkWell(
                                key: Key('likeBtn2'),
                                onTap: _likePress,
                                child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: const Icon(CupertinoIcons.heart, color: Colors.greenAccent)
                                ),
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
     // _matchEngine!.notifyListeners();
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
     final state = await cacheBox.getPetState(
         ownerPetId: widget.senderPet.pet.id, petId: pet.id);


     if (state[0] == profileState.pendingApproval){
       if(await cacheBox.updateMateRequest(sender: pet.id, receiver: widget.senderPet.pet.id, state: requestState.accepted)){
         showSnackbar(context, "A MATCH");
         failed = false;
       }else{
         showSnackbar(context, "Failed to send request, try again.");
       }

     }else if (state[0] == profileState.requested){
       showSnackbar(context, "Already sent a request, pending approval!");

     }else {
       if (state[0] == profileState.undefined){
        await cacheBox.removeNotification(id: state[1]);
       }
      final uid = FirebaseAuth.instance.currentUser!.uid;
       MateRequest? newRequest = await sendMateRequest(uid, pet.ownerId, widget.senderPet.pet.id, pet.id);
       if (newRequest != null){
         failed = false;
         cacheBox.addNewNotifications(items: [newRequest]);
         if (mounted)  showNotification(context, "Request sent successfully!");
       }else{
         if (mounted) showSnackbar(context, "Failed to send request, try again.");
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
