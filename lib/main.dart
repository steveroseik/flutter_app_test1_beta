import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/pages/signup_completion.dart';
import 'package:flutter_app_test1/verifyPhone.dart';
import 'package:flutter_app_test1/verifyWidget.dart';
import 'FETCH_wdgts.dart';
import 'Login_main.dart';
import 'firebase_options.dart';
import 'mainApp.dart';
import 'package:flutter_app_test1/pages/emailVerify.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp( MaterialApp(
    home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if (snapshot.hasData){
            if (FirebaseAuth.instance.currentUser!.emailVerified){
              if (FirebaseAuth.instance.currentUser!.phoneNumber != null){
                return VerifyPhoneWidget();
              }else{

                fetchUserPets();
                return Signup();
              }
            }else{
              return verifyEmail();
            }

          }else{
            return LoginWidget();
          }
        }
    )
  ));
  
}



