import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../FETCH_wdgts.dart';
import '../JsonObj.dart';
import '../routesGenerator.dart';

class PetPassportPage extends StatefulWidget {
  final PetProfile pet;
  const PetPassportPage({required this.pet, super.key});

  @override
  State<PetPassportPage> createState() => _PetPassportPageState();
}

class _PetPassportPageState extends State<PetPassportPage> {

  late PdfControllerPinch pdfPinchController;
  late Future<String> storedUrl;
  double pdfProgress = 0;

  @override
  void initState() {
    storedUrl = getCachedPdfPathWithProgress(widget.pet.passport,
        onReceiveProgress: (received, total){
          if (total != -1) {
            // Calculate download percentage.
            setState(() {
              pdfProgress = ((received / total));
            });
          }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: init_appBar(homeNav_key),
      body: FutureBuilder<String>(
        future: storedUrl,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData){
            return SfPdfViewer.file(File(snapshot.data!));
          }else{
            return Center(child: LinearPercentIndicator(
              lineHeight: 5.0,
              percent: pdfProgress,
              barRadius: const Radius.circular(20),
              backgroundColor: Colors.grey,
              progressColor: Colors.white,
            ));
          }
        },

      ),
    );
  }
}
