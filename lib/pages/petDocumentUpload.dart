
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


import '../DataPass.dart';
import '../JsonObj.dart';
import '../cacheBox.dart';


class PetDocumentUpload extends StatefulWidget {
  final arguments;
  const PetDocumentUpload({Key? key, required this.arguments}) : super(key: key);

  @override
  State<PetDocumentUpload> createState() => _PetDocumentUploadState();
}

class _PetDocumentUploadState extends State<PetDocumentUpload> with TickerProviderStateMixin{
  String urlPath = '';
  bool docAvailable = false;
  String docPath = '';
  bool tapped = false;
  late AnimationController _controller;
  late Animation<double> animation;
  late CacheBox cacheBox;

  Future<String> createPassportPDF(BuildContext context) async {
    try{

      List<String> pictures;
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      final pdfPath = await generatePDFImages(pictures);
      // print(scannedDoc);
      if (pdfPath != null) {
        return pdfPath;
      }else{
        return '';
      }
      // });
    }catch (e){
      print(e);
      return '';
    }

  }

  Future<bool> addNewPet({String? passport}) async{

    return await cacheBox.addOwnerPet(widget.arguments[0],widget.arguments[1],widget.arguments[2],widget.arguments[3],
        widget.arguments[4],widget.arguments[5],widget.arguments[6], passport?? '');

   //TODO:: if you want to increment a pet count for user FIX THIS
    // if (value[0] != 200){
    //   return -100;
    // }else{
    //   value[0] = await cacheBox.incrementUserPets(value[1]);
    //   return value[0];
    // }

  }

  @override
  void initState() {
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    cacheBox = DataPassWidget.of(context);
    return Scaffold(
      appBar: init_appBar(homeNav_key),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: height*0.3,
                width: width*0.5,
                child: Image(image: AssetImage('assets/illustrations/petDocuments.png'))),
            Text('Add Your Pet Passport',
              style: TextStyle(
                fontSize: width*0.05,
                color: Colors.blueGrey.shade900,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width*0.09),
              child: Text("By uploading a copy of your pet passport, your pet's vaccines will be marked as verified to all other users.\n\n"'This step is mainly for ensuring safety upon our community.',
                style: TextStyle(
                  fontSize: width*0.03,
                  color: Colors.blueGrey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: height*0.01,),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)
                  )
              ),
              onPressed: () async{
                final pdfGenerated = await createPassportPDF(context);
                if (pdfGenerated != ""){
                  docPath = pdfGenerated;
                  docAvailable = true;
                  setState(() {});
                  _controller.forward();
                }

              },
              icon: Icon(Icons.camera_alt_outlined,
                  color: Colors.grey.shade900),
              label: Text('Open Camera',
                style: TextStyle(
                    color: Colors.grey.shade900
                ),),
            ),
            FadeTransition(opacity: _controller,
                child: Column(
                  children: [
                    Container(height: height*0.15, width: width*0.25, child:
                    docAvailable ? SfPdfViewer.asset(
                     'assets/pdf/file-example.pdf'): SizedBox()),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                )
                            ),
                            onPressed: tapped ? null : () async{
                              setState(() {
                                tapped = true;
                              });
                              bool succeeded = false;
                              if (urlPath == ""){
                                try{
                                  urlPath = await uploadAndStorePDF(docPath);
                                }catch (e){
                                  urlPath = "";
                                }

                              }
                              if (urlPath != ''){
                                if (widget.arguments.length == 1){
                                  final PetPod petPassed = widget.arguments[0];
                                  final resp = await updatePassport(urlPath, petPassed);
                                  if (mounted) {setState(() {
                                    tapped = false;
                                  });}

                                  if (resp == 200){
                                    homeNav_key.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
                                  }else if (mounted){
                                    showSnackbar(context, "Failed to add your pet document, Try again!");
                                  }
                                }else{

                                  bool value = await addNewPet(passport: urlPath);

                                  if (mounted) {setState(() {
                                    tapped = false;
                                  });}
                                  if (value){
                                    succeeded = true;
                                    homeNav_key.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
                                  }else if(mounted){
                                    showSnackbar(context, "Failed to add your pet, Try again!");
                                  }
                                }
                              }


                              if (!succeeded && mounted){
                                showSnackbar(context, "Failed to upload document");
                              }
                            },
                            child: Text('Finish',
                              style: TextStyle(
                                  color: Colors.grey.shade900
                              ),),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
        floatingActionButton: widget.arguments.length == 1 ? Container() : InkWell(
          onTap:tapped ? null : () async{

            setState(() {
              tapped = true;
            });

            bool value = await addNewPet();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  tapped = false;
                });
              }
            });
            if (value){
              homeNav_key.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
            }else if (mounted){
              showSnackbar(context, "Failed to connect with database, Check your internet connection.");

            }

          },
          child: Container(
              padding: EdgeInsets.all(20),
              child: Text('Skip',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey
              ),)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked
    );
  }
}
