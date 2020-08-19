import 'dart:async';

import 'package:whiteboard/whiteboard.dart';
import 'package:whiteboard/whiteboardkit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whiteboard/homescreen.dart';
import 'package:whiteboard/login.dart';
import 'package:whiteboard/shared.dart';
import 'theme.dart' as Theme;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'White Board Class Room',
      color: Colors.white,
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/HomePage': (BuildContext context) =>
            new HomePage(), //Redirect to homepage
        '/WelcomePage': (BuildContext context) =>
            new Login(), //Redirect to loginpage
      },
    );
  }
}

//creation of Splashscreen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
//Initialize startTime() for predict duration limit.
  startTime() async {
    SharedPreferences whiteprefs = await SharedPreferences.getInstance();
//whiteprefs.clear();
    bool firstTime = whiteprefs.getBool('first_time');

    var _duration = new Duration(seconds: 2);
    if (firstTime != null && !firstTime) {
      // Not first time
      return new Timer(_duration, navigationPageHome);
    } else {
      // First time

      return new Timer(_duration, navigationPageWel);
    }
  }

  void navigationPageHome() {
    //Navigate to Homepage(not first time)
    Navigator.of(context).pushReplacementNamed('/HomePage');
  }

  void navigationPageWel() {
    //Navigate to LoginPage (first time)
    Navigator.of(context).pushReplacementNamed('/WelcomePage');
  }

  @override
  void initState() {
    super.initState();

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    //Find current device size
    Size screenSize = MediaQuery.of(context).size;
    double wt = screenSize.width; //width

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Theme.Colors.loginGradientStart,
                    Theme.Colors.loginGradientEnd
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('White Board', style: ts.copyWith(fontSize: wt / 13)),
                  Text('Class Room ', style: ts.copyWith(fontSize: wt / 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
