import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../JsonObj.dart';

class PetMatchPage extends StatefulWidget {
  final PetPod senderPet;
  final List<PetPod> pets;
  const PetMatchPage({Key? key, required this.pets, required this.senderPet}) : super(key: key);

  @override
  State<PetMatchPage> createState() => _PetMatchPageState();
}

class _PetMatchPageState extends State<PetMatchPage> with TickerProviderStateMixin {

   List<PetMatchCard> petMatches = <PetMatchCard>[];
   late List<Widget> petDialogs;
   bool petsReady = false;
   int swipeBool = 1;

   late AnimationController animControl;
   late Animation animation;

   initPets() async{
    for (PetPod pet in widget.pets){

      final petView = PetMatchCard(pod: pet, sender: widget.senderPet);
      petMatches.add(petView);
      setState(() {
        petsReady = true;
      });
      animControl.forward();
    }
  }

  @override
  void initState() {
     animControl = AnimationController(duration: Duration(seconds: 1), vsync: this);
     animation = CurvedAnimation(parent: animControl, curve: Curves.easeIn);
    initPets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     final height = MediaQuery.of(context).size.height;
     final width = MediaQuery.of(context).size.width;
    return Center(
        child: Scaffold(
          appBar: init_appBar(BA_key),
          body: !petsReady ? LoadingPage() : FadeTransition(
            opacity: animControl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mating Choices For ${widget.senderPet.pet.name}',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width*0.05,
                      fontWeight: FontWeight.w900,color: Colors.blueGrey.shade800),
                ),
                SizedBox(height: height*0.05,),
                petsReady ? petMatches.isEmpty ? Container(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Sorry, we couldn't find matches for ${widget.senderPet.pet.name} at the mean time. \n"
                              'You can try search manually',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: width*0.04,
                              fontWeight: FontWeight.w500,color: CupertinoColors.systemGrey2),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton.icon(
                          onPressed: (){
                           BA_key.currentState?.pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0)
                              )
                          ),
                          icon:  Icon(CupertinoIcons.search, color: Colors.black, size: width*0.045,),
                          label: Text('Search Manually', style: TextStyle(
                              color: Colors.black,
                              fontSize: width*0.035
                          ),),
                        ),
                      ],
                    ),
                  ),
                ): Container(
                  width: double.infinity,
                  height: 350,
                  child: Swiper(
                    itemWidth: 230,
                    itemHeight: double.infinity,
                    itemBuilder: (BuildContext context, int index) {
                      return  petMatches[index];
                      },
                    itemCount: petMatches.length,
                    layout: SwiperLayout.STACK,
        ),
                ) : Container(),
              ],
            ),
          ),
        )
    );

  }
}
