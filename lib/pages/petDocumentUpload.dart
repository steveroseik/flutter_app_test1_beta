import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:path/path.dart';


class PetDocumentUpload extends StatefulWidget {
  final arguments;
  const PetDocumentUpload({Key? key, required this.arguments}) : super(key: key);

  @override
  State<PetDocumentUpload> createState() => _PetDocumentUploadState();
}

class _PetDocumentUploadState extends State<PetDocumentUpload> with TickerProviderStateMixin{
  File pdfDocument = File('');
  PDFDocument? document;
  String urlPath = '';
  bool docAvailable = false;
  bool tapped = false;
  late AnimationController _controller;
  late Animation<double> animation;

  createPassportPDF(BuildContext context) async {
    try{
      var androidLabelsConfigs = {
        ScannerLabelsConfig.PDF_GALLERY_EMPTY_MESSAGE: "add your pet's passport pages"
      };
      File? scannedDoc = await DocumentScannerFlutter.launchForPdf(context, source: ScannerFileSource.CAMERA, labelsConfig: androidLabelsConfigs);
      // print(scannedDoc);
      if (scannedDoc != null) {
        pdfDocument = scannedDoc;
        return pdfDocument;
      }else{
        return File("");
      }
      // });
    }catch (e){
      print(e);
      return File("");
    }

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
    return Scaffold(
      appBar: init_appBar(BA_key),
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
                if (pdfGenerated.path != ""){
                  pdfDocument = pdfGenerated;
                  document = await PDFDocument.fromFile(pdfDocument);
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
                    docAvailable ? PDFViewer(document: document!,
                      showNavigation: false,
                      showPicker: false,
                    ): SizedBox()),
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

                              if (urlPath == ""){
                                urlPath = await uploadAndStorePDF(pdfDocument);
                              }else{
                                if (widget.arguments.length == 1){
                                  final PetPod petPassed = widget.arguments[0];
                                  final resp = await updatePassport(urlPath, petPassed.pet.id);
                                  if (resp == 200){
                                    BA_key.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
                                  }else{
                                    showSnackbar(context, "Failed to connect with database, Check your internet connection.");
                                  }
                                }
                                int value = await addPet(widget.arguments[0],widget.arguments[1],widget.arguments[2],widget.arguments[3],
                                    widget.arguments[4],widget.arguments[5],widget.arguments[6], urlPath);
                                if (value == 200){
                                  BA_key.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
                                }else{
                                  showSnackbar(context, "Failed to connect with database, Check your internet connection.");
                                }

                              }
                              setState(() {
                                tapped = false;
                              });
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
          onTap:() async{
            setState(() {
              tapped = true;
            });
            int value = await addPet(widget.arguments[0],widget.arguments[1],widget.arguments[2],widget.arguments[3],
                widget.arguments[4],widget.arguments[5],widget.arguments[6], "");
            if (value == 200){
              BA_key.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
            }else{
              showSnackbar(context, "Failed to connect with database, Check your internet connection.");
            }
            setState(() {
              tapped = true;
            });
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
