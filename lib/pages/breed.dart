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




class _addBreedPageState extends State<addBreedPage> {

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

    generateRecommendations() async{

      var data = await generateBreedPossibilities(analysisID);
      data = data.toSet().toList();
      autoBreedList = List<suggestion>.generate(data.length, (index) {
        return suggestion(data[index], false);
      });

      setState(() {});
    }




    Future<int> analyzeImage(BuildContext context) async {
      try{
        final resp = await getUploadResponse(imageFile!);
        if (resp.approved == 1){
          analysisID = resp.id;
          generateRecommendations();
          return 0;
        }else{
          final _msg = resp.url != null ? resp.url : 'Unknown Error!';
          showSnackbar(context, _msg);
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


      // fToast.showToast(
      //   child: toast,
      //   gravity: ToastGravity.BOTTOM,
      //   toastDuration: Duration(seconds: 2),
      // );
      //
      // // Custom Toast Position
      // fToast.showToast(
      //     child: toast,
      //     toastDuration: Duration(seconds: 2),
      //     positionedToastBuilder: (context, child) {
      //       return Positioned(
      //         child: child,
      //         top: 16.0,
      //         left: 16.0,
      //       );
      //     });
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
  }

    // @override
    // void didChangeDependencies() {
    //   super.didChangeDependencies();
    // }

  @override
  Widget build(BuildContext context) {
    // fToast.init(context);
    //handle status color for photo analysis
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
                          backgroundColor: handleColor(),
                          child: ValueListenableBuilder<int>(
                                valueListenable: img_src,
                              builder: (BuildContext context, int value, Widget? child){
                                  if (value == 0){
                                    return const CircleAvatar (
                                        radius: 70,
                                        backgroundImage: IMAGE.AssetImage('assets/images/mini.png'));
                                  }else{
                                    return CircleAvatar (
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
                    backgroundColor: Colors.teal.shade100,
                    shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)
                        )
                ),
                onPressed: () async{
                  if (cam_Btn){
                    await pickImage(context, ImageSource.gallery);
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
                    p_stat.value = await analyzeImage(context);
                    // refresh UI and remove loading widget from screen
                    if (p_stat.value == -1){
                      showSnackbar(context, 'Could not find a dog in the photo!');
                    }
                    setState(() {});
                    stopLoading();
                    // reenable camera btn
                    cam_Btn = true;
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
              Expanded(
                child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    children: List.generate(autoBreedList.length, (index) {
                      return Center(
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
                    BA_key.currentState?.pushNamed('/pet_register', arguments: imageFile);
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
