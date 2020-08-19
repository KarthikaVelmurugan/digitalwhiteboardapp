import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whiteboard/QRview.dart';
import 'package:whiteboard/homescreen.dart';
import 'package:whiteboard/whiteboard.dart';

import 'package:whiteboardkit/whiteboardkit.dart';

class DemoWhiteboard extends StatefulWidget {
  String qrtext;
  DemoWhiteboard({this.qrtext});
  @override
  _DemoWhiteboardState createState() => _DemoWhiteboardState();
}

class _DemoWhiteboardState extends State<DemoWhiteboard> {
  DrawingController controller;
  String emailu;

  int flag = 0;
  @override
  void initState() {
    controller = new DrawingController(
      enableChunk: true,
    );

    // controller.toolbox(false);
    controller.brushColor = Colors.black;

    controller.onChunk().listen((chunk) async {
      SharedPreferences whiteprefs = await SharedPreferences.getInstance();

      setState(() {
        emailu = whiteprefs.getString('email');
        //controller_stream.addChunk(chunk);
        print(chunk.toJson());
        Firestore.instance
            .collection('users')
            .document(emailu)
            .collection('whiteboard')
            .document(flag.toString())
            .setData(chunk.toJson());
        print(flag);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic orientation = MediaQuery.of(context).orientation;
    dynamic height = MediaQuery.of(context).size.height;
    dynamic width = MediaQuery.of(context).size.width;
    const WhiteboardStyle ws = WhiteboardStyle(
        toolboxColor: Colors.white10,
        border: Border(
          top: BorderSide.none,
          bottom: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
        ));
    print("orientation" + orientation.toString());
    bool check = false;
    check = orientation == Orientation.landscape ? true : false;
    if (check)
      setState(() {
        print(check);
        orientation == Orientation.landscape
            ? controller.initializeSize(width, height)
            : controller.initializeSize(width, height);
      });
    else
      setState(() {
        print("Check\n\n\n\n" + check.toString());
        orientation == Orientation.landscape
            ? controller.initializeSize(width, height)
            : controller.initializeSize(width, height);
      });
    /* orientation == Orientation.landscape
        ? controller.initializeSize(width, height)
        : controller.initializeSize(width, height);*/
    return MaterialApp(
        //theme: ThemeData(fontFamily: "Poppins"),
        debugShowCheckedModeBanner: false,
        title: "Online white Board",
        home: WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
                body: Container(
                    height: orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.height
                        : 400,
                    width: orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width
                        : 800,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              height: orientation == Orientation.portrait
                                  ? MediaQuery.of(context).size.height - 100
                                  : 300,
                              width: orientation == Orientation.portrait
                                  ? MediaQuery.of(context).size.width
                                  : 800,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    orientation == Orientation.portrait
                                        ? Flexible(
                                            fit: FlexFit.tight,
                                            child: Whiteboard(
                                                controller: controller),
                                          )
                                        : Whiteboard(
                                            controller: controller,
                                          )
                                  ])),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlineButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  highlightedBorderColor: Colors.deepOrange,
                                  onPressed: () {
                                    _callBrushCard();
                                  },
                                  child: Text('change Brush size',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: width / 25))),
                              SizedBox(width: 3),
                              OutlineButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                highlightedBorderColor: Colors.deepOrange,
                                onPressed: () async {
                                  //  _color=!_color;
                                  //controller.erase = true;
                                  //controller.eraserSize = 700;
                                  //controller.undo();
                                  controller.wipe();
                                  Firestore.instance
                                      .collection('users')
                                      .document(emailu)
                                      .collection('whiteboard')
                                      .getDocuments()
                                      .then((snapshot) {
                                    for (DocumentSnapshot ds
                                        in snapshot.documents) {
                                      ds.reference.delete();
                                    }
                                    flag = 0;
                                  });
                                },
                                child: Text('stop/wipe',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: width / 25)),
                              ),
                              /*  RaisedButton(
                    onPressed: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRViewExample(),
                        ),
                      );
                        SharedPreferences whiteprefs = await SharedPreferences.getInstance();
                      setState(() {
                        result = res;
                      
                     Firestore.instance.collection('qrcode').document('Randomno').updateData({'email': whiteprefs.getString('email')});
   

                      });
                    },
                    child: Text('scan'),
                  ),*/
                            ],
                          ),
                        ])))));
  }

  String brushValue = '';
  String _dropDownValue;
  Future<bool> _callBrushCard() {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      border: Border.all(color: Colors.white70, width: 2)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Poppins",
                          color: Colors.black,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500),
                      items: [1, 2, 4, 5, 6, 7, 8].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val.toString(),
                            child: Text(
                              val.toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  color: Colors.black,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(
                          () {
                            _dropDownValue = val;
                            brushValue = val;
                            print("brushvalue" + brushValue);
                            controller.brushSize = double.parse(brushValue);
                          },
                        );
                      },
                      hint: _dropDownValue == null
                          ? Text(
                              'Select your Brush Size',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  color: Colors.black,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500),
                            )
                          : Text(
                              brushValue,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  color: Colors.black,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500),
                            ),
                    ),
                  ),
                ),
              ),
            ));
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to Exit an App'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("Continue"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () {
                  //  toast(context,"Thank You For Your Collaboration!!");

                  Firestore.instance
                      .collection('users')
                      .document(emailu)
                      .collection('whiteboard')
                      .getDocuments()
                      .then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.documents) {
                      ds.reference.delete();
                    }
                  });
                  Firestore.instance
                      .collection('qrcode')
                      .document(widget.qrtext)
                      .delete();
                  //call api for updating status as flase

                  /*  Firestore.instance.collection('qrcode').getDocuments().then((snapshot){
                                                for (DocumentSnapshot ds in snapshot.documents) {
                          ds.reference.delete();
                                                }});*/

                  //    controller.close();

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ));
                },
                child: Text("Leave"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
