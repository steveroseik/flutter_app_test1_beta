import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';

class NotificationsPage extends StatefulWidget {
  final List<MateItem> requests;
  const NotificationsPage({Key? key, required this.requests}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Text("New Requests",
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800),),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              height: height*0.13,
              width: double.infinity,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                    itemCount: widget.requests.length,
                    itemBuilder: (context, index){
                      return InkWell(
                        onTap: (){
                          BA_key.currentState?.pushNamed('/petProfile', arguments: widget.requests[index].sender_pet);
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blueGrey.shade900,
                              radius: 34*height*0.0012,
                              child: CircleAvatar(
                                radius: 30*height*0.0012,
                                backgroundImage: NetworkImage(widget.requests[index].sender_pet.pet.photoUrl),
                              ),
                            ),
                            Text(widget.requests[index].sender_pet.pet.name, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800),)
                          ],
                        ),
                      );
                    }),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Text("Matches",
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800),),
            ),
          ],
        ),
      ),
    );
  }
}
