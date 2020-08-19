 import 'package:flutter/material.dart';

var ts = TextStyle(
      color:Colors.white,fontWeight: FontWeight.bold,
    //  fontSize: wt/13,
      
      letterSpacing: 2
   );
        var ts1 = TextStyle(
      color:Colors.grey[700],fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,

      
   );
    var btnstyle = TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                     
                      color: Colors.white,
                    );
                    int getColorHexFromStr(String colorStr) {
  colorStr = "FF" + colorStr;
  colorStr = colorStr.replaceAll("#", "");
  int val = 0;
  int len = colorStr.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = colorStr.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
      // A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 97 && hexDigit <= 102) {
      // a..f
      val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
    } else {
      throw new FormatException("An error occurred when converting a color");
    }
  }
  return val;
}