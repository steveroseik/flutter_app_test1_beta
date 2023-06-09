import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatefulWidget {
  bool? notPage;
  LoadingPage({Key? key, this.notPage}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return (widget.notPage != null && widget.notPage == true) ? Image.asset(
      "assets/loadingDog2.gif",
      fit: BoxFit.fill,
    ) : Scaffold(
      body: Center(
          child: Image.asset(
            "assets/loadingDog2.gif",
            height: 125.0,
            width: 125.0,
          )//SpinKitFadingCube(
        //   size: 50,
        //   color: Colors.black
        // )
      ),
    );
  }
}
