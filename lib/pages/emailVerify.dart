import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/signup_completion.dart';

import '../mainApp.dart';

class verifyEmail extends StatefulWidget {
  const verifyEmail({Key? key}) : super(key: key);

  @override
  State<verifyEmail> createState() => _verifyEmailState();
}

class _verifyEmailState extends State<verifyEmail> {

  final codeField = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  var emailSent = false;
  bool emailVerified = false;
  Timer? timer;


  @override
  void initState() {

    if (FirebaseAuth.instance.currentUser != null){
      timer = Timer.periodic(Duration(seconds: 3), (_) async {

        await FirebaseAuth.instance.currentUser!.reload();
        setState(() {
          emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        });
        if (emailVerified) timer?.cancel();

      });


    }


    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) => emailVerified ? Signup() :
  Scaffold(
    body: Column(
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical:50),
            margin: EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text('FETCH',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    )),
                SizedBox(height: 5),
                Text('for dog community',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                    ))
              ],
            )
        ),
        SizedBox(height: 30),
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Verify Your Email'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [ElevatedButton(
                    onPressed: () async{
                      if (user != null){
                        try{
                          print(user!.displayName);
                          print(user!.email);
                          await user!.sendEmailVerification();
                          emailSent = true;
                        }on FirebaseAuthException catch (e){
                          print(e);
                        }
                      }
                    },
                    child: Text(!emailSent ? "Send Email" : "Resend Email", textAlign: TextAlign.center),
                  )
                  ],
                ),
              ],
            ),

          ),
        )
      ],
    ),
  );
}
