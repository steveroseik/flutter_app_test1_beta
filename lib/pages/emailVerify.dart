import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/DataPass.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/signup_completion.dart';
import 'package:sizer/sizer.dart';
import '../mainApp.dart';
import '../routesGenerator.dart';

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

  sendEmail() async{
    try{
      await user!.sendEmailVerification();
      emailSent = true;
    }on FirebaseAuthException catch (e){
      showSnackbar(context, e.message!);
    }
  }
  @override
  void initState() {

    sendEmail();
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
  Widget build(BuildContext context) {
    final cacheBox = DataPassWidget.of(context);
    return emailVerified ? Signup(cacheBox: cacheBox) :
    Scaffold(
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(vertical:7.h),
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 3.h),
                  Text('FETCH',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                      )),
                  SizedBox(height: 0.5.h),
                  Text('for dog community',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 10.sp,
                      )),
                  SizedBox(height: 40.h), // unsupervised
                  Text('Verify Your Email Address',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                      )),
                  SizedBox(height: 1.5.h),
                  Text('An email has been sent to ${user!.email},\nplease click on the link and return to the app.',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 10.sp,
                    ),
                    textAlign: TextAlign.center,),
                ],
              )
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          )
                      ),
                      onPressed: () async {
                        if (user != null){
                          try{
                            await user!.sendEmailVerification();
                            emailSent = true;
                          }on FirebaseAuthException catch (e){
                            showSnackbar(context, e.message!);
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(!emailSent ? "Send Email" : "Resend Email"),
                      ),
                    ),
                    SizedBox(width: 20,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          )
                      ),
                      onPressed: () async {
                        if (user != null){
                          try{
                            // FIX
                            await FirebaseAuth.instance.signOut();
                          }on FirebaseAuthException catch (e){
                            showSnackbar(context, e.message!);
                          }
                        }
                        rootNav_key.currentState?.popAndPushNamed('/signEmail');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Change Email"),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          )
        ],
      ),
    );
  }
}
