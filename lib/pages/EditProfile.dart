import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../APILibraries.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';

import '../FETCH_wdgts.dart';

class EditProfile extends StatefulWidget {
  final Map userData;

  const EditProfile({Key? key, required this.userData}) : super(key: key);

  @override
  editprofile createState() => editprofile();
}

class editprofile extends State<EditProfile>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final emailField = TextEditingController();
  final phoneNumber = TextEditingController();
  final TextEditingController ageFieldController = TextEditingController();

  DateTime userBirthDate = DateTime.now();

  final Size windowSize = MediaQueryData.fromWindow(window).size;
  late OverlayEntry loading = initLoading(context, windowSize);

  @override
  void dispose() {
    emailField.dispose();
    super.dispose();
  }

  //bool _status = true;
  final FocusNode myFocusNode = FocusNode();

  initData() {
    firstName.text = widget.userData['firstName'];
    lastName.text = widget.userData['lastName'];
    emailField.text = widget.userData['email'];
    phoneNumber.text = widget.userData['phone'].toString();
    ageFieldController.text = widget.userData['birthdate'];
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  void showDatePicker() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            color: Colors.white,
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (value) {
                      setState(() {
                        if (value != null && value != userBirthDate) {
                          userBirthDate = value;
                          ageFieldController.text =
                              userBirthDate.year.toString() +
                                  '-' +
                                  userBirthDate.month.toString() +
                                  '-' +
                                  userBirthDate.day.toString();
                        }
                      });
                    },
                    initialDateTime:
                    DateTime.now().subtract(Duration(days: 365 * 12)),
                    minimumYear: DateTime.now().year - 100,
                    maximumYear: DateTime.now().year - 12,
                    maximumDate: DateTime.now(),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: init_appBar(settingsNav_key),
      body: ListView(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/Avatar.png'),
                  ),
                  TextButton(
                      onPressed: () {},
                      child: const Text('Change Profile Photo',
                          style: TextStyle(fontSize: 15)))
                ],
              )),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                        Widget>[
                      SizedBox(
                        width: 165,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 8),
                            child: TextFormField(
                              controller: firstName,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: CupertinoColors
                                            .extraLightBackgroundGray)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(20)),
                                filled: true,
                                fillColor:
                                CupertinoColors.extraLightBackgroundGray,
                                labelStyle: const TextStyle(color: Colors.grey),
                                labelText: 'First Name',
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'First name empty';
                                }
                              },
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                            )),
                      ),
                      SizedBox(
                        width: 165,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 8),
                            child: TextFormField(
                              controller: lastName,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: CupertinoColors
                                            .extraLightBackgroundGray)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(20)),
                                filled: true,
                                fillColor:
                                CupertinoColors.extraLightBackgroundGray,
                                labelStyle: const TextStyle(color: Colors.grey),
                                labelText: 'Last Name',
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'Last name empty';
                                }
                              },
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                            )),
                      )
                    ]),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: CupertinoColors
                                            .extraLightBackgroundGray)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(20)),
                                filled: true,
                                fillColor:
                                CupertinoColors.extraLightBackgroundGray,
                                labelStyle: TextStyle(color: Colors.grey),
                                labelText: '+20',
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 4,
                            child: TextFormField(
                              controller: phoneNumber,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: CupertinoColors
                                            .extraLightBackgroundGray)),
                                focusedBorder: OutlineInputBorder(
                                  //borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(20)),
                                filled: true,
                                fillColor:
                                CupertinoColors.extraLightBackgroundGray,
                                labelStyle: TextStyle(color: Colors.grey),
                                labelText: 'Phone number',
                              ),
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.length != 10) {
                                  return 'Invalid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2.5, horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: ageFieldController,
                              readOnly: true,
                              enabled: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: CupertinoColors
                                            .extraLightBackgroundGray)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(20)),
                                filled: true,
                                fillColor:
                                CupertinoColors.extraLightBackgroundGray,
                                labelStyle: TextStyle(color: Colors.grey),
                                labelText: widget.userData == ''
                                    ? ''
                                    : '${widget.userData['birthdate']}',
                              ),
                            ),
                          ),
                          IconButton(
                              color: Colors.teal.shade100,
                              onPressed: () {
                                showDatePicker();
                              },
                              icon: Icon(Icons.calendar_month,
                                  color: Colors.grey.shade900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          onPressed: () async {
                            final validForm = _formKey.currentState!.validate();
                            if (validForm) {
                              //SignupAuth();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("Save", textAlign: TextAlign.center),
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