import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whiteboardkit/drawing_controller.dart';
import 'package:whiteboardkit/whiteboardkit.dart';

class Whiteboardmodel extends StatefulWidget {
  String qrtext;
  Whiteboardmodel({this.qrtext});
  @override
  _WhiteboardState createState() => _WhiteboardState();
}

class _WhiteboardState extends State<Whiteboardmodel> {
  DrawingController controller;
  String emailu;
  String _orientationValue;
  int _orientation;
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
    Size size = MediaQuery.of(context).size;
    dynamic orientation = MediaQuery.of(context).orientation;
    double ht = size.height;
    double wt = size.width;
    print("Height" + ht.toString() + orientation.toString());

    print("Width" + wt.toString() + orientation.toString());
    print("orientation is" + orientation.toString());
    setState(() {
      orientation == Orientation.portrait
          ? controller.initializeSize(wt, ht - 100)
          : controller.initializeSize(ht - 10, wt);
    });

    return MaterialApp(
      //theme: ThemeData(fontFamily: "Poppins"),
      debugShowCheckedModeBanner: false,
      title: "Online white Board",
      home: Scaffold(
          body: Container(
              height: ht,
              width: wt,
              child: Column(children: <Widget>[
                Whiteboard(
                  controller: controller,
                ),
              ]))),
    );
  }

  _checkmode(double wt) {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
                title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text("Select Device mode",
                        style: TextStyle(
                            fontSize: wt / 30,
                            color: Colors.grey[700],
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Radio(
                        value: 0,
                        focusColor: Colors.red,

                        //activeColor: Colors.redAccent,

                        groupValue: _orientation,
                        onChanged: _handleprofession,
                      ),
                      new Text("Potrait",
                          style: TextStyle(
                            fontSize: wt / 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                      new Radio(
                        value: 1,
                        groupValue: _orientation,
                        onChanged: _handleprofession,
                      ),
                      new Text("faculty",
                          style: TextStyle(
                            fontSize: wt / 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                    ],
                  ),
                  SizedBox(
                    child: _orientationValue == true
                        ? Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Please select any mode",
                              style: TextStyle(
                                  fontSize: wt / 30, color: Colors.red[600]),
                            ))
                        : Text(""),
                  )
                ])));
  }

  void _handleprofession(int value) {
    setState(() {
      _orientation = value;
    });
    if (_orientation == 0) {
      print("student");
      _orientationValue = "potrait";
    }
    if (_orientation == 1) {
      print("faculty");
      _orientationValue = "landscape";
    }
  }
}
