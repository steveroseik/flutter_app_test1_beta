import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';
import '../FETCH_wdgts.dart';
import 'package:flutter_app_test1/APILibraries.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {

  GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final emailField = TextEditingController();
  final passField = TextEditingController();
  late OverlayEntry loading = initLoading(context);
  bool loginPressed = false;

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

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
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
              SizedBox(height: 5.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Form(
                    key: _formKey1,
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
                        SizedBox(height: 8.h),
                        TextFormField(
                          controller: emailField,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.sp)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.sp),
                              borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.sp)),
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
                                return 'Enter a valid email address';
                              }
                              return null;
                          },
                        ),
                        SizedBox(height: 1.h),
                        TextFormField(
                          controller: passField,
                          obscureText: true,
                          decoration:InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.sp)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.sp),
                                borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(25.sp)),
                            filled: true,
                            fillColor: CupertinoColors.extraLightBackgroundGray,
                            labelStyle: TextStyle(color: Colors.grey),
                            labelText: 'Password',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onTap: (){
                            passField.selection = TextSelection(baseOffset: 0, extentOffset: passField.length);
                          },
                          onFieldSubmitted: (value) async{
                            if (mounted && !loginPressed){
                              setState(() {
                                loginPressed = true;
                              });
                              final validForm = _formKey1.currentState!.validate();
                              if (validForm) {
                                await SignInAuth();
                              }
                              setState(() {
                                loginPressed = false;
                              });
                            }
                          },
                          validator: (value){
                            if (value!.isEmpty){
                              return "Enter your password";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                              onPressed: loginPressed? null : () async{
                                if (mounted){
                                  setState(() {
                                    loginPressed = true;
                                  });
                                  final validForm = _formKey1.currentState!.validate();
                                  if (validForm) {
                                    await SignInAuth();
                                  }
                                  setState(() {
                                    loginPressed = false;
                                  });
                                }

                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                  backgroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.sp)
                                  )
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 1.8.h),
                                child: Text("Login", textAlign: TextAlign.center, style: TextStyle(
                                  fontSize: 12.sp,
                                ),),
                              ),
                          ),
                            )
                          ],
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
                              backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)
                                )
                            ),
                            onPressed: () {

                              rootNav_key.currentState?.popAndPushNamed('/signupEmail');
                            },
                            child: Text("Signup with email", textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey),),
                          )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)
                                )
                            ),

                            onPressed: () {

                            },
                            child: Text("Signup with google", textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey)),
                          )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

      ),
    );
  }

  Future SignInAuth() async {

    setState((){});
    if (!loading.mounted){
      OverlayState? overlay = Overlay.of(context);
      overlay.insert(loading);
    }

    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailField.text, password: passField.text);
    } on FirebaseAuthException catch (e){
      showSnackbar(context, 'Failed. ${e.message?? ''}');
    }

    setState((){});
    if (loading.mounted){
      loading.remove();
    }



  }
}
