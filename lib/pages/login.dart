import 'package:firebase_core/firebase_core.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

  final _formKey = GlobalKey<FormState>();
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(0, height/12, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
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
                  ),
                ],
              )
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Login',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        )),
                    SizedBox(height: height/10),
                    TextFormField(
                      controller: emailField,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20)),
                        filled: true,
                        fillColor: CupertinoColors.extraLightBackgroundGray,
                        labelStyle: TextStyle(color: Colors.grey),
                        labelText: 'Email',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value){
                          if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!)){
                            return 'Please enter a valid email address';
                          }
                          return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: passField,
                      obscureText: true,
                      decoration:InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        filled: true,
                        fillColor: CupertinoColors.extraLightBackgroundGray,
                        labelStyle: TextStyle(color: Colors.grey),
                        labelText: 'Password',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value){
                        if (value!.length == 0){
                          return "Enter your account password";
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: (){
                            rootNav_key.currentState?.pushNamed('/forgotPass', arguments: emailField.text);
                          },
                          child: const Padding(
                            padding:  EdgeInsets.symmetric(vertical: 10),
                            child: Text('Forgot Password?',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                        onPressed: () async{
                          SignInAuth();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                          child: Text("Login", textAlign: TextAlign.center),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                            backgroundColor: Colors.teal.shade100,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)
                            )
                        ),
                      )
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: const Text('No account?',
                            textAlign: TextAlign.left,
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
                          // userInDb("steveroseik@gmail.com", "ghasjdgjsa");
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
