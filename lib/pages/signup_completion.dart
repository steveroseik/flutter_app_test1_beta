import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_test1/configuration.dart';
import 'package:age_calculator/age_calculator.dart';
import '../JsonObj.dart';
import '../mainApp.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
// import 'package:firebase_auth/firebase_auth.dart';

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
  late email_verif emailController;

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
      case email_verif.connectionError:
        print('connection time out');
        FirebaseAuth.instance.signOut();
        break;
      case email_verif.userAlreadyExists:
        print('duplicate email: ' + uid);
        // FirebaseAuth.instance.currentUser?.delete();
        FirebaseAuth.instance.signOut();
        break;
      case email_verif.newUser:
        setState((){
          isComplete = false;
        });
        break;
      case email_verif.completeUser:
        setState((){
          isComplete = true;
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

    return isLoading ? LoadingPage() : isComplete ? mainApp() : Scaffold(
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
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'First name',
                          )
                          ,
                        )
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: TextFormField(
                          controller: lastName,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Last name',
                          )
                          ,
                        )
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: TextFormField(
                          controller: email,
                          enabled: userEmail == null ? true : false,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Email',
                          )
                          ,
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: ageFieldController,
                              readOnly: true,
                              placeholder: 'Select birth date',
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: CupertinoColors.extraLightBackgroundGray,
                                  borderRadius: BorderRadius.circular(10)
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
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.all(10),
                            child: DropdownButton<String>(
                              value: country,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15
                              ),
                              underline: Container(
                                height: 1,
                                color: Colors.grey[400],
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
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                        ),
                        Expanded(
                            child: DropdownButton<String>(
                              value: city,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15),
                              underline: Container(
                                height: 1,
                                color: Colors.grey[400],
                              ),
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
                            )
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: '+20',
                              )
                              ,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(

                            child: TextFormField(
                              controller: phoneNumber,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: '1223456789',
                              )
                              ,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                        onPressed: ()
                        async {
                          FirebaseAuth.instance.signOut();
                          if (phoneNumber.text.length != 10){
                            //ALERT USER
                          }else{
                            // await FirebaseAuth.instance.verifyPhoneNumber(
                            //   phoneNumber: "0" + phoneNumber.text,
                            //   verificationCompleted: (PhoneAuthCredential credential) {},
                            //   verificationFailed: (FirebaseAuthException e) {},
                            //   codeSent: (String verificationId, int? resendToken) {},
                            //   codeAutoRetrievalTimeout: (String verificationId) {},
                            // );
                          }
                        }
                     ,
                        child: Text("Verify Phone"),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(

                        onTap: (){
                          rootNav_key.currentState?.pop();
                          rootNav_key.currentState?.pushNamed('/login');
                        },
                        child: const Text('Already a user? Login',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),

                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [ElevatedButton(
                        onPressed: () async{
                            bool grantedRegistration = true;
                            encryptString('me');
                            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.text)){
                              grantedRegistration = false;

                            }
                            if (firstName.text == ""){
                              // first name invalid
                              print('fname invalid');
                              grantedRegistration = false;
                            }
                            if (lastName.text == ""){
                              // last name invalid
                              print('lname invalid');
                              grantedRegistration = false;
                            }

                            if (phoneNumber.text.length != 10){
                              //invalid phone number
                              print('phone invalid');
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
                                if (userAvailCheckFromJson(await checkPhoneAvailability(phoneNumber)).code == 200){
                                  if (userAvailCheckFromJson(await checkEmailAvailability(email)).code == 200){
                                    var resp = await addUser(curUser!.uid, email.text, int.parse(phoneNumber.text), firstName.text,
                                        lastName.text, country, city, ageFieldController.text);
                                    print(resp);
                                    if (userAvailCheckFromJson(resp).code == 200){
                                      failedToSignup = false;
                                    }
                                  }else{
                                    print('email address already exists');
                                  }

                                }else{
                                  print('phone number already exists');
                                }
                              }catch(error){
                                print('the error: ' + error.toString());
                                if (userAvailCheckFromJson(await checkPhoneAvailability(phoneNumber)).code == 200){
                                  if (userAvailCheckFromJson(await checkEmailAvailability(email)).code == 200){
                                    var resp = await addUser(curUser!.uid, email.text, int.parse(phoneNumber.text), firstName.text,
                                        lastName.text, country, city, ageFieldController.text);
                                    print(resp);
                                    if (userAvailCheckFromJson(resp).code == 200) {
                                      failedToSignup = false;
                                    }
                                  }else{
                                    print('email address already exists');
                                  }

                                }else{
                                  print('phone number already exists');
                                }
                              }finally{
                               if (failedToSignup){
                                 print('Error in connection.');
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
    );
  }
}
