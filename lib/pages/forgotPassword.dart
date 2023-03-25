import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';

import '../FETCH_wdgts.dart';

class ForgotPass extends StatefulWidget {
  final String emailPushed;
  const ForgotPass({Key? key, required this.emailPushed}) : super(key: key);

  @override
  State<ForgotPass> createState() => _ForgotPassEmailState();
}

class _ForgotPassEmailState extends State<ForgotPass> {
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
  void initState() {
    if (widget.emailPushed != null){
      emailField.text = widget.emailPushed;
    }
    super.initState();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Forgot Password',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        )),
                    SizedBox(height: 20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async{
                            resetPassword();
                          },
                          child: Text("Reset Password", textAlign: TextAlign.center),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future resetPassword() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailField.text.trim());
    }on FirebaseAuthException catch (e){
      showSnackbar(context, e.message!);
    }
    showNotification(context, 'An email has been sent to reset your password.');

  }


}
