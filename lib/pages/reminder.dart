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

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  File file = File('');
  File file2 = File('');
  String _imagePath = '';
  bool showNext = false;
  bool validTitle = false;
  bool validCode = false;
  bool isPressed = false;
  final Size windowSize = MediaQueryData.fromWindow(window).size;
  late OverlayEntry loading = initLoading(context, windowSize);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                overlay?.insert(loading);
                              }
                            });
                            await parseID();
                            setState(() {
                              isPressed = false;
                              if (loading.mounted) {
                                loading.remove();
                              }
                            });
                            if (validTitle && validCode){
                              setState(() {
                                showNext = true;
                              });
                            }
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
                      Text("Now you only need to take a clear photo of you.", textAlign: TextAlign.center),
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
                                overlay?.insert(loading);
                              }
                            });
                            var image = await ImagePicker().pickImage(source: ImageSource.camera);
                            if (image != null){
                              file2 = File(image.path);
                              var resp = await compareFacial(file, file2);
                              if (resp > 90){
                                showNext = true;
                              }else{
                                // not same photo
                              }
                            }else{
                              showSnackbar(context, 'cancelled.');
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
              body: "You're now a gold member along with all of your pets.",
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
          onDone: () {

          },
          onSkip: (){

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
    );
  }

  parseID() async {

    try{
      file = File(await scanID());
    }on PlatformException catch (e){

    }
    if (file.path != ''){
      int fileSize = getFileSize(file);
      do{
        print(fileSize);
        if (fileSize > 2200) {
          file = await FlutterNativeImage.compressImage(file.path,
              quality: 100, percentage: 70);
        }else if (fileSize > 1700){
          file = await FlutterNativeImage.compressImage(file.path,
              quality: 100, percentage: 80);
        }else if (fileSize > 1200){
          file = await FlutterNativeImage.compressImage(file.path,
              quality: 100, percentage: 90);
        }else{
          file = await FlutterNativeImage.compressImage(file.path,
              quality: 100, percentage: 95);
        }
        fileSize = getFileSize(file);

      }while( fileSize > 1024);

      fileSize = getFileSize(file);
      print(fileSize);
      var bytes = File(file.path).readAsBytesSync();
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


