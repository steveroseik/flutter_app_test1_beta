import 'dart:async';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../APILibraries.dart';
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
  Map userData = Map<String, dynamic>();
  List<Marker> markers = <Marker>[];
  Completer<GoogleMapController> _controller = Completer();

  initUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    userData = await fetchUserData(uid);
    setState(() {});
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    initUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            elevation: 8,
            shadowColor: Colors.cyanAccent[70],
            title: const Text(
              "FETCH",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            leadingWidth: 0,
            backgroundColor: Colors.white70,
            actions: const []),
        backgroundColor: kAppPrimaryColor,
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 170,
                    height: 170,
                     padding: EdgeInsets.all(5),
                    decoration: avatarDecoration,
                    // child: Container(
                    //   decoration: avatarDecoration,
                    //   padding: EdgeInsets.all(3),
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       image: DecorationImage(
                    //         image:
                    //         userData['photoUrl'] == '' ? ImageIcon(AssetImage: 'assets/images/Avatar.png') :
                    //         NetworkImage(userData['photoUrl']),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userData == ''
                        ? ''
                        : '${userData['firstName']} ${userData['lastName']}',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Poppins"),
                  ),
                  SizedBox(height: 15),
                  NumbersWidget(),
                  SizedBox(height: 20),
                  Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          settingsNav_key.currentState?.pushNamed(
                              '/editProfile',
                              arguments: userData);
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
                        onTap: () {
                          FirebaseAuth.instance.signOut();
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
            )
          ],
        ),),
    );
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
