import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_app_test1/verifyPhone.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_test1/configuration.dart';
import 'package:age_calculator/age_calculator.dart';
import '../JsonObj.dart';
import '../mainApp.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  //Controllers
  final phoneNumber = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final TextEditingController ageFieldController = TextEditingController();
  final curUser = FirebaseAuth.instance.currentUser;
  String city = 'Cairo';
  String country = 'Egypt';
  DateTime userBirthDate = DateTime.now();
  bool isComplete = false;
  bool isLoading = true;
  late usrState emailController;

  @override
  void initState() {
    userVerified();
    super.initState();
  }

  void userVerified() async{
    await FirebaseAuth.instance.currentUser?.reload();
    final uemail = FirebaseAuth.instance.currentUser!.email.toString();
    final uid = FirebaseAuth.instance.currentUser!.uid.toString();

    emailController = await userInDb(uemail, uid);
    setState(() {
      isLoading = false;
    });

    switch(emailController){
      case usrState.connectionError:
        showSnackbar(context, 'connection time out');
        FirebaseAuth.instance.signOut();
        break;
      case usrState.userAlreadyExists:
        showSnackbar(context, 'Duplicate email.');
        // FirebaseAuth.instance.currentUser?.delete();
        FirebaseAuth.instance.signOut();
        break;
      case usrState.newUser:
        setState((){
          isComplete = false;
        });
        break;
      case usrState.completeUser:
        setState((){
          isComplete = true;
          // fetchUserPets();
        });
        break;
    }
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneNumber.dispose();
    firstName.dispose();
    lastName.dispose();
    email.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    var userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) email.text = userEmail;

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    void showDatePicker()
    {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext builder) {
            return Container(
              height: MediaQuery.of(context).copyWith().size.height*0.25,
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
                            ageFieldController.text = userBirthDate.year.toString() + '-' + userBirthDate.month.toString() + '-' +userBirthDate.day.toString();
                          }
                        });


                      },
                      initialDateTime: DateTime.now().subtract(Duration(days: 365*12)),
                      minimumYear: DateTime.now().year - 100,
                      maximumYear: DateTime.now().year - 12,
                      maximumDate: DateTime.now(),
                    ),
                  ),
                ],
              ),
            );
          }
      );

    }

    return isLoading ? LoadingPage() : isComplete ? mainApp() : GestureDetector(
      onTap:(){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: SingleChildScrollView(
            child: Column(
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            controller: firstName,
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
                                labelText: 'First name',
                              ),
                          )
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            controller: lastName,
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
                              labelText: 'Last name',
                            ),
                          )
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            controller: email,
                            enabled: userEmail == null ? true : false,
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
                              labelText: 'Email',
                            ),
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: ageFieldController,
                                readOnly: true,
                                enabled: false,
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
                                  labelText: 'Birthdate',
                                ),
                              ),
                            ),
                            IconButton(
                                color: Colors.teal.shade100,
                                onPressed: (){
                                  showDatePicker();
                                },
                                icon: Icon(Icons.calendar_month,
                                    color: Colors.grey.shade900)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: CupertinoColors.extraLightBackgroundGray,
                                    border: Border.all(color: Colors.grey.shade300)
                                ),
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(5),
                                child: DropdownButton<String>(
                                  value: country,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      country = newValue!;
                                    });
                                  },
                                  items: <String>['Egypt']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 30),
                                        child: Text(value),
                                      ),
                                    );
                                  }).toList(),
                                )
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: CupertinoColors.extraLightBackgroundGray,
                                  border: Border.all(color: Colors.grey.shade300)
                                ),
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(5),
                                child: DropdownButton<String>(
                                  value: city,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      city = newValue!;
                                    });
                                  },
                                  items: <String>['Cairo','Giza', 'Alexandria', 'Marsa Matrouh']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
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
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
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
                                  labelText: 'Phone number',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),
                          onPressed: () async{
                              bool grantedRegistration = true;
                              encryptString('me');
                              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.text)){
                                grantedRegistration = false;

                              }
                              if (firstName.text == ""){
                                // first name invalid
                                grantedRegistration = false;
                              }
                              if (lastName.text == ""){
                                // last name invalid
                                grantedRegistration = false;
                              }

                              if (phoneNumber.text.length != 10){
                                //invalid phone number
                                grantedRegistration = false;
                              }
                              if (country.isEmpty){
                                // country not chosen
                                grantedRegistration = false;
                              }
                              if (city.isEmpty){
                                // city not chosen
                                grantedRegistration = false;
                              }
                              if (userBirthDate.toString().isEmpty){
                                // birthdate not selected
                                grantedRegistration = false;
                              }
                              if (grantedRegistration){
                                // successfully eligible to register
                                //encrypt password
                                var failedToSignup = true;
                                try{
                                  if (await checkPhoneAvailability(phoneNumber) == 200){
                                    if (await checkEmailAvailability(email) == 200){
                                      var resp = await addUser(curUser!.uid, email.text, int.parse(phoneNumber.text), firstName.text,
                                          lastName.text, country, city, ageFieldController.text);
                                      if (resp == 200){
                                        failedToSignup = false;
                                      }
                                    }else{
                                      showSnackbar(context, 'Email address already exists.');
                                    }

                                  }else{
                                    showSnackbar(context, 'Phone number already exists.');
                                  }
                                }catch(error){
                                  showSnackbar(context, error.toString());
                                }finally{
                                 if (failedToSignup){
                                   showSnackbar(context, 'Error in connection.');
                                 }else{
                                   userVerified();
                                 }
                                }
                              }else{
                                // incomplete fields
                              }
                          },
                          child: Text("Sign up", textAlign: TextAlign.center),
                        )
                        ],
                      ),
                    ],
                  ),

                ),
              ],
            )
        ),
      ),
    );
  }
}
