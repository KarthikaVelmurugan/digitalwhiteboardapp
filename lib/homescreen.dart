import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whiteboard/QRview.dart';
import 'package:whiteboard/anim.dart';
import 'package:whiteboard/shared.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> with TickerProviderStateMixin {
  AnimationController animationController;
  OnBoardingEnterAnimation onBoardingEnterAnimation;
  ValueNotifier<double> selectedIndex = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);

    onBoardingEnterAnimation = OnBoardingEnterAnimation(animationController);

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    return WillPopScope(
        onWillPop: _onBackPressed,
        child:
            Scaffold(resizeToAvoidBottomPadding: false, body: _buildContent()));
  }

  Widget _buildContent() {
    final Size size = MediaQuery.of(context).size;
    double ht = size.height;
    double wt = size.width;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Colors.white,
        theme: ThemeData(fontFamily: "Poppins"),
        title: "Online whiteboard",
        home: AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return Stack(
                children: <Widget>[
                  _buildTopBubble(
                      size.height,
                      -size.height * 0.5,
                      -size.width * 0.1,
                      LinearGradient(
                        begin: FractionalOffset.bottomLeft,
                        end: FractionalOffset.topRight,
                        colors: <Color>[
                          Color(getColorHexFromStr("#EA9F57")),
                          Color(getColorHexFromStr("#DD6F85")),
                        ],
                      )),
                  _buildTopBubble(
                      size.width,
                      -size.width * 0.5,
                      size.width * 0.5,
                      LinearGradient(
                        begin: FractionalOffset.bottomLeft,
                        end: FractionalOffset.topRight,
                        colors: <Color>[
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.2),
                        ],
                      )),
                  _buildTopBubble(
                      size.width,
                      -size.width * 0.5,
                      -size.width * 0.7,
                      LinearGradient(
                        begin: FractionalOffset.bottomLeft,
                        end: FractionalOffset.topRight,
                        colors: <Color>[
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.2),
                        ],
                      )),
                  _buildTopBubble(
                      size.width,
                      -size.width * 0.7,
                      -size.width * 0.4,
                      LinearGradient(
                        begin: FractionalOffset.bottomLeft,
                        end: FractionalOffset.topRight,
                        colors: <Color>[
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.2),
                        ],
                      )),
                  _buildTopBubble(
                      size.width,
                      -size.width * 0.7,
                      size.width * 0.2,
                      LinearGradient(
                        begin: FractionalOffset.bottomLeft,
                        end: FractionalOffset.topRight,
                        colors: <Color>[
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.2),
                        ],
                      )),
                  _buildTopBubble(
                      size.width * 0.5,
                      -size.width * 0.5,
                      size.width * 0.5,
                      LinearGradient(
                        begin: FractionalOffset.bottomLeft,
                        end: FractionalOffset.topRight,
                        colors: <Color>[
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.0),
                        ],
                      )),
                  _buildTopBubble(
                      size.height * 0.5,
                      size.height * 0.5,
                      -size.width * 0.5,
                      LinearGradient(
                        begin: FractionalOffset.bottomLeft,
                        end: FractionalOffset.topRight,
                        colors: <Color>[
                          Color(getColorHexFromStr("#EC5A7A")),
                          Color(getColorHexFromStr("#E17D73")),
                        ],
                      )),
                  FadeTransition(
                      opacity: onBoardingEnterAnimation.fadeTranslation,
                      child: Center(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            _cardList(ht, wt),
                          ])))
                ],
              );
            }));
  }

  String result = '';

  Card _cardList(double ht, double wt) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 20,
      shadowColor: Colors.deepOrange,
      child: Container(
          height: ht / 4,
          width: wt / 1.5,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRViewExample(),
                        ),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "assets/scan.png",
                          height: ht / 5,
                          width: wt / 6,
                          fit: BoxFit.fitWidth,
                        ),
                        Text(
                          "Live whiteboard",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ])),
    );
  }

  Widget _buildTopBubble(double diameter, double top, double right,
      LinearGradient linearGradient) {
    return Positioned(
      top: top,
      right: right,
      child: Transform(
        transform: Matrix4.diagonal3Values(
            onBoardingEnterAnimation.scaleTranslation.value,
            onBoardingEnterAnimation.scaleTranslation.value,
            0.0),
        child: Container(
            height: diameter,
            width: diameter,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(diameter / 2),
                gradient: linearGradient)),
      ),
    );
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
                  SystemNavigator.pop();
                },
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
