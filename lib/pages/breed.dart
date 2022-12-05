import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/src/widgets/image.dart' as IMAGE;
import 'package:loading_indicator/loading_indicator.dart';


int _selectedIndex = 0;
var p_stat = ValueNotifier<int>(-2);
 final img_src =  ValueNotifier<int>(0);
bool loading = true;

class suggestion{
  Breed pet;
  bool isSelected;

  suggestion(this.pet, this.isSelected);
}

class addBreedPage extends StatefulWidget {
  const addBreedPage({Key? key}) : super(key: key);


  @override
  State<addBreedPage> createState() => _addBreedPageState();
}




class _addBreedPageState extends State<addBreedPage> with TickerProviderStateMixin {

    late Future<List<Breed>> finalBreeds;
    File? imageFile;
    late Future<PhotoResponse> pRes;
    // late FToast fToast;
    // var p_stat = -2;
    late Color statColor;
    late OverlayEntry loading;
    final Size windowSize = MediaQueryData.fromWindow(window).size;
    var cam_Btn = true;
    String analysisID = '';
    List<suggestion> autoBreedList = <suggestion>[];
    String suggestionSelected = '';
    late AnimationController _controller;
    late Animation<double> _animation;


    generateRecommendations() async{

      var data = await generateBreedPossibilities(analysisID);
      data = data.toSet().toList();
      autoBreedList = List<suggestion>.generate(data.length, (index) {
        return suggestion(data[index], false);
      });
      stopLoading();
      // reenable camera btn
      p_stat.value = 0;
      cam_Btn = true;
      setState(() {});
      _controller.forward();
    }

    Future<int> analyzeImage(BuildContext context) async {
      try{
        final resp = await getUploadResponse(imageFile!);
        if (resp.approved == 1){
          analysisID = resp.id;
          generateRecommendations();
          return 0;
        }else{
          showSnackbar(context, "Couldn't find a dog in this photo!");
          p_stat.value = -1;
          cam_Btn = true;
          stopLoading();
          setState(() {});
          _controller.reverse();
          return -1;
        }
      } on PlatformException catch (e){
        showSnackbar(context, 'Error fetching response');
        return -2;
      }
    }


    _showToast(String _t) {
      Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.greenAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check),
            SizedBox(
              width: 12.0,
            ),
            Text(_t),
          ],
        ),
      );
    }


    void isLoading(){
      Offset offs = Offset((windowSize.width / 2) - 25, windowSize.height - 150);
      loading = OverlayEntry(
          builder: (BuildContext context) => Positioned(
            left: offs.dx,
            top: offs.dy,
            child: SizedBox(
              height: 50,
              width: 50,
              child: LoadingIndicator(
                  indicatorType: Indicator.ballPulseSync,
                  colors:  [Colors.black, Colors.teal, Colors.blueGrey]
              ),
            ),
          )
      );
    }


    void stopLoading(){
      loading.remove();
    }

    @override
  void initState() {
    super.initState();
    finalBreeds = getBreedList(0);
    // fToast = FToast();
    p_stat.value = -2;
    statColor = Colors.grey;
    img_src.value = 0;
    cam_Btn = true;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

    // @override
    // void didChangeDependencies() {
    //   super.didChangeDependencies();
    // }

  @override
  Widget build(BuildContext context) {
    // fToast.init(context);
    //handle status color for photo analysis
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Color handleColor() {
      statColor =
      p_stat.value == 0 ? Colors.teal : p_stat.value == -1 ? Colors.redAccent : Colors.grey;
      return statColor;
    }

    return Scaffold(
        appBar: init_appBar(BA_key),
        body:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: Text(
                      'Verify Your Pet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ),Container(
                padding: const EdgeInsets.all(10.0),
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Take a clear photo of your pet',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 150,
                height: 150,
                child: CircleAvatar(
                          radius: 100,
                          backgroundColor: CupertinoColors.extraLightBackgroundGray,
                          child: ValueListenableBuilder<int>(
                                valueListenable: img_src,
                              builder: (BuildContext context, int value, Widget? child){
                                  if (value == 0){
                                    return CircleAvatar (
                                      backgroundColor: Colors.white,
                                        radius: 70,
                                        backgroundImage: IMAGE.AssetImage('assets/images/mini.png'));
                                  }else{
                                    return CircleAvatar (
                                        backgroundColor: CupertinoColors.extraLightBackgroundGray,
                                        radius: 70,
                                        backgroundImage: IMAGE.FileImage(imageFile!));
                                  }
                              }
                          )
                      )
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)
                        )
                ),
                onPressed: () async{
                  if (cam_Btn){

                    imageFile = await pickImage(context, ImageSource.gallery);
                    // print(cam_Btn);
                    // refresh UI elements
                    setState(() {});
                    // set state of pet photo as -2 (neutral)
                    p_stat.value = -2;
                    // put loading widget into screen
                    isLoading();
                    OverlayState? overlay = Overlay.of(context);
                    overlay?.insert(loading);
                    //disable camera button
                    cam_Btn = false;
                    // wait until image is analyzed
                    if (imageFile != null){
                      img_src.value = 1;
                      await analyzeImage(context);
                    }else{
                      p_stat.value = -2;
                      cam_Btn = true;
                      img_src.value = 0;
                      stopLoading();
                      setState(() {});
                      _controller.reverse();
                      suggestionSelected = '';
                    }
                  }

                },
                  icon: Icon(Icons.camera_alt_outlined,
                  color: Colors.grey.shade900),
                  label: Text('Open Camera',
                  style: TextStyle(
                    color: Colors.grey.shade900
                  ),),
              ),
              SizedBox(height: 10),
              AnimatedSlide(
                duration: animationDuration_1,
                offset: p_stat.value == 0 ? Offset(0, 0) : Offset.zero ,
                child: AnimatedOpacity(
                  duration: animationDuration_1,
                  opacity: p_stat.value == -1 ? 1 : 0,

                  child: const Text("Try to take a more clear photo",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.redAccent
                    )),
                ),
              ),
              SizedBox(height: 10,),
              FadeTransition(
                opacity: _controller,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Recommended Breeds',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey.shade800
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                child: FadeTransition(
                  opacity: _controller,
                  child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5/1,
                      children: List.generate(autoBreedList.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: InkWell(
                            onTap: (){
                              for (suggestion s in autoBreedList){
                                s.isSelected = false;
                              }
                              autoBreedList[index].isSelected = true;
                              setState(() {
                                suggestionSelected = autoBreedList[index].pet.name;
                              });

                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: autoBreedList[index].isSelected ? Colors.blueGrey : CupertinoColors.extraLightBackgroundGray
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(autoBreedList[index].pet.photoUrl),
                                  ),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${autoBreedList[index].pet.name}',
                                      style: TextStyle(fontWeight: FontWeight.w700, color: autoBreedList[index].isSelected ? Colors.white : Colors.black),
                                    maxLines: 2,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })),
                ),
              )
            ],
          ),
        ),
      floatingActionButton: ValueListenableBuilder<int>(
          valueListenable: p_stat,
          builder: (BuildContext context, int value, Widget? child){
            return Visibility(
                visible: value == 0 ? true : false,
                child: FloatingActionButton.extended(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueGrey,
                  label: Text('Next'),
                  icon: Icon(Icons.navigate_next_outlined),
                  onPressed: () async{
                    BA_key.currentState?.pushNamed('/pet_register', arguments: [imageFile,suggestionSelected]);
                    // await generateRecommendations();
                    setState((){});
                  },
                ));
          }),
      );
  }

  void _onTap(int index)
  {
    _selectedIndex = index;
    setState(() {

    });


  }
}
