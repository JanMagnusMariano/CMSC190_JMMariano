import 'package:flutter/material.dart';
import '../../global_widgets.dart';

// TODO: Decide whether to utilize hintText or not
// TODO: Add more detailed documentation/comments

class AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData icon;
  double _width;
  double _pixelRatio;
  bool large;
  bool medium;


  AuthTextField(
    {this.hint,
      this.textEditingController,
      this.keyboardType,
      this.icon,
      this.obscureText= false,
     });

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    large =  GlobalWidgets.isScreenLarge(_width, _pixelRatio);
    medium=  GlobalWidgets.isScreenMedium(_width, _pixelRatio);
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: large? 12 : (medium? 10 : 8),
      child: TextFormField(
        controller: textEditingController,
        keyboardType: keyboardType,
        cursorColor: Colors.orange[200],
        obscureText: obscureText != null ? obscureText : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange[200], size: 20),
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

// class AuthTextField extends StatelessWidget {
//   final String hintText, value;
//   final double verticalPadding;
//   final Icon suffixIcon;
//   final bool showLabel, obscure;
//   final TextInputType keyboardType;
//   final TextEditingController controller;
//
//   AuthTextField(
//       {@required this.hintText,
//       this.controller,
//       this.verticalPadding,
//       this.value,
//       this.suffixIcon,
//       this.obscure,
//       this.keyboardType,
//       this.showLabel = true});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.only(bottom: 10),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           showLabel
//               ? Text(
//                   hintText.toUpperCase(),
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14.0,
//                     color: Color(0xFF9CA4AA),
//                   ),
//                 )
//               : SizedBox(),
//           SizedBox(height: 7.0),
//           TextFormField(
//             controller: controller,
//             initialValue: value,
//             keyboardType: keyboardType,
//             obscureText: obscure != null ? obscure : false,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//             decoration: InputDecoration(
//               suffixIcon: suffixIcon,
//               contentPadding: EdgeInsets.symmetric(
//                   vertical: verticalPadding != null ? verticalPadding : 10.0,
//                   horizontal: 15.0),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.grey[400],
//                 ),
//               ),
// //              hintText: hintText,
// //              hintStyle: TextStyle(
// //                fontWeight: FontWeight.w500,
// //                fontSize: 16.0,
// //                color: Colors.grey[400],
// //              ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
