import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../global_widgets.dart';
import '../../blocs/register/bloc.dart';
import '../../blocs/connection/bloc.dart' as Local;

import 'components/components.dart';

// TODO: Add appropriate error widgets when fields are incorrect (i.e not filled/wrong credentials)
// TODO: Add more detailed documentation/comments

class Register extends StatefulWidget {
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController
      _firstName = TextEditingController(),
      _lastName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;

  bool get hasText => _emailController.text.isNotEmpty
      && _passwordController.text.isNotEmpty
      && _firstName.text.isNotEmpty
      && _lastName.text.isNotEmpty;

  bool isRegisterButtonEnabled(RegisterState state) =>
      hasText && !state.isSubmitting;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  bool isRegisterEnabled(RegisterState state) =>
      hasText && !state.isSubmitting;

  void _onEmailChanged() {
    BlocProvider.of<RegisterBloc>(context)
        .add(RegisterEmailChanged(email: _emailController.text));
  }

  void _onPasswordChanged() {
    BlocProvider.of<RegisterBloc>(context)
        .add(RegisterPasswordChanged(password: _passwordController.text));
  }

  void _onFormSubmitted() {
    var connectionStatus = Provider.of<Local.ConnectionState>(context, listen: false);

    if (connectionStatus is Local.ConnectionOnline) {
      BlocProvider.of<RegisterBloc>(context).add(
        RegisterSubmitted(
          firstName: _firstName.text,
          lastName: _lastName.text,
          email: _emailController.text,
          password: _passwordController.text
        ),
      );
    } else if (connectionStatus is Local.ConnectionOffline) {
      noConnectionOverlay(context,
        whenRetry: () => _onFormSubmitted(),
        whenOffline: () => BlocProvider.of<RegisterBloc>(context).add(RegisterWithGuest()),
      );
    }
  }

  List<Widget> createFormElements(RegisterState state) {
    return <Widget>[
      Opacity(opacity: 1,child: CustomAppBar()),
      clipShape(),
      SizedBox(height: _height / 25),
      signUpTextRow(),
      fillerTextRow(),
      form(),
      SizedBox(height: _height / 15),
      button(state),
      //infoTextRow(),
      //socialIconsRow(),
      // Row(
      //   children: <Widget>[
      //     Expanded(
      //       child: AuthTextField(
      //         hintText: 'First Name',
      //         controller: _firstName,
      //       ),
      //     ),
      //     SizedBox(width: 15),
      //     Expanded(
      //       child: AuthTextField(
      //         hintText: 'Last Name',
      //         controller: _lastName,
      //       ),
      //     ),
      //   ],
      // ),
      // AuthTextField(
      //   hintText: 'Email',
      //   controller: _emailController,
      //   keyboardType: TextInputType.emailAddress,
      // ),
      // AuthTextField(
      //   hintText: 'Password',
      //   controller: _passwordController,
      //   obscure: true,
      // ),
      // AuthButtons.registerSubmit(onPressed: isRegisterEnabled(state) ? _onFormSubmitted : null),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large =  GlobalWidgets.isScreenLarge(_width, _pixelRatio);
    _medium =  GlobalWidgets.isScreenMedium(_width, _pixelRatio);

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) => checkState(context, state),
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Container(
            height: _height,
            width: _width,
            margin: EdgeInsets.only(bottom: 5),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: createFormElements(state),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widgets

  Widget clipShape() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large? _height/8 : (_medium? _height/7 : _height/6.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200], Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _large? _height/12 : (_medium? _height/11 : _height/10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200], Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        // Container(
        //   height: _height / 5.5,
        //   alignment: Alignment.center,
        //   decoration: BoxDecoration(
        //     boxShadow: [
        //       BoxShadow(
        //           spreadRadius: 0.0,
        //           color: Colors.black26,
        //           offset: Offset(1.0, 10.0),
        //           blurRadius: 20.0),
        //     ],
        //     color: Colors.white,
        //     shape: BoxShape.circle,
        //   ),
        //   child: GestureDetector(
        //       onTap: (){
        //         print('Adding photo');
        //       },
        //
        //       child: Icon(Icons.add_a_photo, size: _large? 40: (_medium? 33: 31),color: Colors.orange[200],)),
        // ),
  //        Positioned(
  //          top: _height/8,
  //          left: _width/1.75,
  //          child: Container(
  //            alignment: Alignment.center,
  //            height: _height/23,
  //            padding: EdgeInsets.all(5),
  //            decoration: BoxDecoration(
  //              shape: BoxShape.circle,
  //              color:  Colors.orange[100],
  //            ),
  //            child: GestureDetector(
  //                onTap: (){
  //                  print('Adding photo');
  //                },
  //                child: Icon(Icons.add_a_photo, size: _large? 22: (_medium? 15: 13),)),
  //          ),
  //        ),
      ],
    );
  }

  Widget signUpTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Register an account",
            style: TextStyle(
              fontSize: _large? 60 : (_medium? 20 : 25),
            ),
          ),
        ],
      ),
    );
  }

  Widget fillerTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Fill in the boxes below",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: _large? 20 : (_medium? 10 : 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left:_width/ 12.0,
          right: _width / 12.0,
          top: _height / 25.0),
      child: Form(
        child: Column(
          children: <Widget>[
            firstNameTextFormField(),
            SizedBox(height: _height / 60.0),
            lastNameTextFormField(),
            SizedBox(height: _height/ 60.0),
            emailTextFormField(),
            SizedBox(height: _height / 60.0),
            passwordTextFormField(),
          ],
        ),
      ),
    );
  }

  Widget firstNameTextFormField() {
    return AuthTextField(
      keyboardType: TextInputType.text,
      icon: Icons.person,
      hint: "First Name",
    );
  }

  Widget lastNameTextFormField() {
    return AuthTextField(
      keyboardType: TextInputType.text,
      icon: Icons.person,
      hint: "Last Name",
    );
  }

  Widget emailTextFormField() {
    return AuthTextField(
      keyboardType: TextInputType.emailAddress,
      icon: Icons.email,
      hint: "Email ID",
    );
  }

  Widget passwordTextFormField() {
    return AuthTextField(
      keyboardType: TextInputType.text,
      obscureText: true,
      icon: Icons.lock,
      hint: "Password",
    );
  }

  Widget button(RegisterState state) {
    return RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () => isRegisterEnabled(state) ? _onFormSubmitted() : print('Null'),
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width:_large? _width/4 : (_medium? _width/3.75: _width/3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[Colors.orange[200], Colors.pinkAccent],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text('SIGN UP', style: TextStyle(fontSize: _large? 16: (_medium? 12: 14)),),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void checkState(BuildContext context, RegisterState state) {
    if(state.isFailure) failureOverlay(context);
    else if(state.isSubmitting) GlobalWidgets.loadingOverlay(context);
    // else if(state.isSuccess) {
    //   Navigator.of(context, rootNavigator: true).pop('dialog');
    //   Navigator.pop(context);
    // }
  }
}
