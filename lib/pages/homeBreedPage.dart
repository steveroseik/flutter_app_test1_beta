import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:age_calculator/age_calculator.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/DataPass.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:flutter_app_test1/breedAdopt_main.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/editPetPage.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:ntp/ntp.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart' as pr;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../FETCH_wdgts.dart';
import '../cacheBox.dart';
import '../routesGenerator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class HomeBreedPage extends StatefulWidget {
  const HomeBreedPage({Key? key}) : super(key: key);

  @override
  State<HomeBreedPage> createState() => _HomeBreedPageState();
}

class _HomeBreedPageState extends State<HomeBreedPage>
    with TickerProviderStateMixin {

  // final emptyPet = PetPod(pet: PetProfile(id: '', name: '', vaccines: [],
  //   ownerId: '', birthdate: DateTime.now(), breed: '',
  //   isMale: false, photoUrl: '', type: -1, createdAt: DateTime.now(),
  //   rateSum: 0, rateCount: 0, passport: "", lastModified: DateTime.now(),
  //     location: Location(longitude: 0, latitude: 0)), isSelected: true);
  bool tapped = false;
  bool petDataLoading = false;
  var isLoading = true;
  bool mateBoxTapped = false;
  final vacEditing = ValueNotifier<int>(0);
  final viewVaccines = ValueNotifier<int>(0);
  final cacheLoaded = ValueNotifier<bool>(false);

  // final multiController = List<MultiSelectController>.empty(growable: true);

  List<PetPod> petPods = <PetPod>[];


  List<PetProfile> friends = <PetProfile>[];


  final petIndex = ValueNotifier<int>(0);
  PetPod? selectedPet;
  final vaccineList = List<selectItem>.empty(growable: true);
  late var items = List<MultiSelectItem>.empty(growable: true);

  double petItemExtent = 0;

  late OverlayEntry loading = initLoading(context);
  bool requestsLoading = true;
  String petAge = "";
  String petRating = "";
  late GeoLocation userLocation;
  final CarouselController scrollController = CarouselController();
  late CacheBox cacheBox;
  bool pScrollAnim = false;
  late StreamSubscription requestRecieveSub;
  late StreamSubscription requestSendSub;
  OverlaySupportEntry? notificationEntry;

  List<MateRequest> sentRequests = [];
  List<MateRequest> receivedRequests = [];
  List<MateRequest> receivedPending = [];


  @override
  void initState() {
    // updateLocation();
    petItemExtent = 50.w;
    // _controller = AnimationController(
    //   duration: const Duration(milliseconds: 300),
    //   vsync: this,
    // );
    // _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    // _controller2 = AnimationController(
    //   duration: const Duration(milliseconds: 300),
    //   vsync: this,
    // );
    // _animation2 = CurvedAnimation(parent: _controller2, curve: Curves.easeIn);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usrHasPets();
      genRelations();
      // do something
      if (petPods.isNotEmpty){
        pScrollAnim = true;
        setState(() {
          petPods[0].isSelected = true;
          selectedPet = petPods[0];
        });
      }
    });
  }

  // if user has no pets he is forced to add at least one pet
  usrHasPets() async {

    await updatePets();
    if (petPods.isEmpty){
      homeNav_key.currentState?.pushNamedAndRemoveUntil(
          '/add_pet', (Route<dynamic> route) => false, arguments: true);
    }else{
      if (mounted && petPods.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
        // _controller2.forward();
        refreshSelectedPetInfo();
        // _controller.forward();
      }
    }
  }

  updatePets() async {
    petPods = await cacheBox.getUserPets();

    if (petPods.isNotEmpty && !pScrollAnim){
      selectedPet = petPods[0];
    }
    setState(() {
      selectedPet?.isSelected = true;
    });
  }




  filterNotifications({required List<MateRequest> requests, bool? sent}){
    List<MateRequest> pendingReqs = <MateRequest>[];
    for ( MateRequest m in requests) {
      switch (m.status) {
        case requestState.pending:
          pendingReqs.add(m);
          break;
        case requestState.accepted:

          // addNewPetFriend(m, cacheBox);
          cacheBox.removeNotification(id: m.id);
          requests.remove(m);
          break;
        case requestState.denied:

          if (sent?? false){
            // delete from server
          }
          cacheBox.removeNotification(id: m.id);
          requests.remove(m);
          break;
        case requestState.undefined:
          requests.remove(m);
          cacheBox.removeNotification(id: m.id);
          if (sent?? false){
            // delete from server
          }
          break;
      }
    }
    setState(() {});
    return pendingReqs;
  }

  addNewRequestItem(MateRequest item) async{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    PetProfile? newPet;
    if (item.senderId == uid){
      newPet = await cacheBox.getPetWithId(item.receiverPetId);
      item.receiverPet = newPet;
    }else{
      newPet = await cacheBox.getPetWithId(item.senderPetId);
      item.senderPet = newPet;
    }
    cacheBox.addNewNotifications(items: [item]);
  }

  getPetFromID(String id){
    return petPods.firstWhere((e) => e.pet.id == id);
  }

  getPetFriends() async{
    friends = await cacheBox.cachedFriends(petPods);
  }

  genRelations() async{
    //TODO:: FIX PET FRIENDS
    // getPetFriends();
    print('genRel: ${await cacheBox.updateMateRequests()}');

    setState(() {
      requestsLoading = false;
    });

    //TODO:: OUTDATED Firebase listener, replace it
    // notificationsListeners();
  }

  // TODO: FIX
  requestDelete({required String id, bool? fromServer}) async{
    int i = receivedRequests.indexWhere((element) => element.id == id);
    if (i != -1) {
      cacheBox.removeNotification(id: id, fromServer: fromServer);
    }
  }

  List<MateRequest> manageModifiedRequests(List<MateRequest> requests){
    List<MateRequest> newRequests = <MateRequest>[];
    for (MateRequest req in requests){
      switch(req.status){
        case requestState.pending:
          // maybe needs to reflect item changes if already exists
          if (receivedRequests.indexWhere((e) => e.id == req.id) == -1) newRequests.add(req);
          break;
        case requestState.denied:
        case requestState.undefined:
          requestDelete(id: req.id, fromServer: true);
          break;
        case requestState.accepted:
          cacheBox.updateCachedRequest(reqId: req.id, state: requestState.accepted);
          // TODO: Friends are added in list from sender not receiver
          // addNewPetFriend(req, cacheBox);
          break;
      }
    }
    return newRequests;
  }

  void notificationsListeners(){
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Timestamp lastSent = Timestamp.fromDate(cacheBox.lastSentNotif);
    Timestamp lastRec = Timestamp.fromDate(cacheBox.lastReceivedNotif);
    requestRecieveSub = FirebaseFirestore.instance.collection('mateRequests')
        .where('receiverId', isEqualTo: uid).where('lastModified', isGreaterThan: lastSent).snapshots().listen((data) async {
      if (data.docChanges.isNotEmpty){
        List<DocumentSnapshot<Map<String, dynamic>>> modifiedRequests = <DocumentSnapshot<Map<String, dynamic>>>[];
        for (var e in data.docChanges){
          switch(e.type){
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              modifiedRequests.add(data.docs.firstWhere((x) => x.id == e.doc.id));
              break;
            case DocumentChangeType.removed:
              if (receivedRequests.indexWhere((x) => x.id == e.doc.id) != -1) {
                requestDelete(id: e.doc.id);
              }
              break;
          }
        }
        final requests = manageModifiedRequests(mateRequestFromDocs(modifiedRequests));
        if (requests.isNotEmpty){
          List<String> petIds = List<String>.generate(requests.length, (index) => requests[index].senderPetId);
          await cacheBox.getPetList(petIds);
          cacheBox.addNewNotifications(items: requests);
          if (petIds.isNotEmpty){
            if (requests.length > 1){
              notificationEntry = showOverlayNotification(duration: const Duration(milliseconds: 3000), (context) => GestureDetector(
                  onTap: (){
                    homeNav_key.currentState?.pushNamed('/petProfile', arguments: [PetPod(pet: requests[0].senderPet!, isSelected: false, foreign: true), requests[0]]);
                    dismissNotification();
                  },
                  child: MultiPetRequestBanner(item: requests[0], count: requests.length-1, receiverPet: getPetFromID(requests[0].receiverPetId))));
            }else{

              notificationEntry = showOverlayNotification(duration: const Duration(milliseconds: 3000), (context) => GestureDetector(
                  onTap: (){
                    homeNav_key.currentState?.pushNamed('/petProfile', arguments: [PetPod(pet: requests[0].senderPet!, isSelected: false, foreign: true), requests[0]]);
                    dismissNotification();
                  },
                  child: PetRequestBanner(request: requests[0], heroTag: '${requests[0].id}${Random().nextInt(40)}',)));
            }
          }
        }
        setState(() {});
      }
    });

    requestSendSub = FirebaseFirestore.instance.collection('mateRequests')
        .where('senderId', isEqualTo: uid).where('lastModified', isGreaterThan: lastRec).snapshots().listen((data) async {

      if (data.docChanges.isNotEmpty){

        List<DocumentSnapshot<Map<String, dynamic>>> modifiedRequests = <DocumentSnapshot<Map<String, dynamic>>>[];
        for (var e in data.docChanges){
          switch(e.type){
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              modifiedRequests.add(data.docs.firstWhere((x) => x.id == e.doc.id));
              break;
            case DocumentChangeType.removed:
              if (receivedRequests.indexWhere((x) => x.id == e.doc.id) != -1) {
                requestDelete(id: e.doc.id);
              }
              break;
          }
        }

        for (var e in mateRequestFromDocs(modifiedRequests)){
          if (e.status == requestState.denied) requestDelete(id: e.id, fromServer: true);
          if (e.status == requestState.accepted) {
            int i = sentRequests.indexWhere((x) => x.id == e.id);
            PetProfile? pet = await cacheBox.getPetWithId(e.receiverPetId);
            if (i != -1){
              sentRequests[i].status = requestState.accepted;

              if (pet != null && sentRequests[i].receiverPet == null){
                sentRequests[i].receiverPet = pet;
              }
            }else{
              if (pet != null){
               e.receiverPet = pet;
              }
              cacheBox.addNewNotifications(items: [e]);
            }
            // addNewPetFriend(e, cacheBox);
          }
        }

      }

    });

  }

  refreshSelectedPetInfo(){
    final age = AgeCalculator.dateDifference(fromDate: selectedPet!.pet.birthdate, toDate: DateTime.now());
    petAge = "";
    bool years = false;
    if (age.years > 1){
      petAge += "${age.years} Years";
      years = true;
    }else if (age.years == 1){
      petAge += "${age.years} Year";
      years = true;
    }
    if (age.months > 1){
      petAge += "${years ? ", " : ""}${age.months} Months";
    }else if (age.months == 1){
      petAge += "${years ? ", " : ""}${age.months} Month";
    }

    if (selectedPet!.pet.rateCount > 0){
      petRating = "${selectedPet!.pet.rateSum ~/ selectedPet!.pet.rateCount} / 5";
    }else{
      petRating = 'No rating';
    }

    createPetVaccines();
  }

  createPetVaccines(){
    vaccineList.clear();
    for ( MapEntry entry in vaccineFList.entries){
      vaccineList.add(selectItem(entry.value, selectedPet!.pet.vaccines.contains(entry.key) ? true : false));
    }
    items = vaccineList
        .map((vac) => MultiSelectItem<selectItem>(vac, vac.name))
        .toList();
  }

  updateLocation() async{
    await getUserCurrentLocation();
  }

  dismissNotification(){
    if (notificationEntry != null){
      notificationEntry!.dismiss();
    }
  }



  @override
  void dispose() {
    // _controller.dispose();
    vacEditing.dispose();
    viewVaccines.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    cacheBox = context.watch<CacheBox>();
    sentRequests = cacheBox.sentRequests;
    receivedRequests = cacheBox.receivedRequests;
    receivedPending = receivedRequests.where((e) => e.status == requestState.pending).toList();
    cacheLoaded.value = true;
    return Scaffold(
        appBar: init_appBar(homeNav_key),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              isLoading ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(width: 20.w, height: 4.h, child: Shimmer(
                      gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade300
                        ),
                      ),
                    ),),
                  ],
                ),
              ) : Padding(
                padding:EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Your Pets',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        )),
                    Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade900,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0))),
                      icon: Icon(Icons.add, size: 15),
                      onPressed: () {
                        homeNav_key.currentState?.pushNamed('/add_pet');
                      },
                      label: Text('New pet',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              isLoading ? Container(
                height: height*0.135,
                child: ShimmerOwnerPetCard(),
              ) : CarouselSlider.builder(
                itemCount: petPods.length,
                carouselController: scrollController,
                options: CarouselOptions(
                  height: 35.h,
                  viewportFraction: 0.6,
                  animateToClosest: true,
                  enlargeFactor: 0.4,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  onPageChanged: (index, carousel){
                    for (int i= 0; i < petPods.length; i++){
                      if (i == index){
                        petPods[i].isSelected = true;
                      }else{
                        petPods[i].isSelected = false;
                      }
                    }
                    selectedPet = petPods[index];
                    petIndex.value = index;
                    refreshSelectedPetInfo();
                    setState(() {});
                    // if (!_controller.isCompleted){
                    //   _controller.forward();
                    // }
                  }
                ),
                itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex){
                  final tag = '${petPods[itemIndex].pet.photoUrl}${Random().nextInt(40)}';
                  return GestureDetector(
                      onTap: (){
                        int selected = petPods.indexWhere((element) => element.isSelected);
                        if(itemIndex == selected){
                          homeNav_key.currentState?.pushNamed('/petProfile',
                              arguments: [petPods[selected],null, null, tag]);
                        }else{
                          scrollController.animateToPage(itemIndex);
                          // selected = petPods.indexWhere((element) => element.isSelected);
                          // if (selected != -1){
                          //   petPods[itemIndex].isSelected = true;
                          //   selectedPet = petPods[itemIndex];
                          //   petIndex.value = itemIndex;
                          //   refreshSelectedPetInfo();
                          //   setState(() {});
                          //   _controller.forward();
                          // }
                        }


                      },
                      child: CustomPet(pod: petPods[itemIndex], tag: tag,));
                },
              ),
              SizedBox(height: 1.h),
              isLoading ?
              Container(
                height: height*0.15,
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          height: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer(
                                gradient: LinearGradient(colors: [Colors.grey, Colors.white]),
                                child: CircleAvatar(
                                  radius: width*0.04,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,10,0),
                                child: Shimmer(
                                  gradient: LinearGradient(colors: [Colors.grey, Colors.white]),
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          height: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer(
                                gradient: LinearGradient(colors: [Colors.grey, Colors.white]),
                                child: CircleAvatar(
                                  radius: width*0.04,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,10,0),
                                child: Shimmer(
                                  gradient: LinearGradient(colors: [Colors.grey, Colors.white]),
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          height: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer(
                                gradient: LinearGradient(colors: [Colors.grey, Colors.white]),
                                child: CircleAvatar(
                                  radius: width*0.04,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,10,0),
                                child: Shimmer(
                                  gradient: LinearGradient(colors: [Colors.grey, Colors.white]),
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 6.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: tapped ? null : () async {
                            setState(() {
                              tapped = true;
                            });
                            if (petIndex.value != -1) {
                              if (!loading.mounted) {
                                OverlayState? overlay = Overlay.of(context);
                                overlay.insert(loading);
                              }
                              final pets = await cacheBox.fetchPetQuery(pet: selectedPet!.pet, reset: true);
                              loading.remove();
                              homeNav_key.currentState?.pushNamed(
                                  '/petMatch',
                                  arguments: [selectedPet, pets, receivedRequests, sentRequests]).then((value) {
                                if ( value != null && value == true){
                                  homeNav_key.currentState?.pushNamed('/search_manual', arguments: [petPods, receivedRequests, sentRequests]);
                                }
                              });
                            }else{
                              showSnackbar(context, 'Select a pet first');
                            }
                            setState(() {
                              tapped = false;
                            });
                          },
                          child:Container(
                            height: 7.h,
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade900,
                              borderRadius: BorderRadius.circular(6.w),
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: CircleAvatar(
                                    backgroundColor:
                                    Colors.redAccent,
                                    radius: 5.w,
                                    child:Image.asset('assets/mateIcon.png', color: Colors.white, width: 7.w,),
                                  ),
                                ),
                                const Text(
                                  'Find Mate',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w800),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(Icons.chevron_right, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        GestureDetector(
                          onTap: ()async {
                            cacheBox.showCachePets();
                            showNotification(context, "Coming soon.");
                          },
                          child: Container(
                            height: 7.h,
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade900,
                              borderRadius: BorderRadius.circular(6.w),
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: CircleAvatar(
                                    backgroundColor:
                                    Colors.redAccent,
                                    radius: 5.w,
                                    child: Icon(Icons.circle_outlined, color: Colors.white),
                                  ),
                                ),
                                const Text(
                                  'Pet Circle',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w800),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(Icons.chevron_right, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FittedBox(
          child: Stack(
            alignment: Alignment(1.4, -1.5),
            children: [
              FloatingActionButton(  // Your actual Fab
                onPressed: requestsLoading ? null : () async{
                  homeNav_key.currentState?.pushNamed('/notif').then((value){

                  });
                },
                child: Icon(Icons.local_fire_department_rounded, color: Colors.orange,),
                backgroundColor: Colors.blueGrey.shade800,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: receivedPending.isEmpty ? 0 : 1,
                child: Container(             // This is your Badge
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                  decoration: BoxDecoration( // This controls the shadow
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 1,
                          blurRadius: 5,
                          color: Colors.black.withAlpha(50))
                    ],
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.redAccent,  // This would be color of the Badge
                  ),             // This is your Badge
                  child: Center(
                    // Here you can put whatever content you want inside your Badge
                    child: Text('${receivedPending.length}', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        )
      //
    );
  }

  someFunc(int limit) async{
    try{
      var resp = await FirebaseFirestore.instance.collectionGroup('dogs').limit(2).get();



      var respond = resp.docs;
      respond.removeWhere((element) => element.data()['name'] == 'Joey');


      for (var element in respond) {
        print('${element['name']}: LM=> ${element.reference.path}\nBD=> ${element.id}');
      }
    }on FirebaseException catch (e){
      print(e.message);
    }
  }

  removeFirst(QuerySnapshot<Map<String, dynamic>> doc){

    return doc;
  }


  void _popEditPage(){
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder){
          return Container(height: 80.h,
              child: EditPetPage(pod: selectedPet!.pet));
        }
    ).then((value) async{
      if (value != null && value){
        setState(() {
          refreshSelectedPetInfo();
        });
      }
    });
  }
}


class Anim extends StatefulWidget {
  const Anim({Key? key, required this.widg, required this.duration})
      : super(key: key);

  final Widget widg;
  final Duration duration;

  @override
  State<Anim> createState() => _AnimState();
}

class _AnimState extends State<Anim> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(Anim oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.widg;
  }
}
