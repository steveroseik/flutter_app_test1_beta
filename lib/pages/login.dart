import 'package:firebase_core/firebase_core.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import '../FETCH_wdgts.dart';
import 'package:flutter_app_test1/APILibraries.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {

  final emailField = TextEditingController();
  final passField = TextEditingController();
  final Size windowSize = MediaQueryData.fromWindow(window).size;
  late OverlayEntry loading = initLoading(context, windowSize);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    emailField.dispose();
    passField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: emailField,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Email',
                      )
                      ,
                    ),
                    TextFormField(
                      controller: passField,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Password',
                      )
                      ,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:  EdgeInsets.all(10),
                          child: Text('Forgot Password?',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [ElevatedButton(
                        onPressed: () async{
                          SignInAuth();
                        },
                        child: Text("Login", textAlign: TextAlign.center),
                      )
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(

                            onTap: (){
                              rootNav_key.currentState?.popAndPushNamed('/signup');
                            },
                            child: const Text('No account?',
                              textAlign: TextAlign.left,
                            ),

                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                        ),
                        onPressed: () {

                          rootNav_key.currentState?.popAndPushNamed('/signupEmail');
                        },
                        child: Text("Signup with email", textAlign: TextAlign.center),
                      )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                        ),
                        onPressed: () {
                          print(FirebaseAuth.instance.currentUser!.email);
                        },
                        child: Text("Signup with google", textAlign: TextAlign.center),
                      )
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),

    );
  }

  Future SignInAuth() async {

    setState((){});
    if (!loading.mounted){
      OverlayState? overlay = Overlay.of(context);
      overlay?.insert(loading);
    }

    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailField.text, password: passField.text);
    } on FirebaseAuthException catch (e){
      print(e);
    }

    setState((){});
    if (loading.mounted){
      loading.remove();
    }



  }
}
