 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
toast(BuildContext context,String msg){
return  Fluttertoast.showToast(msg:msg,toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,timeInSecForIosWeb: 1,backgroundColor: Colors.white,
                      textColor: Colors.blue,fontSize: MediaQuery.of(context).size.width/28); 
}