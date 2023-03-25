import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../FETCH_wdgts.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({Key? key}) : super(key: key);

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
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
                    Text('Choose your new email',
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
                            labelText: 'New email',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value != null &&
                                (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value))) {
                              return 'Please enter a valid email address';
                            } else {
                              return null;
                            }
                          },
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

                            final valid = _formKey.currentState?.validate();
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            if (valid != null && valid){
                              try{
                                await FirebaseAuth.instance.currentUser!.updateEmail(emailField.text);
                                try{
                                  await SupabaseCredentials.supabaseClient.from('users').update(
                                      {'email': emailField.text}).eq('id', uid);
                                  showNotification(context, 'Updated Email.');
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.clear();
                                  FirebaseAuth.instance.signOut();
                                }catch (e){
                                  print('failed with supabase: ${e}');
                                }
                              }catch (e){
                                print('failed with firebase: ${e}');
                              };
                            }else{
                              print('invalid');
                            }

                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Change Email", textAlign: TextAlign.center),
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
