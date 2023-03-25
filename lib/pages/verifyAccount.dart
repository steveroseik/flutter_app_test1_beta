import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:introduction_screen/introduction_screen.dart';
import '../APILibraries.dart';
import '../JsonObj.dart';

class VerifyAccountPage extends StatefulWidget {
  // userPod is not needed anymore
  final UserPod userPod;
  const VerifyAccountPage({Key? key, required this.userPod}) : super(key: key);

  @override
  State<VerifyAccountPage> createState() => _VerifyAccountPageState();
}

class _VerifyAccountPageState extends State<VerifyAccountPage> {
  File file = File('');
  File file2 = File('');
  String _imagePath = '';
  bool showNext = false;
  bool validTitle = false;
  bool validCode = false;
  bool isPressed = false;
  late OverlayEntry loading = initLoading(context);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        appBar: init_appBar(rootNav_key), // CHANGE KEY!!!!
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: IntroductionScreen(
            pages: [
              PageViewModel(
                title: "Take a clear photo of your national ID",
                bodyWidget: Container(
                    child: Column(
                      children: [
                        Text("Don't worry, we don't store the data, it's only used for validation purposes.", textAlign: TextAlign.center,),
                        SizedBox(height: 30,),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade900,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                            onPressed: isPressed ? null : () async{
                              setState(() {
                                isPressed = true;
                                if (!loading.mounted) {
                                  OverlayState? overlay =
                                  Overlay.of(context);
                                  overlay.insert(loading);
                                }
                              });
                              await parseID();
                              if (validTitle && validCode){
                                setState(() {
                                  showNext = true;
                                });
                              }else{
                                showSnackbar(context, "Please Take a more clear photo, make sure ALL ID text are clear.");
                              }
                              isPressed = false;
                              if (loading.mounted) {
                                loading.remove();
                              }
                              setState(() {});
                            },
                            child: Text('Open Camera'))
                      ],
                    )
                ),
                image: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: Image(image: AssetImage('assets/illustrations/PhotoID.png'))),
                ),
                decoration: const PageDecoration(
                  titleTextStyle: TextStyle(color: Colors.orange),
                  bodyTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
                ),
              ),
              PageViewModel(
                title: "Take a Selfie",
                bodyWidget: Container(
                    child: Column(
                      children: [
                        Text("Now you need to take a selfie to compare it with your photo ID", textAlign: TextAlign.center),
                        SizedBox(height: 30,),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade900,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                            onPressed: isPressed ? null : () async{

                              setState(() {
                                isPressed = true;
                                if (!loading.mounted) {
                                  OverlayState? overlay =
                                  Overlay.of(context);
                                  overlay.insert(loading);
                                }
                              });
                              var image = await ImagePicker().pickImage(source: ImageSource.camera);
                              if (image != null){
                                file2 = File(image.path);
                                var resp = await compareFacial(file, file2);
                                if (resp > 90){
                                  showNext = true;
                                }else{
                                  showSnackbar(context, "Take a more clear photo of yourself.");
                                }
                              }else{
                                // showSnackbar(context, 'cancelled.');
                              }
                              if (loading.mounted) {
                                loading.remove();
                              }
                              setState(() {
                                isPressed = false;
                              });
                            }, child: Text('Open Camera')),
                      ],
                    )
                ),
                image: const Center(child: Image(image:AssetImage('assets/illustrations/photo_selfie.png'))),
                decoration: const PageDecoration(
                  titleTextStyle: TextStyle(color: Colors.orange),
                  bodyTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
                ),
              ),
              PageViewModel(
                title: "You're All Done!",
                body: "You're now a verified member along with all of your pets.",
                image: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(child: Image(image:AssetImage('assets/illustrations/user_verified.png'))),
                ),
                decoration: const PageDecoration(
                  titleTextStyle: TextStyle(color: Colors.orange),
                  bodyTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
                ),
              ),
            ],
            onDone: () async{
              try{
                await verifyUser();
                settingsNav_key.currentState?.pop(true);
              }catch (e){
                settingsNav_key.currentState?.pop(false);
              }

            },
            onSkip: (){
              settingsNav_key.currentState?.pop(false);
            },
            showSkipButton: true,
            showNextButton: showNext? true : false,
            freeze: true,
            isProgressTap: false,
            showBackButton: false,
            next: const Icon(Icons.arrow_forward, color: Colors.blueGrey),
            done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
            skip: const Text("cancel", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
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
            onChange: (value){
              setState(() {
                showNext = false;
              });
            },
          ),
        ),
      ),
    );
  }

  parseID() async {

    try{
      file = File(await scanID());
      print(file.path);
    }on PlatformException catch (e){

    }
    if (file.path != ''){
      int fileSize = getFileSize(file);
      File tempFile = File(file.path);
      do{
        if (fileSize > 2200) {
          tempFile = await FlutterNativeImage.compressImage(tempFile.path,
              quality: 100, percentage: 70);
        }else if (fileSize > 1700){
          tempFile = await FlutterNativeImage.compressImage(tempFile.path,
              quality: 100, percentage: 80);
        }else if (fileSize > 1200){
          tempFile = await FlutterNativeImage.compressImage(tempFile.path,
              quality: 100, percentage: 90);
        }else{
          tempFile = await FlutterNativeImage.compressImage(tempFile.path,
              quality: 100, percentage: 95);
        }
        fileSize = getFileSize(tempFile);

      }while( fileSize > 1024);
      print(file.path);
      print(tempFile.path);
      var bytes = File(tempFile.path).readAsBytesSync();
      String img64 = base64Encode(bytes);
      var url = Uri.parse('https://api.ocr.space/parse/image');
      var payload = {
        "base64Image": "data:image/jpg;base64,$img64",
        "language": "ara",
        "isTable": "true",
        "detectOrientation": "true"

      };
      var header = {"apikey": "f9c183d29088957"};
      var post = await http.post(url=url,body: payload,headers: header);
      var result = jsonDecode(post.body);
      print(result);
      var res = result['ParsedResults'][0]['ParsedText'];
      print(res);
      LineSplitter ls = new LineSplitter();
      List<String> lines = ls.convert(res);
      for (dynamic line in lines){
        if (line.contains('بطاقة تحقيق')){
          print('FOUND 1');
          validTitle = true;
        }
        if (RegExp(r"^[a-zA-Z0-9]{9}").hasMatch(line)){
          print('FOUND 2');
          validCode = true;
        }
      }
    }
  }
}


