import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whiteboard/shared.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:whiteboard/whiteboardkit.dart';

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  var qrText = '';
  var flashState = flashOn;
  var cameraState = frontCamera;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _visible = false;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double ht = size.height;
    double wt = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 20,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Row(children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      //   Text('This is the result of scan: $qrText'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(8),
                            child: OutlineButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              highlightedBorderColor: Colors.deepOrange,
                              onPressed: () {
                                if (controller != null) {
                                  controller.toggleFlash();
                                  if (_isFlashOn(flashState)) {
                                    setState(() {
                                      flashState = flashOff;
                                    });
                                  } else {
                                    setState(() {
                                      flashState = flashOn;
                                    });
                                  }
                                }
                              },
                              child: Text(flashState,
                                  style: ts1.copyWith(fontSize: wt / 30)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(8),
                            child: OutlineButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              highlightedBorderColor: Colors.deepOrange,
                              onPressed: () {
                                if (controller != null) {
                                  controller.flipCamera();
                                  if (_isBackCamera(cameraState)) {
                                    setState(() {
                                      cameraState = frontCamera;
                                    });
                                  } else {
                                    setState(() {
                                      cameraState = backCamera;
                                    });
                                  }
                                }
                              },
                              child: Text(cameraState,
                                  style: ts1.copyWith(fontSize: wt / 30)),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(8),
                            child: OutlineButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              highlightedBorderColor: Colors.deepOrange,
                              onPressed: () {
                                controller?.pauseCamera();
                              },
                              child: Text('pause',
                                  style: ts1.copyWith(fontSize: wt / 30)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(8),
                            child: OutlineButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              highlightedBorderColor: Colors.deepOrange,
                              onPressed: () {
                                controller?.resumeCamera();
                              },
                              child: Text('resume',
                                  style: ts1.copyWith(fontSize: wt / 30)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: AvatarGlow(
                        glowColor: Colors.red,
                        endRadius: 50.0,
                        duration: Duration(milliseconds: 2000),
                        repeat: true,
                        showTwoGlows: true,
                        repeatPauseDuration: Duration(milliseconds: 100),
                        child: Material(
                          elevation: 10.0,
                          shape: CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            child: Image.asset(
                              'assets/icon.png',
                              height: 50,
                            ),
                            radius: 20.0,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _visible = true;
                      });
                      if (_visible == true) _showLiveStreamDialogue(wt);
                    },
                  )
                ]),
              ))
        ],
      ),
    );
  }

  _showLiveStreamDialogue(double wt) {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
            content: InkWell(
              onTap: () {
                launch(
                    'https://karthikavelmurugan.github.io/onlinewhiteboard.tailermade/index.html');
              },
              child: Text(
                "https://karthikavelmurugan.github.io/onlinewhiteboard.tailermade/index.html",
                style: TextStyle(color: Colors.red, fontSize: wt / 35),
              ),
            ),
            title: Card(
                child: Row(children: <Widget>[
              Image.asset('assets/icon.png', height: 70),
              SizedBox(width: 5),
              Text(
                'Make your whiteboard as\n livestream scan QR on\n below link',
                style:
                    TextStyle(fontSize: wt / 30, fontWeight: FontWeight.bold),
              )
            ]))));
  }
  /*
    AlertDialog(
      
      title: new Row(children:<Widget>[
        Image.asset('assets/icon.png',height:50),
        SizedBox(width:5),
        Text('Make your whiteboard as\n livestream scan QR on\n below link',style: TextStyle(fontSize:wt/50),)]),
      content: new InkWell(
        onTap: (){
          launch('https://karthikavelmurugan.github.io/tailermadewhiteboard.github.io/index.html');
        },
        child:Text('https://karthikavelmurugan.github.io/tailermadewhiteboard.github.io/index.html'),),
      actions: <Widget>[
       
        new GestureDetector(
          onTap: () { 
          //  toast(context,"Thank You For Your Collaboration!!");
          setState(() {
            _visible = false;
          });
          },
        
            child:Text("Got It"),
        ),
      ],
    ),
  ) ??
      false;
}
*/

  bool _isFlashOn(String current) {
    return flashOn == current;
  }

  bool _isBackCamera(String current) {
    return backCamera == current;
  }

  void _onQRViewCreated(QRViewController controller) async {
    SharedPreferences whiteprefs = await SharedPreferences.getInstance();
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
      controller.dispose();

      if (qrText != '') {
        Firestore.instance
            .collection('qrcode')
            .document(qrText)
            .updateData({'email': whiteprefs.getString('email'), 'live': true});
        //call api for uploading status as true

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DemoWhiteboard(
                qrtext: qrText,
              ),
            ));
        //Navigator.pop(context, qrText);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
