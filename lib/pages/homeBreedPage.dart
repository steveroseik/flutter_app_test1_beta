import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:age_calculator/age_calculator.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:flutter_app_test1/pages/loadingPage.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
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

  final emptyPet = PetPod(pet: PetProfile(id: '', name: '', vaccines: [],
    ownerId: '', birthdate: DateTime.now(), breed: '',
    isMale: false, photoUrl: '', verified: false, ts: DateTime.now(),
    rateSum: 0, rateCount: 0, passport: "", lastModified: DateTime.now(),
      location: Location(longtitude: 0, latitude: 0)), isSelected: true);
  bool tapped = false;
  bool petDataLoading = false;
  var isLoading = true;
  bool mateBoxTapped = false;
  final vacEditing = ValueNotifier<int>(0);
  final viewVaccines = ValueNotifier<int>(0);
  final cacheLoaded = ValueNotifier<bool>(false);
  int notifCount = 0;

  // final multiController = List<MultiSelectController>.empty(growable: true);
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _controller2;
  late Animation<double> _animation2;


  List<PetPod> petPods = <PetPod>[];

  List<MateItem> receivedRequestPods = <MateItem>[];
  List<MateRequest> receivedRequests = <MateRequest>[];
  List<MateRequest> sentRequests = <MateRequest>[];

  final petIndex = ValueNotifier<int>(0);
  PetPod? selectedPet;
  final vaccineList = List<selectItem>.empty(growable: true);
  late var items = List<MultiSelectItem>.empty(growable: true);

  final petItemExtent = 28.w;

  late OverlayEntry loading = initLoading(context);
  bool requestsLoading = true;
  String petAge = "";
  String petRating = "";
  late GeoLocation userLocation;
  final scrollController = InfiniteScrollController();
  late CacheBox cacheBox;
  bool pScrollAnim = false;
  late StreamSubscription requestRecieveSub;
  late StreamSubscription requestSendSub;
  late RequestsProvider requestsProvider;

  @override
  void initState() {
    // updateLocation();
    runAfterCacheLoad();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation2 = CurvedAnimation(parent: _controller2, curve: Curves.easeIn);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      if (petPods.isNotEmpty){
        pScrollAnim = true;
        animatePetScroll();
      }
    });
  }

  runAfterCacheLoad() async{
    if (!cacheLoaded.value){
      await notifierChange(cacheLoaded);
    }
    usrHasPets();
    genRelations();
  }

  void animatePetScroll(){
    if (scrollController.hasClients){
      scrollController.animateToItem(petPods.length~/2);
    }else{
      // fix to await when build is done
      Future.delayed(const Duration(milliseconds: 1000)).then((value)
      {
        scrollController.animateTo((petItemExtent * (petPods.length-1) / 2), duration: Duration(milliseconds: 500), curve: Curves.easeIn);
      });
    }

  }

  // if user has no pets he is forced to add at least one pet
  usrHasPets() async {

    if (!cacheBox.ownerHasPets()) {
      homeNav_key.currentState?.pushNamedAndRemoveUntil(
          '/add_pet',(Route<dynamic> route) => false, arguments: true);
    }else{
      await updatePets();
      if (petPods.isEmpty){
        homeNav_key.currentState?.pushNamedAndRemoveUntil(
            '/add_pet', (Route<dynamic> route) => false, arguments: true);
      }
    }

    if (mounted && petPods.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      _controller2.forward();
      refreshSelectedPetInfo();
      _controller.forward();
    }


  }

  updatePets() async {
    petPods = await cacheBox.getUserPets();

    if (petPods.isNotEmpty && !pScrollAnim){
      int mean = petPods.length~/2;
      selectedPet = petPods[mean];
      animatePetScroll();
    }
    if (petPods.length == 1){
      setState(() {
        petPods[0].isSelected = true;
      });
    }
  }


  bool filterTest(MateRequest req){
    switch (req.status) {
      case requestState.pending:
        notifCount++;
        return false;
      case requestState.accepted:
      //load pet friend and
      // add to friends later
      //TODO: for now, fix later
      return true;
      case requestState.denied:
        // if (sent?? false){
        //   // delete from server
        // }
        return true;
      case requestState.undefined:
        // if (sent?? false){
        //   // delete from server
        // }
        return true;
    }
  }


  filterNotifications({required List<MateRequest> requests, bool? sent}){
    List<MateRequest> pendingReqs = <MateRequest>[];
    for ( MateRequest m in requests) {
      switch (m.status) {
        case requestState.pending:
          (sent?? false) ? null : notifCount++;
          pendingReqs.add(m);
          break;
        case requestState.accepted:
        //load pet friend and
        // add to friends later
          break;
        case requestState.denied:
          requests.remove(m);
          if (sent?? false){
            // delete from server
          }
          break;
        case requestState.undefined:
          requests.remove(m);
          if (sent?? false){
            // delete from server
          }
          break;
      }
    }
    setState(() {});
    return pendingReqs;
  }

  addRequestItems(List<PetProfile> pets){
    List<MateItem> newItems = <MateItem>[];

    for (PetProfile pet in pets){
      MateRequest req = receivedRequests.firstWhere((e) =>
      e.senderPet == pet.id);
      PetPod newPod = PetPod(pet: pet, isSelected: false, foreign: true);
      newItems.add(MateItem(sender_pet: newPod, request: req));
    }
    requestsProvider.addItems(newItems);
    print(requestsProvider.reqItems);
    return newItems;
  }

  getPetFromID(String id){
    return petPods.firstWhere((e) => e.pet.id == id);
  }

  genRelations() async{
    notifCount = 0;
    receivedRequests = cacheBox.cachedReceivedNotif;
    sentRequests = cacheBox.cachedSentNotif;
    filterNotifications(requests: receivedRequests);
    filterNotifications(requests: sentRequests, sent: true);
    try{
      if (receivedRequests.isNotEmpty){
        final petIDs = List<String>.generate(receivedRequests.length, (index) {
          return receivedRequests[index].senderPet;
        });

        List<PetProfile> generatedPets = await cacheBox.getPetList(petIDs);
        addRequestItems(generatedPets);
      }

      if (mounted){
        setState(() {
          requestsLoading = false;
        });
      }
    }catch (e){
      print("genRelations Error: $e");
    }

    notificationsListeners();
  }

  // FIX
  requestDelete({required String id, bool? fromServer}) async{
    int i = receivedRequests.indexWhere((element) => element.id == id);
    if (i != -1) {
      (receivedRequests[i].status == requestState.pending)
          ? notifCount--
          : null;
      receivedRequests.removeAt(i);
      requestsProvider.removeAt(receivedRequestPods.indexWhere((e) => e.request!.id == id));
      if (fromServer?? false) {
        await deleteRequestFromServer(id) ? null : print('failed');
      }
    }
  }

  List<MateRequest> manageModifiedRequests(List<MateRequest> requests){
    List<MateRequest> newRequests = <MateRequest>[];
    for (MateRequest req in requests){
      switch(req.status){
        case requestState.pending:
          newRequests.add(req);
          break;
        case requestState.denied:
        case requestState.undefined:
          requestDelete(id: req.id, fromServer: true);
          break;
        case requestState.accepted:
        // TODO: add to friends.
          break;
      }
    }
    return newRequests;
  }

  void notificationsListeners(){
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final lastSent = Timestamp.fromDate(cacheBox.lastSentNotif);
    final lastRec = Timestamp.fromDate(cacheBox.lastReceivedNotif);
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
          // TODO: try to change newReq to on variable requests and test removal filterNotifications
          requests.removeWhere((element) {
            return  filterTest(element);
          });
          List<MateRequest> newReq = filterNotifications(requests: requests);
          receivedRequests.addAll(newReq);
          List<String> petIds = List<String>.generate(newReq.length, (index) => newReq[index].senderPet);
          if (petIds.isNotEmpty){
            final newPets = await cacheBox.getPetList(petIds);
            List<MateItem> newItems = addRequestItems(newPets);
            if (newItems.length > 1){
              showOverlayNotification(duration: const Duration(milliseconds: 3000), (context) => MultiPetRequestBanner(pod: newItems[0], count: newItems.length-1, receiverPet: getPetFromID(newItems[0].request!.receiverPet)));

            }else{
              showOverlayNotification(duration: const Duration(milliseconds: 3000), (context) => PetRequestBanner(pod: newItems[0], receiverPet: getPetFromID(newItems[0].request!.receiverPet)));
            }
          }
        }
        setState(() {});
      }
    });

    requestSendSub = FirebaseFirestore.instance.collection('mateRequests')
        .where('senderId', isEqualTo: uid).where('lastModified', isGreaterThan: lastRec).snapshots().listen((data) {

      if (data.docs.isNotEmpty){
        final requests = mateRequestFromShot(data);
        cacheBox.addNewNotifications(items: requests, sent: true);
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

  @override
  void dispose() {
    _controller.dispose();
    vacEditing.dispose();
    viewVaccines.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    cacheBox = DataPassWidget.of(context);
    requestsProvider = pr.Provider.of<RequestsProvider>(context);
    cacheLoaded.value = true;
    return Scaffold(
        appBar: init_appBar(homeNav_key),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              isLoading ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(width: width*0.2, height: height*0.04, child: Shimmer(
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
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Your Pets',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
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
              isLoading ? Container(
                height: height*0.135,
                child: ShimmerOwnerPetCard(),
              ) : Container(
                height: 15.h,
                child: InfiniteCarousel.builder(
                  itemCount: petPods.length,
                  controller: scrollController,
                  itemExtent: petItemExtent,
                  anchor: 1,
                  velocityFactor: 1,
                  onIndexChanged: (index) {
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
                    if (!_controller.isCompleted){
                      _controller.forward();
                    }
                  },
                  axisDirection: Axis.horizontal,
                  loop: false,
                  itemBuilder: (context, itemIndex, realIndex) {
                    final currentOffset = petItemExtent * realIndex;
                    final itemsLength = petPods.length;
                    return AnimatedBuilder(
                      animation: scrollController,
                      builder: (context, child) {
                        final diff = (scrollController.offset - currentOffset);
                        final maxPadding = 3.w;
                        final carouselRatio = petItemExtent / maxPadding;
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: (diff / carouselRatio).abs(),
                            vertical: (diff / carouselRatio).abs(),
                          ),
                          child: GestureDetector(
                              onTap: (){
                                if(itemIndex == scrollController.selectedItem){
                                  if (petPods[itemIndex].isSelected){
                                    petPods[itemIndex].isSelected = false;
                                    selectedPet = null;
                                    petIndex.value = -1;
                                    setState(() {});
                                    _controller.reverse();
                                  }else{
                                    petPods[itemIndex].isSelected = true;
                                    selectedPet = petPods[itemIndex];
                                    petIndex.value = itemIndex;
                                    refreshSelectedPetInfo();
                                    setState(() {});
                                    _controller.forward();
                                  }
                                }else{
                                  scrollController.animateToItem(itemIndex);
                                }


                              },
                              child: CustomPet(pod: petPods[itemIndex])),
                        );
                      },
                    );
                  },
                ),
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
              ) : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isLoading? Container() : Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: FadeTransition(
                            opacity: _animation,
                            child: Container(
                              height: petIndex.value == -1 ? 0 : 30.h,
                              child: selectedPet == null ? null : Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Pet Details',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            )),
                                        Spacer(),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueGrey.shade900,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30.0))),
                                          icon: Icon(Icons.edit, size: width*0.03, color: Colors.white),
                                          onPressed: () {
                                            _popEditPage();
                                          },
                                          label: Text('Edit',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ColumnSuper(
                                    innerDistance: -2.5.h,
                                    children: [
                                      Container(
                                          height: 80,
                                          width: width*0.8,
                                          padding: EdgeInsets.all(width*0.04),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700]),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20)),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Icon(CupertinoIcons.calendar_circle_fill, color: Colors.white,),
                                                    SizedBox(width: width*0.009,),
                                                    Text(petAge, style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white
                                                    ),)
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              Container(
                                                child: Icon(selectedPet!.pet.isMale ? Icons.male_rounded : Icons.female_rounded,
                                                  color: selectedPet!.pet.isMale ? Colors.blue : Colors.pinkAccent,),
                                              )
                                            ],
                                          )
                                      ),
                                      Container(
                                        height: 80,
                                        width: width*0.7,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade900]),
                                            borderRadius:
                                            BorderRadius.circular(
                                                20)),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: ListTile(
                                                  leading: CircleAvatar(
                                                      backgroundColor: Colors.transparent,
                                                      child: Icon(
                                                        Icons
                                                            .vaccines,
                                                        color: Colors
                                                            .white,)),
                                                  title: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Vaccinations',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontFamily:
                                                              'Roboto',
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500),
                                                        ),
                                                        SizedBox(height: 10),
                                                        LinearPercentIndicator(
                                                          lineHeight: 5.0,
                                                          percent: (selectedPet!
                                                              .pet
                                                              .vaccines
                                                              .length /
                                                              8),
                                                          barRadius:
                                                          Radius.circular(
                                                              20),
                                                          backgroundColor:
                                                          Colors.blueGrey.shade900,
                                                          progressColor:
                                                          Colors.white,
                                                          trailing: Text(
                                                            '${(selectedPet!.pet.vaccines.length / 8 * 100).toInt()}%',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                                color: Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  AnimatedContainer(
                                    height: height*0.06,
                                    width: width*0.6,
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    duration: Duration(
                                        milliseconds: 1000),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            20)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: width*0.06,
                                          child: Image(image: AssetImage("assets/verifiedDocuments.png",),
                                            color: selectedPet!.pet.passport == "" ? Colors.redAccent.withOpacity(0.9):
                                            Colors.green.withOpacity(0.8), fit: BoxFit.contain,),
                                        ),
                                        selectedPet!.pet.passport == ""  ? ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueGrey.shade800,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30.0))),
                                          icon: Icon(Icons.add, size: width*0.03, color: Colors.white),
                                          onPressed: () {
                                            homeNav_key.currentState?.pushNamed('/petDocument', arguments: [selectedPet!]);
                                          },
                                          label: Text('Add passport',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w400)),
                                        ) : Row(
                                          children: [
                                            Text(
                                              petRating,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.blueGrey.shade500),
                                              overflow: TextOverflow.visible,
                                              textAlign: TextAlign.center,
                                            ),
                                            FittedBox(child: Icon(Icons.star_rate_rounded, color: CupertinoColors.activeOrange)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
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
                                  if ( value as bool == true){
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
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade900,
                                borderRadius: BorderRadius.circular(24.sp),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                      backgroundColor:
                                      Colors.redAccent,
                                      radius: 15,
                                      child: ImageIcon(
                                          AssetImage(
                                              'assets/mateIcon.png'),
                                          color: Colors.white, size: 20)),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'Find Mate',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Roboto',
                                        fontWeight:
                                        FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          GestureDetector(
                            onTap: ()async {
                              cacheBox.showCachePets();
                              showNotification(context, "Coming soon.");
                            },
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade900,
                                borderRadius: BorderRadius.circular(24.sp),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                    Colors.redAccent,
                                    radius: 15,
                                    child: Icon(Icons.circle_outlined, color: Colors.white),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'Pet Circle',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FadeTransition(
          opacity: _controller2,
          child: FittedBox(
            child: Stack(
              alignment: Alignment(1.4, -1.5),
              children: [
                FloatingActionButton(  // Your actual Fab
                  onPressed: requestsLoading ? null : () async{

                    homeNav_key.currentState?.pushNamed('/notif', arguments: [receivedRequestPods, petPods]).then((value){
                      // refreshNotificationCount();
                    });
                  },
                  child: Icon(Icons.local_fire_department_rounded, color: Colors.orange,),
                  backgroundColor: Colors.blueGrey.shade800,
                ),
                notifCount == 0 ? Container() : Container(             // This is your Badge
                  child: Center(
                    // Here you can put whatever content you want inside your Badge
                    child: Text('${notifCount}', style: TextStyle(color: Colors.white)),
                  ),
                  padding: EdgeInsets.all(3),
                  constraints: BoxConstraints(minHeight: 32, minWidth: 32),
                  decoration: BoxDecoration( // This controls the shadow
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 1,
                          blurRadius: 5,
                          color: Colors.black.withAlpha(50))
                    ],
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.redAccent,  // This would be color of the Badge
                  ),
                ),
              ],
            ),
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
