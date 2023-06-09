import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app_test1/DataPass.dart';
import 'package:flutter_app_test1/cacheBox.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/hiveAdapters.dart';
import 'package:flutter_app_test1/pages/loadingPage.dart';
import 'package:flutter_app_test1/pages/signup_completion.dart';
import 'package:flutter_app_test1/verifyWidget.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'Login_main.dart';
import 'firebase_options.dart';
import 'package:flutter_app_test1/pages/emailVerify.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter<Duration>(DurationAdapter());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  CacheBox cacheBox = CacheBox();
  RequestsProvider requestsProvider = RequestsProvider();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:

        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        cacheBox.storeCache();
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataPassWidget(
      cacheBox: cacheBox,
      child: Sizer(
          builder:(context, orientation, deviceType){
            return OverlaySupport(
              child: ChangeNotifierProvider<RequestsProvider>(
                create: (_) => requestsProvider,
                child: Consumer<RequestsProvider>(
                  builder: (BuildContext context, value, Widget? widget){
                    return MaterialApp(
                        home: StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (context, snapshot){
                              if (snapshot.hasData){
                                if (FirebaseAuth.instance.currentUser!.emailVerified){
                                  return Signup(cacheBox: cacheBox);
                                }else{
                                  return verifyEmail();
                                }
                              }else{
                                if (snapshot.connectionState == ConnectionState.waiting){
                                  return LoadingPage();
                                }else{
                                  if(FirebaseAuth.instance.currentUser == null){
                                    FirebaseAuth.instance.signOut();
                                  }
                                  return LoginWidget();
                                }
                              }
                            }
                        )
                    );
                  },
                ),
              ),
            );
          }
      ),
    );
  }
}