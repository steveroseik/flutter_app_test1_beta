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
    isMale: false, photoUrl: '', ready: false, createdAt: DateTime.now(),), true);
  late BuildContext scaffoldContext;
  bool tapped = false;
  bool petDataLoading = false;
  var isLoading = true;
  bool mateBoxTapped = false;
  final vacEditing = ValueNotifier<int>(0);
  final viewVaccines = ValueNotifier<int>(0);

  // final multiController = List<MultiSelectController>.empty(growable: true);
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _controller2;
  late Animation<double> _animation2;

  List<PetPod> petPods = <PetPod>[];

  List<MateItem> petRequests = <MateItem>[];

  final petIndex = ValueNotifier<int>(-1);
  late PetPod selectedPet;
  final vaccineList = List<selectItem>.empty(growable: true);
  late var items = List<MultiSelectItem>.empty(growable: true);

  final Size windowSize = MediaQueryData.fromWindow(window).size;
  late OverlayEntry loading = initLoading(context, windowSize);
  bool requestsLoading = true;

  // if user has no pets he is forced to add at least one pet
  usrHasPets() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.get('hasPets') != null && prefs.get('hasPets') == false) {
      setState(() {
        isLoading = false;
      });
      BA_key.currentState?.pushNamedAndRemoveUntil(
          '/add_pet', (Route<dynamic> route) => false);
    }else{
      final resp = await fetchUserPets();
      if (!resp){
        BA_key.currentState?.pushNamedAndRemoveUntil(
            '/add_pet', (Route<dynamic> route) => false);
      }
    }
    await updatePets(petIndex.value);
    await getRequests();
    setState(() {
      isLoading = false;
    });
  }

  updatePets(int index) async {
    petPods = await fetchPets(index);
  }

  getRequests() async {
   requestsLoading = true;
   setState(() {});
    final uid = await FirebaseAuth.instance.currentUser!.uid;
    petRequests = await fetchPetRequests(uid).whenComplete(() {
     requestsLoading = false;
    });

   setState(() {});


  }

  getSelectedPet() {
    try {
      return selectedPet;
    } catch (e) {
      showSnackbar(context, 'Select a pet first');
      return null;
    }
  }
  createPetVaccines(){
    vaccineList.clear();
    for ( MapEntry entry in vaccineFList.entries){
      vaccineList.add(selectItem(entry.value, selectedPet.pet.vaccines.contains(entry.key) ? true : false));
    }
    items = vaccineList
        .map((vac) => MultiSelectItem<selectItem>(vac, vac.name))
        .toList();
  }


  @override
  void initState() {
    usrHasPets();
    super.initState();
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
    _controller.stop();
    _controller2.stop();
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
            appBar: init_appBarBreed(BA_key),
            body: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: height / 6,
                        width: width * 0.9,
                        padding: EdgeInsets.all(10),
                        child: isLoading ? ShimmerOwnerPetCard() : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: petPods.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: tapped ? null
                                    : () async {
                                  if (selectedPet == petPods[index]){
                                    petPods[index].isSelected = false;
                                    selectedPet = emptyPet;
                                  }else{
                                    tapped = true;
                                    for (var item in petPods) {
                                      item.isSelected = false;
                                    }
                                    petPods[index].isSelected = true;
                                    if (petIndex.value == -1 && index != -1) {
                                      selectedPet = petPods[index];
                                      petIndex.value = index;
                                      _controller.forward().then((value) {});
                                      createPetVaccines();
                                      setState(() {});
                                    } else {
                                      if (index != -1) {
                                        if (selectedPet != petPods[index]) {
                                          _controller.reverse().then((value) {
                                            selectedPet = petPods[index];
                                            createPetVaccines();
                                            setState(() {
                                              viewVaccines.value = 0;
                                              petIndex.value = index;

                                            });

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
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        child: Column(
                          children: [
                            Container(
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
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Text('Age',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w800,
                                                              color: Colors.grey
                                                            ),),
                                                          SizedBox(height: 5),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(20),
                                                                color: CupertinoColors.extraLightBackgroundGray,
                                                              ),child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                                                            child: Text("${AgeCalculator.dateDifference(fromDate: selectedPet.pet.birthdate, toDate: DateTime.now()).years}",
                                                              style: TextStyle(
                                                                color: Colors.grey,
                                                                fontWeight: FontWeight.w800,
                                                              ),),
                                                          )),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        children: [
                                                          Text('Gender',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w800,
                                                              color: Colors.grey,
                                                            ),),
                                                          SizedBox(height: 5),
                                                          Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 5),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(20),
                                                                color: CupertinoColors.extraLightBackgroundGray,
                                                              ),child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                                                            child: Text((selectedPet.pet.isMale ? 'Male' : 'Female'),
                                                              style: TextStyle(
                                                                color: Colors.grey,
                                                                fontWeight: FontWeight.w600,
                                                              ),),
                                                          )),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        children: [
                                                          Text('Mates',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w800,
                                                              color: Colors.grey,
                                                            ),),
                                                          SizedBox(height: 5),
                                                          Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(20),
                                                                color: CupertinoColors.extraLightBackgroundGray,
                                                              ),child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                                                            child: Text("${0}",
                                                              style: TextStyle(
                                                                color: Colors.grey,
                                                                fontWeight: FontWeight.w600,
                                                              ),),
                                                          )),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(height: 10,),
                                                AnimatedContainer(
                                                  height: 80,
                                                  duration: Duration(
                                                      milliseconds: 1000),
                                                  decoration: BoxDecoration(
                                                      color: CupertinoColors.extraLightBackgroundGray,
                                                      border: Border.all(
                                                          color: Colors.grey.shade300,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(height: 10),
                                                      Flexible(
                                                        child: ListTile(
                                                          leading: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.blueGrey,
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
                                                                      color: Colors
                                                                          .blueGrey,
                                                                      fontFamily:
                                                                      'Roboto',
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                                SizedBox(height: 10),
                                                                LinearPercentIndicator(
                                                                  lineHeight: 5.0,
                                                                  percent: selectedPet
                                                                      .pet
                                                                      .vaccines
                                                                      .length /
                                                                      8,
                                                                  barRadius:
                                                                  Radius.circular(
                                                                      20),
                                                                  backgroundColor:
                                                                  Colors.grey.shade300,
                                                                  progressColor:
                                                                  Colors.blueGrey,
                                                                  trailing: Text(
                                                                    '${(selectedPet.pet.vaccines.length / 8 * 100).toInt()}%',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                        color: Colors
                                                                            .blueGrey),
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
                                                SizedBox(height: 2,),
                                                ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(30.0))),
                                                  icon: Icon(Icons.edit, size: 10, color: Colors.blueGrey),
                                                  onPressed: () {
                                                    _customSheet();
                                                  },
                                                  label: Text('Edit pet info',
                                                      style: TextStyle(
                                                          color: Colors.blueGrey,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600)),
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
                            isLoading ?
                            Container(
                              height: 100,
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Shimmer(
                                      gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.grey.shade300
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    flex: 1,
                                    child: Shimmer(
                                      gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.grey.shade300
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : Container(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      if (getSelectedPet() != null) {
                                        setState(() {});
                                        if (!loading.mounted) {
                                          OverlayState? overlay =
                                              Overlay.of(context);
                                          overlay?.insert(loading);
                                        }
                                        final pets = await getPetMatch();
                                        setState(() {});
                                        if (loading.mounted) {
                                          loading.remove();
                                        }
                                        BA_key.currentState?.pushNamed(
                                            '/petMatch',
                                            arguments: [selectedPet, pets]);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade700,
                                        border: Border.all(
                                            color: CupertinoColors
                                                .extraLightBackgroundGray,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
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
                                          SizedBox(width: 10),
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
                                  SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: (){
                                      BA_key.currentState?.pushNamed('/search_manual');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade800,
                                        border: Border.all(
                                            color: CupertinoColors
                                                .extraLightBackgroundGray,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                          SizedBox(width: 10),
                                          Text(
                                            'Search Manually',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: (){
                                      BA_key.currentState?.pushNamed('/search_manual');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade900,
                                        border: Border.all(
                                            color: CupertinoColors
                                                .extraLightBackgroundGray,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(25),
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
                                          SizedBox(width: 10),
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
                            SizedBox(
                              height: 20,
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Mate Requests',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      )),
                                  Spacer(),
                                  IconButton(onPressed: (){
                                    getRequests();
                                  },
                                      icon: Icon(Icons.refresh_rounded),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey.shade900,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0))))
                                ],
                              ),
                            ),
                            Divider(),
                            Container(
                              height: 300,
                              child: requestsLoading ? ShimmerPetRequestBanner(context):
                              ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: petRequests.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: (){
                                        _modalBottomSheetMenu(petRequests[index]);
                                      },
                                      child: PetRequestBanner(
                                          pod: petRequests[index]),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            //
            );
  }

  void _showMultiSelect(BuildContext context, Widget widget) async {
    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      builder: (ctx) {
        return  MultiSelectBottomSheet(
          items: items,
          onConfirm: (values) {
            // print(values as List<dynamic>);
          },
          maxChildSize: 0.8, initialValue: [items],
        );
      },

    );
  }

  void _modalBottomSheetMenu(MateItem request){
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder){
          return new Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height/2,
            color: Colors.transparent, //could change this to
            //so you don't have to change MaterialApp canvasColor
            child: PetRequestCard(request: request)
          );
        }
    ).then((value) async{
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('petReqAction') == true){
        getRequests();
        prefs.setBool('petReqAction', false);
      }
    });
  }

  void _customSheet(){
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder){
          return Container(height: MediaQuery.of(context).size.height * 0.8,
              child: EditPetPage(pod: selectedPet.pet));
        }
    ).then((value) async{
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('petReqAction') == true){
        getRequests();
        prefs.setBool('petReqAction', false);
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
