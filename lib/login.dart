import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whiteboard/animation_delay.dart';
import 'package:whiteboard/checkingnet.dart';
import 'package:whiteboard/fluttertoast.dart';
import 'package:whiteboard/globals.dart';
import 'package:whiteboard/registerpage.dart';
import 'package:whiteboard/shared.dart';
import 'package:whiteboard/signin.dart';
import 'theme.dart' as Theme;

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> with SingleTickerProviderStateMixin {
  final int delayedAmount = 500;
  double _scale;
  AnimationController _controller;
  //getgooglesignin
  getSignIn() async {
    await signInWithGoogle().whenComplete(() async {
      if (name == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              //check user do googlesignin properly or not
              return Login();
            },
          ),
        );
      } else {
        //user signed properly
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Register();
            },
          ),
        );
      }
    });
  }

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
    checkingnet(context);
    _scale = 1 - _controller.value;

    MediaQueryData queryData = MediaQuery.of(context);
    double ht = queryData.size.height;
    double wt = queryData.size.width;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Colors.white,
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
                          height: ht / 5,
                        ),
                      ),
                      delay: delayedAmount + 1000,
                    ),
                    Container(
                        height: ht / 4,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DelayedAnimation(
                                child: Text(
                                  "ONLINE EDUCATION",
                                  style: ts.copyWith(fontSize: wt / 20),
                                ),
                                delay: delayedAmount + 2000,
                              ),
                              DelayedAnimation(
                                child: Text(
                                    "We need to bring learning to people",
                                    style: ts1.copyWith(fontSize: wt / 25)),
                                delay: delayedAmount + 3000,
                              ),
                              DelayedAnimation(
                                child: Text("instead of people to learning",
                                    style: ts1.copyWith(fontSize: wt / 25)),
                                delay: delayedAmount + 4000,
                              ),
                            ])),
                    DelayedAnimation(
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(child: _signInButton(wt))),
                      delay: delayedAmount + 5000,
                    )
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

  Widget _signInButton(double wt) {
    return OutlineButton(
      onPressed: () async {
        checkingnet(context);

        if (checknet == 'connected') {
          signInWithGoogle().whenComplete(() {
            if (name == null) {
              toast(context, "Sorry!You are not signin properly! try again!");
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return Login();
                  },
                ),
              );
            } else {
              //    toast(context,"Successfully signin your google account!");
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return Register();
                  },
                ),
              );
            }
          });
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.white70, width: 2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text('Sign in with Google',
              style: btnstyle.copyWith(fontSize: wt / 25)),
        ),
      ),
    );
  }
}
