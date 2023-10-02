import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/cacheBox.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_app_test1/verifyPhone.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_test1/configuration.dart';
import 'package:age_calculator/age_calculator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:sizer/sizer.dart';
import '../JsonObj.dart';
import '../mainApp.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Signup extends StatefulWidget {
  final CacheBox cacheBox;
  const Signup({Key? key, required this.cacheBox}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  //Controllers

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final TextEditingController ageFieldController = TextEditingController();
  final TextEditingController phoneFieldController = TextEditingController();
  final TextEditingController codeController = TextEditingController()..text = "+20";
  GlobalKey<FormState> formRegis = GlobalKey<FormState>();
  GlobalKey<CSCPickerState> cscKey = GlobalKey<CSCPickerState>();
  GlobalKey<DropdownSearchState> formKey =  GlobalKey<DropdownSearchState>();
  final _introKey = GlobalKey<IntroductionScreenState>();
  final curUser = FirebaseAuth.instance.currentUser;
  String? city;
  String country = 'Egypt';
  String? state;
  DateTime? userBirthDate;
  bool isComplete = false;
  bool isLoading = true;
  bool? isMale;
  late usrState emailController;
  late List<String> cities;
  UserPod? userPod;
  List<Gender> genders = <Gender>[Gender("Male", Icons.male, false),
                                  Gender("Female", Icons.female, false)];
  DateTime tempDate = DateTime.now();



  void initState() {
    initCities();
    userVerified();
    super.initState();
  }

  initCities() async{
    String fetchedCities = await rootBundle.loadString('assets/cities.txt');
    cities = fetchedCities.split('\n');
    cities.toSet().toList();
  }

  void userVerified() async{

    await FirebaseAuth.instance.currentUser?.reload();
    final uemail = FirebaseAuth.instance.currentUser!.email.toString();
    final uid = FirebaseAuth.instance.currentUser!.uid.toString();

    List<dynamic> resp = await userInDb(uemail, uid);
    userPod = resp[1];
    emailController = resp[0];
    final List<PetProfile> pets = resp[2];

    switch(emailController){
      case usrState.connectionError:
        showSnackbar(context, 'connection time out');
        widget.cacheBox.signOut();
        break;
      case usrState.userAlreadyExists:
        showSnackbar(context, 'Duplicate email.');
        FirebaseAuth.instance.currentUser?.delete();
        widget.cacheBox.signOut();
        break;
      case usrState.newUser:
        isComplete = false;
        break;
      case usrState.completeUser:
        widget.cacheBox.storeUser(userPod!, pets: pets);
        isComplete = true;
        break;
    }

    setState(() {
      isLoading = false;
    });

    try{

    }catch (e) {
      print('userVerifiedError: $e');
    }

  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    firstName.dispose();
    lastName.dispose();
    email.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    // Fetching user email, useless rn, should be updated when phone registration is implemented
    var userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) email.text = userEmail;


    void showDatePicker() {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext builder) {
            return Container(
              margin: EdgeInsets.all(5.sp),
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.sp),
                  color: Colors.white
              ),
              height: MediaQuery
                  .of(context)
                  .copyWith()
                  .size
                  .height * 0.35,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: (){
                          Navigator.of(context).pop(false);
                          if (userBirthDate != null){
                            ageFieldController.text = '${userBirthDate!.year}-${userBirthDate!.month}-${userBirthDate!.day}';
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))
                        ),
                        child: Text('Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),),
                      ),
                      ElevatedButton(
                        onPressed: (){
                          Navigator.of(context).pop(true);
                          userBirthDate = tempDate;
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))
                        ),
                        child: Text('Done',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 10.sp,
                          ),),
                      ),
                    ],
                  ),
                  Flexible(
                    flex: 2,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (value) {
                        setState(() {
                          if (value != userBirthDate) {
                            tempDate = value;
                            ageFieldController.text = '${tempDate.year}-${tempDate.month}-${tempDate.day}';
                          }
                        });
                      },
                      initialDateTime: userBirthDate ?? DateTime.now().subtract(const Duration(days: 366*12)),
                      minimumYear: DateTime.now().year - 100,
                      maximumYear: DateTime.now().year - 12,
                      maximumDate: DateTime.now(),
                    ),
                  ),
                ],
              ),
            );
          }).then((value) {
        if (value == null){
          if (userBirthDate != null){
            ageFieldController.text = '${userBirthDate!.year}-${userBirthDate!.month}-${userBirthDate!.day}';
          }
        }
      });
    }

    return isLoading ? LoadingPage() : isComplete ? mainApp(pod: userPod) : GestureDetector(
      onTap:(){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(0, 7.h, 0, 5.h),
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 3.h),
                        Text('FETCH',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w900,
                            )),
                        SizedBox(height: 0.5.h),
                        Text('for dog community',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 10.sp,
                            ))
                      ],
                    )
                ),
                SizedBox(
                  height: 75.h,
                  child: IntroductionScreen(
                    key: _introKey,
                    pages: [
                      PageViewModel(
                        useScrollView: false,
                        titleWidget: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          alignment: Alignment.bottomCenter,
                          child: Text('Complete Your Information',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                              )),),
                        bodyWidget:  Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                  child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      controller: firstName,
                                      decoration:InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
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
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (value){
                                        if (value == null || RegExp(r'[^a-zA-Z]').hasMatch(value) || value.length < 3){
                                          return 'Enter a valid name';
                                        }else{
                                          return null;
                                        }
                                      }
                                  )
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                  child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      controller: lastName,
                                      decoration:InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
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
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (value){
                                        if (value == null || RegExp(r'[^a-zA-Z]').hasMatch(value) || value.length < 3){
                                          return 'Enter a valid name';
                                        }else{
                                          return null;
                                        }
                                      }
                                  )
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                child: InkWell(
                                  onTap: (){
                                    showDatePicker();
                                  },
                                  child: TextFormField(
                                    controller: ageFieldController,
                                    readOnly: true,
                                    enabled: false,
                                    decoration:InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
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
                                    validator: (value){
                                      if (value != null && value.length > 5){
                                        return null;
                                      }else{
                                        return 'Please choose your birthdate';
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                child: CSCPicker(
                                  key: cscKey,
                                  flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                                  onCountryChanged: (country){
                                    this.country = country;
                                  },
                                  onStateChanged: (state){
                                    this.state = state;
                                  },
                                  onCityChanged: (city){
                                    this.city = city;
                                  },
                                    layout: Layout.horizontal,
                                    defaultCountry: CscCountry.Egypt,
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13.sp),
                                    color: CupertinoColors.extraLightBackgroundGray,
                                    border: Border.all(width: 0.5.sp, color: Colors.grey.shade400)
                                  ),
                                  disabledDropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13.sp),
                                      color: Colors.grey,
                                      border: Border.all(width: 0.5.sp, color: Colors.grey.shade400)
                                  )
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                child: Container(
                                  height: 6.h,
                                  alignment: Alignment.topLeft,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: genders.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              for (var gender in genders) {
                                                gender.isSelected = false;
                                              }
                                              genders[index].isSelected = true;
                                              if (genders[index].name == "Male"){
                                                isMale = true;
                                              }else{
                                                isMale = false;
                                              }
                                            });
                                          },
                                          child: CustomRadioRound(genders[index]),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PageViewModel(
                        titleWidget: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          alignment: Alignment.bottomLeft,
                          child: Text('Add Your Phone Number',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                              )),),
                        bodyWidget: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    padding:EdgeInsets.fromLTRB(0, 0, 1.5.w, 0),
                                    child: GestureDetector(
                                      onTap: (){
                                        showCountryPicker(
                                          context: context,
                                          showPhoneCode: true, // optional. Shows phone code before the country name.
                                          onSelect: (Country country) {
                                            codeController.text = "+${country.phoneCode}";
                                          },
                                          countryListTheme: CountryListThemeData(
                                            bottomSheetHeight: 75.h,
                                            inputDecoration: InputDecoration(
                                              hintText: 'Search Country',
                                              prefixIcon: const Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15.sp),
                                              ),
                                            ),

                                          )
                                        );
                                      },
                                      child: Padding(
                                        padding:EdgeInsets.symmetric(vertical: 1.h),
                                        child: TextFormField(
                                          controller: codeController,
                                            decoration:InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                              disabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                  borderSide: BorderSide(color: CupertinoColors.extraLightBackgroundGray)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(20)),
                                              filled: true,
                                              fillColor: CupertinoColors.extraLightBackgroundGray,
                                              labelStyle: TextStyle(color: Colors.grey),
                                              hintText: '+20',
                                            ),
                                          enabled: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 1.h),
                                    child: TextFormField(
                                      onChanged: (value){
                                        if (value.isNotEmpty && value[0] == '0'){
                                          phoneFieldController.text = value.replaceFirst('0', '');
                                        }
                                      },
                                      keyboardType: TextInputType.phone,
                                      controller: phoneFieldController,
                                        decoration:InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
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
                                          hintText: "1223456789",
                                        ),
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        validator: (value){
                                          if (value == null || RegExp(r'[^0-9]').hasMatch(value) || value.length > 13){
                                            return 'Enter a valid phone number';
                                          }else{
                                            return null;
                                          }
                                        }
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      )
                    ],
                    onDone: (){},
                    overrideDone: SizedBox(
                      height: 3.h,
                      child: GestureDetector(
                        onTap: ()async{
                          bool failedToSignup = true;
                          try{

                            String phoneNumber = "${codeController.text}${phoneFieldController.text}";
                            if (phoneFieldController.text.length <= 13){
                              final ret = await checkPhoneAvailability(phoneNumber);
                              if ( ret == 200){
                                var resp = await addUser(curUser!.uid, email.text, phoneNumber, firstName.text,
                                    lastName.text, country, state!, city!, userBirthDate!, isMale!);
                                if (resp[0] == 200){
                                  failedToSignup = false;
                                  widget.cacheBox.storeUser(resp[1]);
                                }else{
                                  showSnackbar(context, 'Could not communicate with server, try again.');
                                }
                              }else if (ret == 0 ){
                                showSnackbar(context, '.. Could not communicate with server, try again.');
                              }else{
                                showSnackbar(context, 'Phone number already exists.');
                              }
                            }else{
                              showSnackbar(context, 'Add your phone number first!');
                            }
                          }catch(error){
                            showSnackbar(context, 'Problem finishing your Sign up. Try again!');
                          }finally{
                            if (!failedToSignup){
                              userVerified();
                            }
                          }

                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.fromLTRB(0, 0, 2.w, 0),
                          child: Text("Done",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blueGrey
                            ),),
                        ),
                      ),
                    ),
                    overrideNext: SizedBox(
                      height: 3.h,
                      child: InkWell(
                        onTap: ()async{
                          bool grantedRegistration = true;

                          if (firstName.text == "" || lastName.text == "" || country == null || userBirthDate == null || isMale == null){
                            grantedRegistration = false;
                          }else{
                            final statesList = await cscKey.currentState?.getStates();
                            if (state == null && statesList!.isNotEmpty){
                              grantedRegistration = false;
                            }else if(state != null){
                              final cityList = await cscKey.currentState?.getCities();
                              if (city == null && cityList!.isNotEmpty){
                                grantedRegistration = false;
                              }
                            }
                          }
                          if (grantedRegistration){
                            _introKey.currentState?.next();
                          }else{
                            showSnackbar(context, "Please Complete all fields");
                          }

                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Next",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey
                              ),),
                            Icon(Icons.navigate_next_rounded, color: Colors.blueGrey,),
                          ],
                        ),
                      ),
                    ),
                    showSkipButton: false,
                    showNextButton: true,
                    freeze: true,
                    isProgressTap: false,
                    showBackButton: true,
                    back: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey),
                    next: const Icon(Icons.arrow_forward, color: Colors.blueGrey),
                    done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                    dotsDecorator: DotsDecorator(
                        size: const Size.square(10.0),
                        activeSize: const Size(20.0, 10.0),
                        activeColor: Colors.blueGrey,
                        color: Colors.black26,
                        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                        activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)
                        )
                    ),
                  ),
                )

              ],
            ),
        ),
      ),
    );
  }
}
