import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';


import '../JsonObj.dart';

class PetMatchPage extends StatefulWidget {
  final senderPet;
  final List<PetProfile> pets;
  const PetMatchPage({Key? key, required this.pets, required this.senderPet}) : super(key: key);

  @override
  State<PetMatchPage> createState() => _PetMatchPageState();
}

class _PetMatchPageState extends State<PetMatchPage> {

   late List<Widget> petMatches;
   late List<Widget> petDialogs;
   final dataReady = ValueNotifier<int>(0);
   int swipeBool = 1;
   final cardController = FlipCardController();



   initPets() async{
    petMatches = List<Widget>.generate(widget.pets.length, (index){
      return CustomPetMatch(pod: widget.pets[index]);
    });
    petDialogs = List<Widget>.generate(widget.pets.length, (index){
      return PetConfirmDialog(pod: widget.pets[index], sender: widget.senderPet);
    });
    dataReady.value = 1;
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
            children: [
              SizedBox(height: 40),
              Text(
                'Possible pets for mating',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 20,),
              Flexible(
                flex: 2,
                child: ValueListenableBuilder<int>(
                  valueListenable: dataReady,
                  builder: (context, value, widget){
                    if (value == 0){
                      return Text('Loading...');
                    }else{
                      return Container(
                        height: 300,
                        child: Swiper(
                          itemBuilder: (BuildContext context, int index) {
                            return  FlipCard(
                                rotateSide: RotateSide.left,
                                onTapFlipping: true,
                                axis: FlipAxis.vertical,
                                controller: cardController,
                                frontWidget: petMatches[index],
                                backWidget: petDialogs[index]
                            );
                            // return FlipCard(
                            //   key: cardKey,
                            //   fill: Fill.fillBack,
                            //   direction: FlipDirection.HORIZONTAL, // default
                            //   front: Container(
                            //     child: petMatches[index],
                            //   ),
                            //   back: Container(
                            //     child: petMatches[index],
                            //   ),
                            // );
                          },
                          itemCount: petMatches.length,
                          itemWidth: 350,
                          itemHeight: 400,
                          layout: SwiperLayout.STACK,
                        ),
                      );
                    }
                  },
                ),
              ),
              ElevatedButton(onPressed: ()async {

              }, child: Text('test'))
            ],
          ),
        )
    );
  }
}
