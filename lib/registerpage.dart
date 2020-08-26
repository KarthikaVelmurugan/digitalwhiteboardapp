import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whiteboard/animation_delay.dart';
import 'package:whiteboard/checkingnet.dart';
import 'package:whiteboard/fluttertoast.dart';
import 'package:whiteboard/globals.dart';
import 'package:whiteboard/homescreen.dart';
import 'package:whiteboard/login.dart';
import 'package:whiteboard/netcheckdialogue.dart';
import 'package:whiteboard/signin.dart';

import 'widgets/custom_shape.dart';
import 'widgets/responsive_ui.dart';

import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  @override
  _Register createState() => _Register();
}

String sname = '';
String mobno = '';
String res = '';
String profession;
String state;
String district;
String college;

class _Register extends State<Register> with SingleTickerProviderStateMixin {
  String errD = '';
  String errC = '';
  String errS = '';
  final int delayedAmount = 500;
  double _scale;
  AnimationController _controller;
  String _dropDownDistrictValue, _dropDownStateValue, _dropDownCollegeValue;
  bool _validaten = false;
  bool _validatei = false;
  bool _validatem = false;
  bool _professionvalidate = false;
  String professionValue;
  FocusNode namefocusnode,
      mobilefocusnode,
      collegefocusnode,
      statefocusnode,
      districtfocusnode;
  //String profession, college;
  final String url = "https://api.savemynation.com/api/v1/savemynation/state";
  final String durl =
      "https://api.savemynation.com/api/v1/savemynation/district";
  final String curl = "https://colleges-in.herokuapp.com";
  int _profession;
  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;
  int _page = 1;
  TextEditingController nameController = TextEditingController();
  TextEditingController mobnoController = TextEditingController();
  TextEditingController collegeController = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey();
  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  var sessionToken = '';

  List<String> sdata = List();
  List<String> disdata = List();
  List<String> clisdata = List();
  String firebaseToken;

  Future<http.Response> _postRequest() async {
    SharedPreferences whiteprefs = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {
      'name': whiteprefs.getString('name'),
      'mobile': whiteprefs.getString('mobno'),
      'state': state,
      'district': district,
      'professional': whiteprefs.getString('profession'),
      'email': whiteprefs.getString('email'),
      'profileUrl': whiteprefs.getString('url'),
      'deviceType': 'mobile',
      'firebaseToken': firebaseToken,
      'college': college,
      'imei': whiteprefs.getString('imei'),
    };
    CollectionReference collectionReference = Firestore.instance
        .collection('users')
        .document(whiteprefs.getString('email'))
        .collection('profile');
    collectionReference.add(data);
    //encode Map to JSON
    //String body = json.encode(data);
    /*  var sendResponse = await http.post(
        'https://api.savemynation.com/api/partner/savepartner/registervolunteer',
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: data,
        encoding: Encoding.getByName("gzip"));
        print('result');
        sessionToken = json.decode(sendResponse.body)['deviceToken'];
        print(sessionToken);
       //toast(context,"Sessiontoken : $sessionToken");
        whiteprefs.setString('stoken', sessionToken);
     
       
        print(firebaseToken);
        //toast(context,"Firebasetoen is :$firebaseToken");
        
    setState(() {
      print(sendResponse.body);
    });
    return sendResponse;*/
  }

  firebaseCloudMessaging() async {
    String token = await _firebaseMessaging.getToken();

    firebaseToken = token;
  }

