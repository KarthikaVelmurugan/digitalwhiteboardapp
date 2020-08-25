import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whiteboard/homescreen.dart';
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
  String _dropDownValue;
  String brushValue = '';
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    /*  orientation == Orientation.landscape
        ? SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
          ])
        : SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
          ]);*/
    double ht = size.height;
    double wt = size.width;
    print("Height" + ht.toString() + orientation.toString());

    print("Width" + wt.toString() + orientation.toString());
    print("orientation is" + orientation.toString());
    setState(() {
      controller.initializeSize(wt * 2.6, ht - 500);
    });

    /* 
      orientation == Orientation.portrait
          ? controller.initializeSize(wt, ht - 100)
          : controller.initializeSize(ht - 10, wt);
    });*/

    return MaterialApp(
        //theme: ThemeData(fontFamily: "Poppins"),
        debugShowCheckedModeBanner: false,
        title: "Online white Board",
        home: WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
              appBar: PreferredSize(
                  child: AppBar(
                    title: Text(
                      "WhiteBoard",
                      style: TextStyle(fontSize: wt / 70),
                    ),
                    backgroundColor: Colors.deepOrange[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    elevation: 15,
                    actions: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: RaisedButton(
                          onPressed: () {},
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white,
                          child: DropdownButton(
                              underline: SizedBox(),
                              items: [1, 2, 4, 5, 6, 7, 8].map(
                                (val) {
                                  return DropdownMenuItem<String>(
                                    value: val.toString(),
                                    child: Text(
                                      val.toString(),
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
                                    controller.brushSize =
                                        double.parse(brushValue);
                                  },
                                );
                              },
                              hint: _dropDownValue == null
                                  ? Text("change brush size",
                                      style: TextStyle(
                                          fontSize: wt / 70,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400))
                                  : Text(brushValue,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black))),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white,
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
                              for (DocumentSnapshot ds in snapshot.documents) {
                                ds.reference.delete();
                              }
                              flag = 0;
                            });
                          },
                          child: Text('wipe',
                              style: TextStyle(
                                  color: Colors.black, fontSize: wt / 70)),
                        ),
                      )
                    ],
                  ),
                  preferredSize: Size.fromHeight(30.0)),
              body: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Whiteboard(controller: controller),

                    /*Container(
              height: ht,
              width: wt,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        height: ht,
                        width: wt / 1.25,
                        child: Expanded(
                            child: Whiteboard(
                          controller: controller,
                        ))),
                    SizedBox(
                      width: 5,
                    ),*/
                    /*   Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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
                              for (DocumentSnapshot ds in snapshot.documents) {
                                ds.reference.delete();
                              }
                              flag = 0;
                            });
                          },
                          child: Text('stop/wipe',
                              style: TextStyle(
                                  color: Colors.black, fontSize: wt / 50)),
                        ),
                        SizedBox(height: 8.0),
                        OutlineButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          highlightedBorderColor: Colors.deepOrange,
                          child: DropdownButton(
                              items: [1, 2, 4, 5, 6, 7, 8].map(
                                (val) {
                                  return DropdownMenuItem<String>(
                                    value: val.toString(),
                                    child: Text(
                                      val.toString(),
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
                                    controller.brushSize =
                                        double.parse(brushValue);
                                  },
                                );
                              },
                              hint: _dropDownValue == null
                                  ? Text("change brush size",
                                      style: TextStyle(fontSize: wt / 80))
                                  : Text(brushValue,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                        ),
                      ],
                    )*/
                  ])),
        ));
  }

  Future<bool> _onBackPressed() {
    //  controller.close();
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
                  //      controller.close();
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
