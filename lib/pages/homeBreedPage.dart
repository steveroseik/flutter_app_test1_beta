import 'dart:convert';
import 'dart:ui';
import 'package:age_calculator/age_calculator.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:flutter_app_test1/breedAdopt_main.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/editPetPage.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../FETCH_wdgts.dart';
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
  final emptyPet = PetPod(PetProfile(id: '', name: '', vaccines: [],
    ownerId: '', birthdate: DateTime.now(), breed: '',
    isMale: false, photoUrl: '', verified: false, createdAt: DateTime.now(), rateSum: 0, rateCount: 0, passport: ""), true, GeoLocation(0.0, 0.0), 0);
  bool tapped = false;
  bool petDataLoading = false;
  var isLoading = true;
  bool mateBoxTapped = false;
  final vacEditing = ValueNotifier<int>(0);
  final viewVaccines = ValueNotifier<int>(0);
  int notifCount = 0;

  // final multiController = List<MultiSelectController>.empty(growable: true);
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _controller2;
  late Animation<double> _animation2;

  List<PetPod> petPods = <PetPod>[];

  List<MateItem> petReqItems = <MateItem>[];
  List<MateRequest> petRequests = <MateRequest>[];
  List<MateRequest> sentRequests = <MateRequest>[];

  final petIndex = ValueNotifier<int>(-1);
  PetPod? selectedPet;
  final vaccineList = List<selectItem>.empty(growable: true);
  late var items = List<MultiSelectItem>.empty(growable: true);

  final Size windowSize = MediaQueryData.fromWindow(window).size;
  late OverlayEntry loading = initLoading(context, windowSize);
  bool requestsLoading = true;
  String petAge = "";
  String petRating = "";
  late GeoLocation userLocation;

  // if user has no pets he is forced to add at least one pet
  usrHasPets() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.get('hasPets') != null && prefs.get('hasPets') == false) {
      if (this.mounted) setState(() {
        isLoading = false;
      });
      BA_key.currentState?.pushNamedAndRemoveUntil(
          '/add_pet', (Route<dynamic> route) => false);
    }else{
      await updatePets(petIndex.value);
      if (petPods.isEmpty){
        BA_key.currentState?.pushNamedAndRemoveUntil(
            '/add_pet', (Route<dynamic> route) => false);
      }
    }

    if (mounted && petPods.isNotEmpty) {
        setState(() {
        isLoading = false;
      });
      _controller2.forward();
    }


  }

  refreshNotificationCount(){
    notifCount = 0;
    for(MateRequest req in petRequests){
      if (req.status == 0) notifCount++;
    }
    if (this.mounted) {
      setState(() {
    });
    }
  }

  updatePets(int index) async {
    petPods = await fetchPets(index);
  }

  genRelations() async{
    notifCount = 0;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final  allRelations = await fetchPetsRelation(uid);
    for ( MateRequest m in allRelations){
      if (m.status != 1){
        if(m.receiverId == uid){
          petRequests.add(m);
          if (m.status == 0) notifCount ++;
        }
        if (m.senderId == uid){
          sentRequests.add(m);
        }
      }
    }

    final petIDs = List<String>.generate(petRequests.length, (index) {
      return petRequests[index].senderPet;
    });
    List<PetPod> generatedPets = await fetchRequestPets(petIDs);

    for (MateRequest req in petRequests){
      PetPod pet = generatedPets.firstWhere((element) =>
      element.pet.id == req.senderPet);
      petReqItems.add(MateItem(sender_pet: pet, request: req));
    }

    setState(() {
      requestsLoading = false;
    });


  }


  refreshSelectedPetInfo(){
    final age = AgeCalculator.dateDifference(fromDate: selectedPet!.pet.birthdate, toDate: DateTime.now());
    petAge = "";
    print(age.years);
    bool years = false;
    if (age.years > 1){
      petAge += age.years.toString() + " Years";
      years = true;
    }else if (age.years == 1){
      petAge += age.years.toString() + " Year";
      years = true;
    }
    if (age.months > 1){
      petAge += ( years ? ", " : "" ) + age.months.toString() + "Months";
    }else if (age.months == 1){
      petAge += ( years ? ", " : "" )  + age.months.toString() + "Month";
    }

    if (selectedPet!.pet.rateCount > 0){
      petRating = (selectedPet!.pet.rateSum ~/ selectedPet!.pet.rateCount).toString() + " / 5";
    }else{
      petRating = 'n/a';
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
    print('finished');
  }

  @override
  void initState() {
    updateLocation();
     usrHasPets();
     genRelations();
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

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
            appBar: init_appBar(BA_key),
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
                          BA_key.currentState?.pushNamed('/add_pet');
                        },
                        label: Text('New pet',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  isLoading ? Container(
                    height: height*0.135,
                    child: ShimmerOwnerPetCard(),
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: height*0.13,
                        width: width * 0.9,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: petPods.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: tapped ? null
                                    : () async {
                                  if (selectedPet != null && selectedPet == petPods[index]){
                                      _controller.reverse().then((value) {
                                        petPods[index].isSelected = false;
                                        selectedPet = emptyPet;
                                        petIndex.value = -1;
                                        setState(() {});
                                      });
                                  }else{
                                    tapped = true;
                                    for (var item in petPods) {
                                      item.isSelected = false;
                                    }
                                    petPods[index].isSelected = true;
                                    if (petIndex.value == -1 && index != -1) {
                                      selectedPet = petPods[index];
                                      _controller.forward();
                                      petIndex.value = index;
                                      refreshSelectedPetInfo();
                                      setState(() {});
                                    } else {
                                      if (index != -1) {
                                        if (selectedPet != petPods[index]) {
                                          selectedPet = petPods[index];
                                          refreshSelectedPetInfo();
                                          setState(() {
                                            viewVaccines.value = 0;
                                            petIndex.value = index;
                                          _controller.reset();
                                          _controller.forward();
                                          });
                                        }
                                      }
                                    }
                                    tapped = false;
                                  }
                                },
                                child: CustomPet(
                                    pod: petPods[index]),
                              );
                            })
                      ),
                    ],
                  ),
                  SizedBox(height: height*0.045),
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
                      child: Container(
                        child: Column(
                          children: [
                            isLoading? Container() : Container(
                                width: width,
                                child: ValueListenableBuilder<int>(
                                  valueListenable: petIndex,
                                  builder: (BuildContext context, int value,
                                      Widget? child) {
                                    if (value != -1) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        child: AnimatedOpacity(
                                          opacity: value == -1 ? 0 : 1,
                                          duration: Duration(seconds: 3),
                                          child: FadeTransition(
                                            opacity: _controller,
                                            child: Column(
                                              children: [

                                                ColumnSuper(
                                                  innerDistance: -20,
                                                  children: [
                                                    AnimatedContainer(
                                                      height: 80,
                                                      width: width*0.8,
                                                      padding: EdgeInsets.all(width*0.04),
                                                      duration: Duration(
                                                          milliseconds: 1000),
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
                                                    AnimatedContainer(
                                                      height: 80,
                                                      width: width*0.7,
                                                      duration: Duration(
                                                          milliseconds: 1000),
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
                                                      selectedPet!.pet.passport == ""  ?ElevatedButton.icon(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.blueGrey.shade800,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(30.0))),
                                                        icon: Icon(Icons.add, size: width*0.03, color: Colors.white),
                                                        onPressed: () {
                                                          BA_key.currentState?.pushNamed('/petDocument', arguments: [selectedPet!]);
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
                                                SizedBox(height: 2,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [

                                                    ElevatedButton.icon(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.blueGrey,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(30.0))),
                                                      icon: Icon(Icons.edit, size: width*0.03, color: Colors.white),
                                                      onPressed: () {
                                                        _customSheet();
                                                      },
                                                      label: Text('Edit pet info',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w600)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return SizedBox();
                                    }
                                  },
                                )),
                            SizedBox(height: 10),
                            Container(
                              height: 100,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: tapped ? null : () async {
                                      setState(() {
                                        tapped = true;
                                      });
                                      if (petIndex.value != -1) {
                                        setState(() {});
                                        if (!loading.mounted) {
                                          OverlayState? overlay =
                                              Overlay.of(context);
                                          overlay?.insert(loading);
                                        }
                                        final pets = await getPetMatch(petPods[petIndex.value].pet);
                                        setState(() {});
                                        if (loading.mounted) {
                                          loading.remove();
                                        }
                                        BA_key.currentState?.pushNamed(
                                            '/petMatch',
                                            arguments: [selectedPet, pets, petRequests, sentRequests]).then((value) {
                                              if ( value as bool == true){
                                                BA_key.currentState?.pushNamed('/search_manual', arguments: [petPods, petRequests, sentRequests]);
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
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                              backgroundColor:
                                                  Colors.redAccent,
                                              radius: 15,
                                              child: ImageIcon(
                                                  AssetImage(
                                                      'assets/mateIcon.png'),
                                                  color: Colors.white, size: 20)),
                                          Spacer(),
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
                                  GestureDetector(
                                    onTap: (){
                                      BA_key.currentState?.pushNamed('/search_manual', arguments: [petPods, petRequests, sentRequests]);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width/3.5,
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade900,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                              backgroundColor:
                                                  Colors.redAccent,
                                              radius: 15,
                                              child: ImageIcon(
                                                  AssetImage(
                                                      'assets/searchIcon.png'),
                                                  size: 20,
                                                  color: Colors.white)),
                                          Spacer(),
                                          FittedBox(
                                            child: Text(
                                              'Search\nManually',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      showNotification(context, "Coming soon.");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade900,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                            Colors.redAccent,
                                            radius: 15,
                                            child: Icon(Icons.circle_outlined, color: Colors.white),
                                          ),
                                          Spacer(),
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
                            ),
                          ],
                        ),
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
                        BA_key.currentState?.pushNamed('/notif', arguments: [petReqItems, petPods]).then((value){
                         refreshNotificationCount();
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

  void _customSheet(){
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder){
          return Container(height: MediaQuery.of(context).size.height * 0.8,
              child: EditPetPage(pod: selectedPet!.pet));
        }
    ).then((value) async{
      if (value != null && value){
        await updatePets(-1);
        petIndex.value = -1;
        petPods.forEach((element) {
          element.isSelected = false;
        });
        selectedPet = emptyPet;
        setState(() {

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
