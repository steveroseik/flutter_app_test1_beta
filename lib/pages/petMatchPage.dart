import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../JsonObj.dart';

class PetMatchPage extends StatefulWidget {
  final PetPod senderPet;
  final List<PetProfile> pets;
  const PetMatchPage({Key? key, required this.pets, required this.senderPet}) : super(key: key);

  @override
  State<PetMatchPage> createState() => _PetMatchPageState();
}

class _PetMatchPageState extends State<PetMatchPage> {

   List<PetMatchCard> petMatches = <PetMatchCard>[];
   late List<Widget> petDialogs;
   bool petsReady = false;
   int swipeBool = 1;


   initPets() async{
     final prefs = await SharedPreferences.getInstance();
     final uLat = prefs.getDouble('lat');
     final uLong = prefs.getDouble('long');
    for (PetProfile pet in widget.pets){

      final pod = PetPod(pet, false, GeoLocation(0,0), 0);
      await pod.fetchLocation();
      final petView = PetMatchCard(pod: pod, sender: widget.senderPet);
      petMatches.add(petView);
      setState(() {
        petsReady = true;
      });
    }
  }

  @override
  void initState() {
    initPets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
          appBar: init_appBar(BA_key),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Mating Choices For ${widget.senderPet.pet.name}',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,color: Colors.blueGrey.shade800),
              ),
              petsReady ? Container(
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
        )
    );

  }
}
