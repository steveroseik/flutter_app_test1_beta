import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';

class NotificationsPage extends StatefulWidget {
  List<MateItem> requests;
  final List<PetPod> ownerPets;
  NotificationsPage({Key? key, required this.requests, required this.ownerPets}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  bool notif = false;
  bool match = false;
  List<MateItem> matches = <MateItem>[];
  List<MateItem> petRequest = <MateItem>[];


  updateRequests(){
    match = false;
    notif = false;
    setState(() {

    });
    List<MateItem> tempMatch = <MateItem>[];
    List<MateItem> tempReq = <MateItem>[];
    widget.requests.clear();
    widget.requests.addAll(petRequest);
    widget.requests.addAll(matches);
    for (MateItem item in widget.requests){
      if (item.request!.status == 2){
        tempMatch.add(item);
      }else if (item.request!.status == 0) {
        tempReq.add(item);
      }
    }
    petRequest = tempReq;
    matches = tempMatch;
    if (matches.isNotEmpty ) match = true;
    if (petRequest.isNotEmpty) notif = true;
    setState(() {

    });
  }
  filterMatches(){
    for (MateItem item in widget.requests){
      if (item.request!.status == 2){
        matches.add(item);
      }
      if (item.request!.status == 0) {
        petRequest.add(item);
      }
    }
    if (matches.isNotEmpty ) match = true;
    if (petRequest.isNotEmpty) notif = true;
    setState(() {

    });
  }

  // extract pet receiver details
  fetchReceiverPet(String petID){
    for (PetPod pet in widget.ownerPets){
      if (pet.pet.id == petID) return pet;
    }
  }

  @override
  void initState() {
      filterMatches();
      super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: init_appBar(BA_key),
      body: Container(
        alignment: Alignment.bottomCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !match ? Container() : Column(
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
                          return InkWell(
                            onTap: (){
                              BA_key.currentState?.pushNamed('/petProfile', arguments: [matches[index], widget.ownerPets]);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blueGrey.shade900,
                                    radius: 34*height*0.0012,
                                    child: CircleAvatar(
                                      backgroundColor: CupertinoColors.extraLightBackgroundGray,
                                      radius: 34*height*0.0012-1,
                                      backgroundImage: NetworkImage(matches[index].sender_pet.pet.photoUrl),
                                    ),
                                  ),
                                  Spacer(),
                                  FittedBox(child: Text(matches[index].sender_pet.pet.name, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),))
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
            !notif ?  Center(
              child: Text(
                "No new requests.",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: width*0.04,
                    fontWeight: FontWeight.w500,color: CupertinoColors.systemGrey2),
                textAlign: TextAlign.center,
              ),
            ) : Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: petRequest.length,
                    itemBuilder: (context, index){
                      final PetPod petRec = fetchReceiverPet(petRequest[index].request!.receiverPet);
                      return InkWell(
                        onTap: (){
                          BA_key.currentState?.pushNamed('/petProfile', arguments: [petRequest[index],[petRec]])
                              .then((value) {
                            updateRequests();
                          });
                        },
                        child: PetRequestBanner(pod: petRequest[index], receiverPet: petRec),
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
