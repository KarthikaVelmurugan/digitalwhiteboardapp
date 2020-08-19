import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whiteboard/animation_delay.dart';
import 'package:whiteboard/checkingnet.dart';
import 'package:whiteboard/globals.dart';
import 'package:whiteboard/shared.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:whiteboard/whiteboardkit.dart';
import 'theme.dart' as Theme;

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin {
  //  final Location location = Location();

  final int delayedAmount = 500;
  double _scale;
  AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    checkingnet(context);

    MediaQueryData queryData = MediaQuery.of(context);
    double ht = queryData.size.height;
    double wt = queryData.size.width;
    var ts = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: wt / 20,
    );

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Colors.white,
        theme: ThemeData(
          fontFamily: 'Poppins',
        ),
        title: "White Board Class Room",
        home: WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
              body: Container(
                height: ht,
                width: wt,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    DelayedAnimation(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        height: ht / 2.5,
                        width: queryData.size.width,
                        child: Image.asset(
                          'assets/login_logo.png',
                          height: ht / 3,
                        ),
                      ),
                      delay: delayedAmount + 1000,
                    ),
                    DelayedAnimation(
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(child: _startButton(wt))),
                      delay: delayedAmount + 2000,
                    ),
                  ],
                ),
              ),
            )));
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () {
                  //  toast(context,"Thank You For Your Collaboration!!");
                  Navigator.of(context).pop(true);
                },
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _startButton(double wt) {
    return OutlineButton(
      onPressed: () async {
        checkingnet(context);

        if (checknet == 'connected') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return DemoWhiteboard();
          }));
          /*  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return MyWebView(title:"White Board",selectedUrl:"https://mostafazke.github.io/ng-whiteboard/");
                      },
                    ),
                  );  */

        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.white70, width: 2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text('Open WhiteBoard',
              style: btnstyle.copyWith(fontSize: wt / 25)),
        ),
      ),
    );
  }
}
