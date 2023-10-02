import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/DataPass.dart';
import 'package:flutter_app_test1/cacheBox.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../APILibraries.dart';
import '../JsonObj.dart';
import '../routesGenerator.dart';

Color kAppPrimaryColor = Colors.white;
Color kWhite = Colors.black.withOpacity(0.05);
Color kLightBlack = Colors.black.withOpacity(0.05);
Color fCL = Colors.grey.shade600;

final kTitleTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

BoxDecoration avatarDecoration =
BoxDecoration(shape: BoxShape.circle, color: kAppPrimaryColor, boxShadow: [
  BoxShadow(
    color: kWhite,
    offset: Offset(10, 10),
    blurRadius: 10,
  ),
  BoxShadow(
    color: kWhite,
    offset: Offset(-10, -10),
    blurRadius: 10,
  ),
]);

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserPod userPod;
  List<Marker> markers = <Marker>[];
  Completer<GoogleMapController> _controller = Completer();
  bool isLoading = false;

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("Geolocation error: $error");
    });
    return await Geolocator.getCurrentPosition();
  }



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.height;
    CacheBox cacheBox = DataPassWidget.of(context);
    userPod = cacheBox.getUserInfo();
    return Scaffold(
      appBar: init_appBar(settingsNav_key),
      backgroundColor: kAppPrimaryColor,
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: height*0.06,
              backgroundColor: CupertinoColors.extraLightBackgroundGray,
              child: CircleAvatar(
                radius: height*0.06-2,
                backgroundColor: CupertinoColors.extraLightBackgroundGray,
                child:  isLoading || userPod.photoUrl == "" ? LayoutBuilder(builder: (context, constraint) {
                  return Icon(Icons.account_circle_rounded, size: constraint.biggest.height, color: Colors.white,);
                }) : null,
                backgroundImage: isLoading ? null : userPod.photoUrl == "" ? null :
                NetworkImage(userPod.photoUrl),
              ),
            ),
            const SizedBox(height: 5),
            isLoading ? Container() : Text(
              '${userPod.firstName.capitalize()} ${userPod.lastName.capitalize()}',
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Poppins"),
            ),
            SizedBox(height: height*0.015),
            Text(
              isLoading ? '' : '${userPod.email}',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Poppins",
                  color: Colors.grey),
            ),
            SizedBox(height: height*0.005),
            Text(
              isLoading ? '' : '+20 ${userPod.phone}',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Poppins",
                  color: Colors.grey),
            ),
            SizedBox(height: height*0.02),
            isLoading ?  Shimmer(
              gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
              child: GlassContainer(
                blur: 10,
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange.withOpacity(0.8), Colors.deepOrange.withOpacity(0.9)]),
                height: 60,
                width: 300*width*0.0008),
            ) : userPod.type == 1 ? GlassContainer(
              blur: 10,
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.withOpacity(0.8), Colors.deepOrange.withOpacity(0.9)]),
              height: 60,
              width: 300*width*0.0008,
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.verified_user_rounded,color: Colors.blueGrey.shade700),
                      Text('Account Verified',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey.shade700
                        ),),
                    ],
                  )
              ),
            ) : InkWell(
              onTap: (){
                settingsNav_key.currentState?.pushNamed('/verifyAccount', arguments: userPod).then((value) {
                  if (value as bool == true){
                    userPod.type = 1;
                    setState(() {

                    });
                  }
                });
              },
              child: GlassContainer(
                blur: 10,
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.red.shade700.withOpacity(0.8), Colors.redAccent.shade200.withOpacity(0.9)]),
                height: 60,
                width: 300*width*0.0008,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(CupertinoIcons.shield_lefthalf_fill,color: Colors.blueGrey.shade700),
                      Text('Verify Acccount',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey.shade700
                      ),),
                    ],
                  )
                ),
              ),
            ),
            Spacer(),
            Column(
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    settingsNav_key.currentState?.pushNamed(
                        '/editProfile',
                        arguments: userPod);
                  },
                  child: ProfileListItem(
                    icon: LineAwesomeIcons.pen,
                    text: 'Edit Profile',
                    icon2: LineAwesomeIcons.angle_right,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    settingsNav_key.currentState?.pushNamed(
                        '/setting');
                  },
                  child: ProfileListItem(
                    icon: LineAwesomeIcons.cog,
                    text: 'Settings',
                    icon2: LineAwesomeIcons.angle_right,

                  ),
                ),
                InkWell(
                  onTap: () async{
                    cacheBox.signOut();
                  },
                  child: ProfileListItem(
                    icon: LineAwesomeIcons.alternate_sign_out,
                    text: 'Logout',
                    icon2: LineAwesomeIcons.angle_right,

                  ),
                ),
              ],
            ),
          ],
        ),
      ),);
  }
}

class NumbersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      buildButton(context, '4.8', 'Ranking'),
      buildDivider(),
      buildButton(context, '3', 'Dogs'),
      buildDivider(),
      buildButton(context, '12', 'Friends'),
    ],
  );

  Widget buildDivider() => Container(
    height: 24,
    child: VerticalDivider(
      color: Colors.grey[500],
      thickness: 1,
    ),
  );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      );
}
