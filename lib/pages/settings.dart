import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';

import '../APILibraries.dart';
import '../routesGenerator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            elevation: 8,
            shadowColor: Colors.cyanAccent[70],
            title: const Text(
              "FETCH",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            leadingWidth: 0,
            backgroundColor: Colors.white70,
            actions: const []),
        body: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .5,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.elliptical(
                                MediaQuery.of(context).size.width * 0.5, 100.0),
                            bottomRight: Radius.elliptical(
                                MediaQuery.of(context).size.width * 0.5, 100.0),
                          ),
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/images/DogFamily.jpg'),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Stack(
                        children: [],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage:
                            AssetImage('assets/images/Avatar.png'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    'Dogs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '|',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Hiking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '|',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Food',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
                child: Text(
                  'I have 2 dogs Roy and Leo and they are my life',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, primary: Colors.teal[400],
                        shape: const BeveledRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3))),
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () async{
                        FirebaseAuth.instance.signOut();
                        // final uid = FirebaseAuth.instance.currentUser!.uid;
                        // final userData = await fetchUserData(uid);
                        // settingsNav_key.currentState?.pushNamed('/editProfile', arguments: userData);
                      },
                      child: const Text(
                        'Edit Profile',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
