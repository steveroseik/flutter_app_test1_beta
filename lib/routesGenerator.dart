import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:flutter_app_test1/pages/BreedsArticles.dart';
import 'package:flutter_app_test1/pages/EditProfile.dart';
import 'package:flutter_app_test1/pages/FoodArticles.dart';
import 'package:flutter_app_test1/pages/HealthArticles.dart';
import 'package:flutter_app_test1/pages/TrainingArticles.dart';
import 'dart:io';
import 'package:flutter_app_test1/pages/breed.dart';
import 'package:flutter_app_test1/pages/breed_sp.dart';
import 'package:flutter_app_test1/pages/breed_registration.dart';
import 'package:flutter_app_test1/pages/create_meet.dart';
import 'package:flutter_app_test1/pages/editPass.dart';
import 'package:flutter_app_test1/pages/editPetPage.dart';
import 'package:flutter_app_test1/pages/editSettings.dart';
import 'package:flutter_app_test1/pages/emailVerify.dart';
import 'package:flutter_app_test1/pages/explore.dart';
import 'package:flutter_app_test1/pages/forgotPassword.dart';
import 'package:flutter_app_test1/pages/homeBreedPage.dart';
import 'package:flutter_app_test1/pages/notificationsPage.dart';
import 'package:flutter_app_test1/pages/petDocumentUpload.dart';
import 'package:flutter_app_test1/pages/petMatchPage.dart';
import 'package:flutter_app_test1/pages/petProfilePage.dart';
import 'package:flutter_app_test1/pages/settings.dart';
import 'package:flutter_app_test1/pages/user_profile.dart';
import 'package:flutter_app_test1/pages/home.dart';
import 'package:flutter_app_test1/pages/login.dart';
import 'package:flutter_app_test1/pages/signup_completion.dart';
import 'package:flutter_app_test1/mainApp.dart';
import 'package:flutter_app_test1/pages/signupWithEmail.dart';
import 'package:flutter_app_test1/verifyPhone.dart';
import 'package:flutter_app_test1/pages/meets_selectpets.dart';


import 'FETCH_wdgts.dart';

// This is for routes configurations across the whole application

// Global keys identify each Navigator key for individual tabs in application
GlobalKey<NavigatorState> BA_key = GlobalKey();
GlobalKey<NavigatorState> rootNav_key = GlobalKey();
GlobalKey<NavigatorState> AppNav_key = GlobalKey();
GlobalKey<NavigatorState> UserNav_key = GlobalKey();
GlobalKey<NavigatorState> phoneNav_key = GlobalKey();
GlobalKey<NavigatorState> settingsNav_key = GlobalKey();
GlobalKey<NavigatorState> explore_key = GlobalKey();

class RouteGenerator {
  // Main Routes Generator
  static Route<dynamic> generateRoute_main(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
        );
        return _errorRoute();
      case '/signup_complete':
        return MaterialPageRoute(
          builder: (_) => Signup(),
        );
      case '/signupEmail':
        return MaterialPageRoute(builder: (_) => SignUpEmail());
      case '/verifyEmail':
        return MaterialPageRoute(builder: (_) => verifyEmail());
      case '/mainApp':
        return MaterialPageRoute(
          builder: (_) => mainApp(),
        );
      case '/forgotPass':
        if (args is String){
          return MaterialPageRoute(builder: (_) => ForgotPass(emailPushed: args));
        }
        print("args not Text");
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  // This is the Breed/Adopt routesGenerator
  static Route<dynamic> generateRoute_BA(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    //for each case called, checks are applied to navigation to the correct next page
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeBreedPage());
      case '/add_pet':
        return MaterialPageRoute(builder: (_) => addBreedPage());
      case '/petMatch':
        if (args is List){
          return MaterialPageRoute(builder: (_) => PetMatchPage(senderPet: args[0],pets: args[1]));
        }else{
          return _errorRoute();
        }

      case '/search_manual':
        if (args is List<PetPod>){
          return MaterialPageRoute(builder: (_) => breedSearchPage(ownerPets: args,));
        }
        return _errorRoute();
      case '/pet_register':
        //this case is for second step of pet verification after taking a picture of the pet
        // if happens to navigate to the page with an unidentified photo will navigate to error route
        if (args is List) {
          return MaterialPageRoute(
            builder: (_) => petRegPage(recFile: args[0], breedSelected: args[1],), // Second Page
          );
        }
        return _errorRoute();
      case '/editPet':
        if (args is PetProfile){
          return MaterialPageRoute(builder: (_) => EditPetPage(pod: args));
        }
        return _errorRoute();
      case '/pet_adopt':
        return MaterialPageRoute(
          builder: (_) => breedSearchPage(ownerPets: [],), // Second Page
        );
      case '/petDocument':
        if (args is List){
          return MaterialPageRoute(
              builder: (_) => PetDocumentUpload(arguments: args,));
        }
        return _errorRoute();
      case '/petProfile':
        if (args is List){
          return MaterialPageRoute(
              builder: (_) => PetProfilePage(pod: args[0], ownerPets: args[1], senderState: args[2]));
        }
        return _errorRoute();
      case '/notif':
        if (args is List){
          return CupertinoPageRoute(builder: (_) => NotificationsPage(requests: args[0], ownerPets: args[1]));
        }
        return _errorRoute();
      default:
        // if an unmatched route is called, return error route
        return _errorRoute();
    }
  }

  // This is the User routesGenerator
  static Route<dynamic> generateRoute_user(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/user_profile':
        if (args is! File) {
          return MaterialPageRoute(
            builder: (_) => UserProfile(), // Second Page
          );
        }
        return _errorRoute();
      case '/food_articles':
        return MaterialPageRoute(builder: (_) => FoodArticles());
      case '/health_articles':
        return MaterialPageRoute(builder: (_) => HealthArticles());
      case '/breeds_articles':
        return MaterialPageRoute(builder: (_) => BreedsArticles());
      case '/training_articles':
        return MaterialPageRoute(builder: (_) => TrainingArticles());
      default:
      // if an unmatched route is called, return error route
        return _errorRoute();
    }
  }
 static Route<dynamic> generateRoute_explore(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MapsPage());
      case '/create_meet':
        return MaterialPageRoute(builder: (_) => CreateMeet());
      case '/select_pets':
        if (args is List){
          return MaterialPageRoute(builder: (_) => SelectPets_Meets(criteria: args[0],id:args[1]));
        }
        return _errorRoute();


      default:
      // if an unmatched route is called, return error route
        return _errorRoute();
    }
  }

  static Route<dynamic> generateRoute_phone(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => VerifyPhone());
      case '/code':
        return MaterialPageRoute(builder: (_) => CodeSent(phone: args));
      default:
        return _errorRoute();
    }
  }

  // This is the User routesGenerator
  static Route<dynamic> generateRoute_settings(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SettingsPage());
      case '/editProfile':
        if (args is Map)
          return MaterialPageRoute(builder: (_) => EditProfile(userData: args));
        return _errorRoute();
      case '/editPass':
        if (args is Map)
          return MaterialPageRoute(builder: (_) => editPass(userData: args));
        return _errorRoute();
      case '/setting':
        return MaterialPageRoute(builder: (_) => editSettings());
      default:
      // if an unmatched route is called, return error route
        return _errorRoute();
    }
  }

  // this is an error page that appears once any error happens in navigation above
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ), // AppBar
        body: Center(
          child: Text('ERROR'),
        ), // Center
      ); // Scaffold
    }); // Material PageRoute
  }
}
