import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../APILibraries.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';

import '../FETCH_wdgts.dart';

class editSettings extends StatefulWidget {
  const editSettings({Key? key}) : super(key: key);

  @override
  editsetting createState() => editsetting();
}

class editsetting extends State<editSettings> {
  @override
  void initState() {
    super.initState();
  }

  bool iconBool = true;

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    bool loc = true;

    return SafeArea(
        child: Scaffold(
            appBar: init_appBar(settingsNav_key),
            body: Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(children: <Widget>[
                    SizedBox(height: 160),
                    InkWell(
                      onTap: () async {

                        settingsNav_key.currentState?.pushNamed('/reauth');
                      },
                      child: ProfileListItem(
                        icon: Icons.email_outlined,
                        text: 'Change Email',
                        icon2: LineAwesomeIcons.angle_right,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final email = FirebaseAuth.instance.currentUser!.email;
                        FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
                        showNotification(context, "An Email has been sent to ${email}.");
                      },
                      child: ProfileListItem(
                        icon: LineAwesomeIcons.lock,
                        text: 'Forgot Password',
                        icon2: LineAwesomeIcons.angle_right,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        if(iconBool == true){
                          iconBool = false;
                        }else if (iconBool == false) {
                          iconBool = true;
                        }
                        setState(() {

                        });
                      },
                      child: ProfileListItem(
                        icon: Icons.location_on_outlined,
                        text: 'Location',
                        icon2: iconBool ? LineAwesomeIcons.toggle_off : LineAwesomeIcons.toggle_on,
                      ),
                    ),
                  ]))
            ])));
  }
}