  Future<String> getSWData() async {
    var res = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body)['state'];
    print(resBody);
    List<String> tags = resBody != null ? List.from(resBody) : null;
    setState(() {
      sdata = tags;
    });
    return "Sucess";
  }

  Future<String> getCData() async {
    var res = await http
        .get(Uri.encodeFull(curl), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body)['state'];
    print(resBody);
    List<String> tags = resBody != null ? List.from(resBody) : null;
    setState(() {
      clisdata = tags;
    });
    return "Sucess";
  }

  Future<http.Response> postDTRequest() async {
    Map data = {'state': state};
    print("ok");
    var response = await http.post(durl,
        headers: {'Content-Type': "application/x-www-form-urlencoded"},
        body: data,
        encoding: Encoding.getByName("gzip"));
    var reBody = json.decode(response.body)['district'];
    print(reBody);
    List<String> dtags = reBody != null ? List.from(reBody) : null;
    setState(() {
      disdata = dtags;
    });
    return response;
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
    checkingnet(context);
    if (checknet == 'connected') {
      this.getCData();
      this.getSWData();
      firebaseCloudMessaging();
      initPlatformState();
    } else {
      shownet(context);
    }
    namefocusnode = FocusNode();
    mobilefocusnode = FocusNode();
    collegefocusnode = FocusNode();
    statefocusnode = FocusNode();
    districtfocusnode = FocusNode();
    setState(() {
      if (name == null) {
        toast(context, "Sorry!You are not signin properly! try again!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });
  }

  Future<void> initPlatformState() async {
    SharedPreferences whiteprefs = await SharedPreferences.getInstance();
    String platformImei = 'unknown';
    String saveimei = 'unknown';

    String idunique = 'unknown';
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformImei =
          await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      idunique = await ImeiPlugin.getId();
    } on PlatformException {
      platformImei = "Failed to get platform version";
      toast(context,
          "This App requires phone/call management!!\nKindly allow it");
      initPlatformState();
    }

    if (!mounted) return;

    setState(() {
      print(idunique);
      _platformImei = platformImei;
      uniqueId = idunique;
      saveimei = uniqueId;
      whiteprefs.setString('imei', saveimei);
      print(_platformImei);
    });
  }

  @override
  void dispose() {
    super.dispose();
    namefocusnode.dispose();
    mobilefocusnode.dispose();
    collegefocusnode.dispose();
    districtfocusnode.dispose();
    statefocusnode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    checkingnet(context);

    if (name == null) {
      toast(context, "Sorry!You are not signin properly! try again!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    return Material(
      child: Container(
        height: _height,
        width: _width,
        padding: EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DelayedAnimation(child: clipShape(), delay: delayedAmount + 1000),
              DelayedAnimation(
                  child: welcomeTextRow(_width), delay: delayedAmount + 2000),
              DelayedAnimation(
                  child: signInTextRow(), delay: delayedAmount + 3000),
              SizedBox(
                height: 10,
              ),
              _page == 1
                  ? DelayedAnimation(child: form(), delay: delayedAmount + 4000)
                  : form1(),
              SizedBox(height: _height / 12),
              DelayedAnimation(child: button(), delay: delayedAmount + 5000),
            ],
          ),
        ),
      ),
    );
  }

  Widget clipShape() {
    //double height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _height /
                  3.25, //_large? _height/4 : (_medium? _height/3.75 : _height/3.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200], Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.2,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _height /
                  3.5, //_large? _height/4.5 : (_medium? _height/4.25 : _height/4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200], Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        /*  Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(top: _large? _height/30 : (_medium? _height/25 : _height/20)),
          child: CircleAvatar(backgroundImage: NetworkImage(imageUrl,
         //   height: _height/3.5,
         //   width: _width/3.5,
            ),
            radius: 30,
          ),
        ),*/
      ],
    );
  }

  Widget welcomeTextRow(double wt) {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Hello!" + "\t" + name,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: wt / 15 //_large? 60 : (_medium? 50 : 40),
                ),
          ),
        ],
      ),
    );
  }

  Widget signInTextRow() {
    return Center(
        child: Container(
      margin: EdgeInsets.only(left: _width / 15.0),
      child: Row(
        children: <Widget>[
          Text(
            "Personal Details",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: _width / 25 // _large? 20 : (_medium? 17.5 : 15),
                ),
          ),
        ],
      ),
    ));
  }

  Widget form() {
    return Container(
        padding: EdgeInsets.all(25.0),
        //  margin: EdgeInsets.all(1.0),
        child: Card(
          key: _key,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          elevation: 10,
          shadowColor: Colors.deepOrange,
          child: Container(
            padding: EdgeInsets.all(7.0),
            child: Column(
              children: <Widget>[
                nameTextFormField(),
                SizedBox(height: _height / 40.0),
                mobnoTextFormField(),
                SizedBox(height: _height / 40.0),
                //proTextFormField()
                professionalSelect(),
              ],
            ),
          ),
        ));
  }

  Widget form1() {
    return Container(
        padding: EdgeInsets.all(25.0),
        //  margin: EdgeInsets.all(1.0),
        child: Card(
          key: _key,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          elevation: 10,
          shadowColor: Colors.deepOrange,
          child: Container(
            padding: EdgeInsets.all(7.0),
            child: Column(
              children: <Widget>[
                // collegedropdownbox(),
                collegeTextFormField(),
                //      _collegechoose == 'others'? collegeTextFormField() : null,
                statedropdownbox(),

                districtdropdownbox(),
              ],
            ),
          ),
        ));
  }

  Widget collegedropdownbox() {
    return Container(
        child: Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: DropdownButton(
          underline: SizedBox(height: 0.5),
          focusNode: collegefocusnode,
          hint: _dropDownCollegeValue == null
              ? Row(children: <Widget>[
                  Padding(
                      padding: new EdgeInsets.all(3.0),
                      child: Icon(Icons.school,
                          color: Colors.deepOrange, size: 25)),
                  SizedBox(width: 4.0),
                  Text('College Name',
                      style: TextStyle(
                        fontSize: _width / 30,
                        color: Colors.grey[600],
                        letterSpacing: 1,
                      ))
                ])
              : Row(children: <Widget>[
                  Padding(
                      padding: new EdgeInsets.all(3.0),
                      child:
                          Icon(Icons.book, color: Colors.deepOrange, size: 25)),
                  SizedBox(width: 4.0),
                  Text(_dropDownCollegeValue,
                      style: TextStyle(
                        fontSize: _width / 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ))
                ]),
          isExpanded: true,
          iconSize: 24.0,
          style: TextStyle(
              fontSize: _width / 30,
              color: Colors.black,
              letterSpacing: 1,
              fontWeight: FontWeight.w600),
          isDense: false,
          items: clisdata.map(
            (val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(
                  val,
                  style: TextStyle(
                      fontSize: _width / 30,
                      color: Colors.black,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600),
                ),
              );
            },
          ).toList(),
          onChanged: (val) {
            setState(
              () {
                _dropDownCollegeValue = val;
                college = val;
                collegefocusnode.unfocus();
                //  statefocusnode.unfocus();
                statefocusnode.requestFocus();
              },
            );
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.all(3.0),
        child: Text(errC,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: _width / 30, color: Colors.red)),
      ),
    ]));
  }

  Widget districtdropdownbox() {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: DropdownButton(
          underline: SizedBox(),
          focusNode: districtfocusnode,
          hint: _dropDownDistrictValue == null
              ? Row(children: <Widget>[
                  Padding(
                      padding: new EdgeInsets.all(3.0),
                      child: Icon(Icons.location_on,
                          color: Colors.deepOrange, size: 25)),
                  SizedBox(width: 4.0),
                  Text('District',
                      style: TextStyle(
                        fontSize: _width / 30,
                        color: Colors.grey[600],
                        letterSpacing: 1,
                      ))
                ])
              : Row(children: <Widget>[
                  Padding(
                      padding: new EdgeInsets.all(3.0),
                      child: Icon(Icons.location_on,
                          color: Colors.deepOrange, size: 25)),
                  SizedBox(width: 4.0),
                  Text(_dropDownDistrictValue,
                      style: TextStyle(
                        fontSize: _width / 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ))
                ]),
          isExpanded: true,
          iconSize: 25.0,
          style: TextStyle(
              fontSize: _width / 30,
              color: Colors.black,
              letterSpacing: 1,
              fontWeight: FontWeight.w600),
          isDense: false,
          items: disdata.map(
            (val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(
                  val,
                  style: TextStyle(
                      fontSize: _width / 30,
                      color: Colors.black,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600),
                ),
              );
            },
          ).toList(),
          onChanged: (val) {
            setState(
              () {
                _dropDownDistrictValue = val;
                district = val;
                districtfocusnode.unfocus();
                // districtfocusnode.requestFocus();
                //  this.postDTRequest();
              },
            );
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.all(3.0),
        child: Text(errD,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: _width / 30, color: Colors.red)),
      ),
    ]);
  }

  Widget statedropdownbox() {
    return Container(
        child: Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: DropdownButton(
          underline: SizedBox(height: 0.5),
          focusNode: statefocusnode,
          hint: _dropDownStateValue == null
              ? Row(children: <Widget>[
                  Padding(
                      padding: new EdgeInsets.all(3.0),
                      child:
                          Icon(Icons.book, color: Colors.deepOrange, size: 25)),
                  SizedBox(width: 4.0),
                  Text('State',
                      style: TextStyle(
                        fontSize: _width / 30,
                        color: Colors.grey[600],
                        letterSpacing: 1,
                      ))
                ])
              : Row(children: <Widget>[
                  Padding(
                      padding: new EdgeInsets.all(3.0),
                      child:
                          Icon(Icons.book, color: Colors.deepOrange, size: 25)),
                  SizedBox(width: 4.0),
                  Text(_dropDownStateValue,
                      style: TextStyle(
                        fontSize: _width / 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ))
                ]),
          isExpanded: true,
          iconSize: 24.0,
          style: TextStyle(
              fontSize: _width / 30,
              color: Colors.black,
              letterSpacing: 1,
              fontWeight: FontWeight.w600),
          isDense: false,
          items: sdata.map(
            (val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(
                  val,
                  style: TextStyle(
                      fontSize: _width / 30,
                      color: Colors.black,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600),
                ),
              );
            },
          ).toList(),
          onChanged: (val) {
            setState(
              () {
                _dropDownStateValue = val;
                state = val;
                statefocusnode.unfocus();
                districtfocusnode.requestFocus();
                this.postDTRequest();
              },
            );
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.all(3.0),
        child: Text(errS,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: _width / 30, color: Colors.red)),
      ),
    ]));
  }

  Widget collegeTextFormField() {
    return TextFormField(
      onChanged: (value) {
        college = value;
      },
      focusNode: collegefocusnode,
      onFieldSubmitted: (String value) {
        collegefocusnode.unfocus();
        statefocusnode.requestFocus();
      },
      style: TextStyle(
          fontSize: _width / 30,
          color: Colors.black,
          letterSpacing: 1,
          fontWeight: FontWeight.w600),
      controller: collegeController,
      keyboardType: TextInputType.text,
      cursorColor: Colors.deepOrange,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.school, color: Colors.deepOrange, size: 25),
        hintText: "Institution Name",
        hintStyle: TextStyle(fontSize: _width / 30),
        errorText: _validatei ? 'Please type your institution name' : null,
        errorStyle: TextStyle(
          fontSize: _width / 30,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget professionalSelect() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("Select Your Profession",
                style: TextStyle(
                    fontSize: _width / 30,
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

                groupValue: _profession,
                onChanged: _handleprofession,
              ),
              new Text("student",
                  style: TextStyle(
                    fontSize: _width / 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
              new Radio(
                value: 1,
                groupValue: _profession,
                onChanged: _handleprofession,
              ),
              new Text("faculty",
                  style: TextStyle(
                    fontSize: _width / 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ],
          ),
          SizedBox(
            child: _professionvalidate == true
                ? Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Please select your profession",
                      style: TextStyle(
                          fontSize: _width / 30, color: Colors.red[600]),
                    ))
                : Text(""),
          )
        ]);
  }

  void _handleprofession(int value) {
    setState(() {
      _profession = value;
    });
    if (_profession == 0) {
      print("student");
      professionValue = "student";
    }
    if (_profession == 1) {
      print("faculty");
      professionValue = "faculty";
    }
  }

  Widget nameTextFormField() {
    return TextFormField(
      onChanged: (value) {
        sname = value;
      },
      focusNode: namefocusnode,
      onFieldSubmitted: (String value) {
        //   namefocusnode.unfocus();
        mobilefocusnode.requestFocus();
      },
      style: TextStyle(
          fontSize: _width / 30,
          color: Colors.black,
          letterSpacing: 1,
          fontWeight: FontWeight.w600),
      controller: nameController,
      keyboardType: TextInputType.text,
      cursorColor: Colors.deepOrange,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person, color: Colors.deepOrange, size: 25),
        hintText: "Name",
        hintStyle: TextStyle(fontSize: _width / 30),
        errorText:
            _validaten ? 'Name must contains atleast 4 characters' : null,
        errorStyle: TextStyle(
          fontSize: _width / 30,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget mobnoTextFormField() {
    return TextFormField(
      onChanged: (value) {
        mobno = value;
      },
      focusNode: mobilefocusnode,
      onFieldSubmitted: (String value) {
        mobilefocusnode.unfocus();
        //  mobilefocusnode.requestFocus();
      },
      style: TextStyle(
          fontSize: _width / 30,
          color: Colors.black,
          letterSpacing: 1,
          fontWeight: FontWeight.w600),
      controller: mobnoController,
      keyboardType: TextInputType.number,
      cursorColor: Colors.deepOrange,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.call, color: Colors.deepOrange, size: 25),
        hintText: "Mobile No",
        hintStyle: TextStyle(fontSize: _width / 30),
        errorText: _validatem ? 'Invalid Mobile Number' : null,
        errorStyle: TextStyle(fontSize: _width / 30),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget button() {
    return RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () async {
        setState(() {
          if (_page == 1) {
            //do unit testing for form 1

            var f = 0;
            _validaten = false;
            _validatem = false;
            _professionvalidate = false;

            if (sname == null || sname.length < 4) {
              _validaten = true;

              f = 1;
            }
            if (mobno == null || (mobno.length < 10)) {
              _validatem = true;

              f = 1;
            }
            if (professionValue == null) {
              _professionvalidate = true;

              f = 1;
            }
            if (f == 0) {
              //    toast(context,"Your $name and Mobile $mobno saved!");
              storeData();
              _page = 2;
              /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>Register1()
                    ),
                  );*/

            }
          } else if (_page == 2) {
            var f1 = 0;
            errS = '';
            errD = '';
            _validatei = false;

            if (college == null) {
              _validatei = true;

              f1 = 1;
            }
            if (_dropDownStateValue == null) {
              errS = 'Please Enter your State.';

              f1 = 1;
            }
            if (_dropDownDistrictValue == null) {
              errD = 'Please Enter your district.';

              f1 = 1;
            }

            if (f1 == 0) {
              storeData1();
              _postRequest().whenComplete(() async {
                SharedPreferences whiteprefs =
                    await SharedPreferences.getInstance();
                whiteprefs.setBool('first_time', false);
                print('bool value changed');
                //  toast(context,"Successfully registered!!!");

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              });
            }
          }
        });
      },
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width:
            _width / 3, //_large? _width/4 : (_medium? _width/3.75: _width/3.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[Colors.orange[200], Colors.pinkAccent],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: _page == 1
            ? Text('next', style: TextStyle(fontSize: _width / 20))
            : Text('submit', style: TextStyle(fontSize: _width / 20)),
      ),
    );
  }

  storeData() async {
    SharedPreferences whiteprefs = await SharedPreferences.getInstance();
    setState(() {
      print(sname + email + imageUrl + name + mobno + professionValue);

      whiteprefs.setString('sname', name);
      whiteprefs.setString('email', email);
      whiteprefs.setString('url', imageUrl);
      whiteprefs.setString('name', sname);
      whiteprefs.setString('mobno', mobno);
      whiteprefs.setString('profession', professionValue);
    });
  }

  storeData1() async {
    SharedPreferences whiteprefs = await SharedPreferences.getInstance();
    setState(() {
      print(college);

      whiteprefs.setString('college', college);
      whiteprefs.setString('state', state);
      whiteprefs.setString('district', district);
    });
  }
}

String donametest() {
  if (sname.length < 4 || sname == '') {
    return "Invalid username";
  } else
    return "valid username : $sname";
}

String domobtest() {
  if (mobno.length == 10 && mobno != '')
    return "valid mobileno : $mobno";
  else
    return "Invalid Mobile number";
}

String doprotest() {
  if (profession == null)
    return "Invalid Profession";
  else
    return "Valid Profession : $profession";
}

String docollegetest() {
  if (college == null)
    return "Invalid College";
  else
    return "Valid College : $college";
}

String dostatetest() {
  if (state == null)
    return "Invalid state";
  else
    return "Valid state : $state";
}

String dodistest() {
  if (district == null)
    return "Invalid district";
  else
    return "Valid state : $district";
}
