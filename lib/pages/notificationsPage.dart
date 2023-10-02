import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/DataPass.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:provider/provider.dart';

import '../JsonObj.dart';
import '../cacheBox.dart';



class NotificationsPage extends StatefulWidget {
  NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  late CacheBox cacheBox;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  List<MateRequest> matches = [];
  List<MateRequest> petRequests = [];

  List<PetProfile> get ownerPets => cacheBox.ownerPets;



  //TODO: FIX ERROR DELETE AND REDO
  // updateRequests(int index){
  //   switch(widget.requests[index].request!.status){
  //     case requestState.denied:
  //       // update server
  //       widget.requests.removeAt(index);
  //       break;
  //     case requestState.accepted:
  //       break;
  //     default: null;
  //   }
  // }

  // filterMatches(){
  //   for (MateItem item in widget.requests){
  //     if (item.stat == requestState.accepted){
  //       matches.add(item);
  //     }
  //     if (item.stat == requestState.pending) {
  //       petRequest.add(item);
  //     }
  //   }
  // }

  // extract pet receiver details
  fetchReceiverPet(String petID){
    for (var pet in ownerPets){
      if (pet.id == petID) return pet;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {


    });
      super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    cacheBox = context.watch<CacheBox>();
    matches = cacheBox.allRequests.where((e) => e.status == requestState.accepted).toSetWithRules().toList();
    petRequests = cacheBox.allRequests.where((e) => ((e.receiverId == uid) &&
        e.status == requestState.pending)).toList();
    return Scaffold(
      appBar: init_appBar(homeNav_key),
      body: Container(
        alignment: Alignment.bottomCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            matches.isEmpty ? Container() : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                  child: Text("Matches",
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800),),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  height: height*0.135,
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: matches.length,
                        itemBuilder: (context, index){
                          final petData = matches[index].senderId == uid ? matches[index].receiverPet :  matches[index].senderPet;
                          final heroTag = '${petData!.photoUrl}${Random().nextInt(40)}';
                          return InkWell(
                            onTap: (){
                              homeNav_key.currentState?.pushNamed('/petProfile', arguments: [
                                PetPod(pet: petData, isSelected: false, foreign: true), matches[index], null, heroTag]);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blueGrey.shade900,
                                    radius: 34*height*0.0012,
                                    child: Hero(
                                      tag: heroTag,
                                      child: CircleAvatar(
                                        backgroundColor: CupertinoColors.extraLightBackgroundGray,
                                        radius: 34*height*0.0012-1,
                                        backgroundImage: NetworkImage(petData.photoUrl),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  FittedBox(child: Text(petData.name, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),))
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Text("Notifications",
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800),),
            ),
            SizedBox(height: height*0.03,),
            petRequests.isEmpty ? Center(
              child: Text(
                "No new requests.",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: width*0.04,
                    fontWeight: FontWeight.w500,color: CupertinoColors.systemGrey2),
                textAlign: TextAlign.center,
              ),
            ) :
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: petRequests.length,
                    itemBuilder: (context, index){
                      final petData = petRequests[index].senderId == uid ? petRequests[index].receiverPet :  petRequests[index].senderPet;
                      final heroTag = '${petData!.photoUrl}${Random().nextInt(40)}';
                      return InkWell(
                        onTap: (){
                          homeNav_key.currentState?.pushNamed('/petProfile', arguments: [
                            PetPod(pet: petData, isSelected: false, foreign: true), petRequests[index], petRequests[index].receiverPet, heroTag]);
                        },
                        child: PetRequestBanner(request: petRequests[index], heroTag: heroTag),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
