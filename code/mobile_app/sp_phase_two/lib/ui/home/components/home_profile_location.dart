// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// /// Issues
// /// 1. Not yet refactored
//
// class HomeProfileLocation extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
// //      body: BlocBuilder<UserDataBloc, UserDataState>(
// //        // ignore: missing_return
// //        builder: (BuildContext context, UserDataState state) {
// //          return Container(
// //            padding: EdgeInsets.all(20),
// //            child: (state is UserDataLoaded) ? _body(state) : Container(),
// //          );
// //        },
// //      ),
//     );
//   }
//
//   Widget _body(dynamic state) {
//     return Column(
//       children: <Widget>[
//         Row(
//           children: <Widget>[
//             Expanded(
//               child: AuthTextField(
//                 value: state.userData.firstName,
//                 hintText: "First name",
//               ),
//             ),
//             SizedBox(width: 15.0),
//             Expanded(
//               child: AuthTextField(
//                 value: state.userData.lastName,
//                 hintText: "Last name",
//               ),
//             )
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// ///Temporary Widget
//
// class AuthTextField extends StatelessWidget {
//   final String hintText;
//   final double verticalPadding;
//   final String value;
//   final Icon suffixIcon;
//   final bool showLabel;
//   final bool obscure;
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
//       child: Column(
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
//             enabled: false,
//             //controller: controller,
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
