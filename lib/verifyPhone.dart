import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:pinput/pinput.dart';

class VerifyPhone extends StatefulWidget {
  const VerifyPhone({Key? key}) : super(key: key);

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var phoneNumber = TextEditingController();
    var extControl = TextEditingController();

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, height / 12, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
            ),
          ),
          SizedBox(height: height / 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Add Phone Number',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
          ),
          SizedBox(height: height / 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: TextFormField(
                    controller: extControl,
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
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor:
                      CupertinoColors.extraLightBackgroundGray,
                      labelStyle: TextStyle(color: Colors.grey),
                      labelText: 'Phone number',
                    ),
                  ),
                ),
              ],
            )
          ),
          ElevatedButton(
            onPressed: () {

              if (phoneNumber.length == 10){
                phoneNav_key.currentState?.pushNamed('/code', arguments: phoneNumber.value);
              }else{
                print('invalid phone');
              }
            },
            child: Text("Send SMS"),
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
          ),
        ],
      )),
    );
  }
}

// Code Sent Widget

class CodeSent extends StatefulWidget {
  final phone;
  const CodeSent({Key? key, required this.phone}) : super(key: key);

  @override
  State<CodeSent> createState() => _CodeSentState();
}

class _CodeSentState extends State<CodeSent> {

  var verificationId;
  var codeToken;
  var codeController = TextEditingController();


  Future phoneAuth() async{
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+20' + widget.phone.toString(),
        verificationCompleted: (phoneCredentials) async {
          print('COMPLETE!!!');
          FirebaseAuth.instance.currentUser!.reload();
        },
        verificationFailed: (verificationFailed) async {
          print(verificationFailed);
        },
        codeSent: (verificationId, codeToken){
          setState(() {
            this.verificationId = verificationId;
            this.codeToken = codeToken;
            print('id : ${verificationId} \n token : ${codeToken}');
          });
        },
        codeAutoRetrievalTimeout: (verificationId)async {
          print('time out');
        });
  }

  Future sendCode(userCode) async {

    var credentials = PhoneAuthProvider.credential(verificationId: this.verificationId, smsCode: userCode);

    await FirebaseAuth.instance.currentUser!.linkWithCredential(credentials)
        .then((value){
          print('thenWhat?');
    })
        .whenComplete((){
          print('complete1');
    })
        .onError((error, stackTrace){
          print(error);
    });
  }
  @override
  void initState() {
    phoneAuth();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var phoneNumber = TextEditingController();
    var smsSent = ValueNotifier<int>(0);

    final pinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = pinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(20),
    );

    final submittedPinTheme = pinTheme.copyWith(
      decoration: pinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, height / 12, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
            ),
          ),
          SizedBox(height: height / 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Verify SMS Code',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
          ),
          SizedBox(height: height / 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pinput(
                controller: codeController,
                length: 6,
                defaultPinTheme: pinTheme,
                submittedPinTheme: submittedPinTheme,
                focusedPinTheme: focusedPinTheme,
                onCompleted: (value){
                  sendCode(value);
                },
              )
            ],
          ),
          SizedBox(height: height/30),
          ElevatedButton(
            onPressed: () {
              phoneNav_key.currentState?.pop();
            },
            child: Text("Change Phone number"),
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
          ),
        ],
      )),
    );
  }
}
