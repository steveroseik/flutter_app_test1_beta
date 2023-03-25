import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';

import '../FETCH_wdgts.dart';

class ReAuthPage extends StatefulWidget {
  const ReAuthPage({Key? key}) : super(key: key);

  @override
  State<ReAuthPage> createState() => _ReAuthPageState();
}

class _ReAuthPageState extends State<ReAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final emailField = TextEditingController();
  final passField = TextEditingController();
  final passField2 = TextEditingController();
  late OverlayEntry loading = initLoading(context);

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
        children: [
          Container(
              padding: EdgeInsets.symmetric(vertical: 50),
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
              )),
          SizedBox(height: 30),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Enter Your Account Password',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        )),
                    SizedBox(height: 30,),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextFormField(
                          controller: passField,
                          obscureText: true,
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
                            labelText: 'Password',
                          ),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)
                              )
                          ),
                          onPressed: () async {

                            String email = FirebaseAuth.instance.currentUser!.email!;
                            AuthCredential credential = EmailAuthProvider.credential(email: email, password: passField.text);
                            try{
                              await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
                              settingsNav_key.currentState?.pushNamed('/changeEmail');

                            }catch (e){print(e);}
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Authenticate", textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
