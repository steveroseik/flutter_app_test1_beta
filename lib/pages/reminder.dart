import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../APILibraries.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  File file = File('path');
  File file2 = File('');
  String _imagePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: init_appBar(rootNav_key), // CHANGE KEY!!!!
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: () async{

            }, child: Text('Get file size')),
            ElevatedButton(onPressed: () async{
             parseID();
            }, child: Text('Analyse')),
            ElevatedButton(onPressed: () async{

              // print(file.path);
              // print(getFileSize(file));

              // compareFacial(file, file2);
            }, child: Text('Send request')),
          ]
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
        double perc = ( (1024) / fileSize ) * 100;
        print(perc.toInt());
        if (fileSize > 2000){
          file = await FlutterNativeImage.compressImage(file.path,
              quality: 100, percentage: 80);
        }else{
          file = await FlutterNativeImage.compressImage(file.path,
              quality: 100, percentage: 90);
        }
        fileSize = getFileSize(file);
        print(fileSize);
      }while( fileSize > 1024);

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
      bool validTitle = false;
      bool validCode = false;
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


