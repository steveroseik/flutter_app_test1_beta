// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_app_test1/FETCH_wdgts.dart';
// import 'package:flutter_app_test1/routesGenerator.dart';
// import 'package:line_awesome_flutter/line_awesome_flutter.dart';
//
//
// void main() => runApp(ReminderPage());
//
//
// class  ReminderPage extends StatelessWidget {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Profile List",
//       //theme: ThemeData(
// //primarySwatch: Colors.grey,
// //),
//       home: MainPage(),
//       debugShowCheckedModeBanner: false,
//
//     );
//
//   }
// }
// class MainPage extends StatefulWidget {
//   const MainPage({Key? key}) : super(key: key);
//
//   @override
//   State<MainPage> createState() => _MainPageState();
// }
//
// class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{
//
//
//
//   @override
//   void initState() {
//
//     super.initState();
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 5,
//       child: Scaffold(
//         body: NestedScrollView(
//           headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//             return <Widget>[
//               new SliverAppBar(
//
//                 elevation: 8,
//                 shadowColor: Colors.black,
//                 title: const Text(
//                   "FETCH",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 centerTitle: false,
//                 leadingWidth: 0,
//                 backgroundColor: Colors.white70,
//                 bottom: TabBar(
//                   indicatorSize: TabBarIndicatorSize.label,
//                   indicatorColor: Colors.black,
//                   indicatorWeight: 5,
//                   labelColor: Colors.black,
//
//                   isScrollable: true,
//                   tabs: [
//                     Tab(child: Text('1')),
//                     Tab(child: Text('2')),
//                     Tab(child: Text('3')),
//                     Tab(child: Text('4')),
//                     Tab(child: Text('5')),
//                     Tab(child: Text('6')),
//                     Tab(child: Text('7')),
//                     Tab(child: Text('8')),
//                     Tab(child: Text('9')),
//
//                   ],
//                 ),
//               ),
//             ];
//           },
//           body:  Container(
//             color: Color(0xFFF6F8FC),
//             child: Column(
//               children: [
//
//                 Padding(
//
//                   padding: const EdgeInsets.all(20.0),
//                   child: Text('Reminders', style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 35,
//                   ),),
//                 ),
//
//                 Column(
//                     children: <Widget>[
//                       // InkWell(
//                       //   onTap: () async {
//                       //     settingsNav_key.currentState?.pushNamed(
//                       //         '/editProfile',
//                       //         arguments: userData);
//                       //   },
//                       ProfileListItem(
//                         icon: LineAwesomeIcons.syringe,
//                         text: 'Reminder 1', icon2: null,
//                       ),
//                     ]),
//                 InkWell(
//                   onTap: () async {},
//                   child: ProfileListItem(
//                     icon: LineAwesomeIcons.syringe,
//                     text: 'Reminder 2',
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     // FirebaseAuth.instance.signOut();
//                   },
//                   child: ProfileListItem(
//                     icon: LineAwesomeIcons.syringe,
//                     text: 'Reminder 3',
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     // FirebaseAuth.instance.signOut();
//                   },
//                   child: ProfileListItem(
//                     icon: LineAwesomeIcons.syringe,
//                     text: 'Reminder 4',
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     // FirebaseAuth.instance.signOut();
//                   },
//                   child: ProfileListItem(
//                     icon: LineAwesomeIcons.syringe,
//                     text: 'Reminder 5',
//                   ),
//                 ),
//
//
//                 SizedBox.fromSize(
//                   size: Size(56, 56), // button width and height
//                   child: ClipOval(
//                     child: Material(
//                       color: Colors.white, // button color
//                       child: InkWell(
//                         splashColor: Colors.black, // splash color
//                         onTap: () {}, // button pressed
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Icon(Icons.add, color: Colors.black,), // icon
//                             // text
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//
//
//             ),
//
//
//           ),
//         ),
//       ),
//     );
//
//   }
// }
//
//
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: Text("Reminder 1"),),
//     );
//   }
// }