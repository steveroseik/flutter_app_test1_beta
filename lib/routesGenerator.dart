import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_app_test1/pages/breed.dart';
import 'package:flutter_app_test1/pages/breed_sp.dart';
import 'package:flutter_app_test1/pages/breed_registration.dart';
import 'package:flutter_app_test1/pages/emailVerify.dart';
import 'package:flutter_app_test1/pages/forgotPassword.dart';
import 'package:flutter_app_test1/pages/user_profile.dart';
import 'package:flutter_app_test1/pages/home.dart';
import 'package:flutter_app_test1/pages/login.dart';
import 'package:flutter_app_test1/pages/signup_completion.dart';
import 'package:flutter_app_test1/mainApp.dart';
import 'package:flutter_app_test1/pages/signupWithEmail.dart';

// This is for routes configurations across the whole application

// Global keys identify each Navigator key for individual tabs in application
GlobalKey<NavigatorState> BA_key = GlobalKey();
GlobalKey<NavigatorState> rootNav_key = GlobalKey();
GlobalKey<NavigatorState> AppNav_key = GlobalKey();
GlobalKey<NavigatorState> UserNav_key = GlobalKey();

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
        return MaterialPageRoute(builder: (_) => addBreedPage());
      case '/pet_register':
        //this case is for second step of pet verification after taking a picture of the pet
        // if happens to navigate to the page with an unidentified photo will navigate to error route
        if (args is File) {
          return MaterialPageRoute(
            builder: (_) => petRegPage(recFile: args), // Second Page
          );
        }
        return _errorRoute();
      case '/pet_adopt':
        return MaterialPageRoute(
          builder: (_) => breedSearchPage(), // Second Page
        );
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
      case '/no_pass':
        return MaterialPageRoute(
          builder: (_) => breedSearchPage(), // Second Page
        );

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
