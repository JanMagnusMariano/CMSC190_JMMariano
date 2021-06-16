import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../global_widgets.dart';

import '../../blocs/sign_in/bloc.dart';
import '../../blocs/connection/bloc.dart' as Local;

import '../../blocs/register/bloc.dart';

import '../slide_route.dart';
import 'register.dart';

import 'components/components.dart';

/// Issues:
/// 1. Add input validator and sanitizer
/// 2. Add transition animations when switching between screens
/// 3. Add and resize application icons to appropriate size

class SignIn extends StatefulWidget {
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AssetImage _signInIcon = new AssetImage('lib/assets/images/weather_icon.png');
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;
  GlobalKey<FormState> _key = GlobalKey();

  bool get hasText => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isSignInEnabled(SignInState state) => hasText && !state.isSubmitting;

  @override
  void initState() {
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    super.initState();
  }

  void _onEmailChanged() {
    BlocProvider.of<SignInBloc>(context)
        .add(SignInEmailChanged(email: _emailController.text));
  }

  void _onPasswordChanged() {
    BlocProvider.of<SignInBloc>(context)
        .add(SignInPasswordChanged(password: _passwordController.text));
  }

  void _onFormSubmitted() {
    var connectionStatus =
        Provider.of<Local.ConnectionState>(context, listen: false);

    if (connectionStatus is Local.ConnectionOnline) {
      BlocProvider.of<SignInBloc>(context).add(
        SignInWithCredentialsPressed(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    } else if (connectionStatus is Local.ConnectionOffline) {
      //BlocProvider.of<SignInBloc>(context).add(SignInWithGuest());
      noConnectionOverlay(context,
        whenRetry: () => _onFormSubmitted(),
        whenOffline: () => BlocProvider.of<SignInBloc>(context).add(SignInWithGuest()),
      );
    }
  }

  List<Widget> createFormElements(SignInState state, BuildContext context) {
    return <Widget>[
      clipShape(),
      SizedBox(height: _height / 25),
      welcomeTextRow(),
      //signInTextRow(),
      form(),
      //forgetPassTextRow(),
      SizedBox(height: _height / 15),
      button(state),
      SizedBox(height: _height / 20),
      signUpTextRow(),
      // Container(
      //   padding: EdgeInsets.symmetric(vertical: 20),
      //   child: Container(
      //     height: 100,
      //     width: 100,
      //     decoration: BoxDecoration(
      //       image: DecorationImage(
      //         fit: BoxFit.fill,
      //         image: _signInIcon,
      //       ),
      //     ),
      //   ),
      //   //child: Image.asset('assets/flutter_logo.png', height: 200),
      // ),
      // AuthTextField(
      //   keyboardType: TextInputType.emailAddress,
      //   textEditingController: _emailController,
      //   icon: Icons.email,
      //   hint: "Email ID",
      // ),
      // AuthTextField(
      //   keyboardType: TextInputType.emailAddress,
      //   textEditingController: _passwordController,
      //   icon: Icons.lock,
      //   obscureText: true,
      //   hint: "Password",
      // ),
      // SizedBox(height: 10),
      // AuthButtons.loginSubmit(onPressed: isSignInEnabled(state) ? _onFormSubmitted : null),
      // GoogleSignInButton(),
      // //Components.CreateAccountButton(),
      // AuthButtons.registerButton(context),
      // //trial
      // Guest()
    ];
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large =  GlobalWidgets.isScreenLarge(_width, _pixelRatio);
    _medium =  GlobalWidgets.isScreenMedium(_width, _pixelRatio);

    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) => checkState(context, state),
      child: BlocBuilder<SignInBloc, SignInState>(
        builder: (context, state) {
          return Container(
            height: _height,
            width: _width,
            padding: EdgeInsets.only(bottom: 5.0),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: createFormElements(state, context),
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
              height:_large? _height/4 : (_medium? _height/3.75 : _height/3.5),
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
              height: _large? _height/4.5 : (_medium? _height/4.25 : _height/4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200], Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/10 : _height/7.5)),
          child: Image.asset(
            'lib/assets/images/icon.png',
            height: _height/4,
            width: _width/2,
          ),
        ),
      ],
    );
  }

  Widget welcomeTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 150),
      child: Row(
        children: <Widget>[
          Text(
            "Sign in to your account",
            style: TextStyle(
              fontSize: _large? 50 : (_medium? 20 : 25),
            ),
          ),
        ],
      ),
    );
  }

  // Widget signInTextRow() {
  //   return Container(
  //     margin: EdgeInsets.only(left: _width / 15.0),
  //     child: Row(
  //       children: <Widget>[
  //         Text(
  //           "Sign in to your account",
  //           style: TextStyle(
  //             fontWeight: FontWeight.w200,
  //             fontSize: _large? 18 : (_medium? 15.5 : 13),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0,
          right: _width / 12.0,
          top: _height / 15.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            emailTextFormField(),
            SizedBox(height: _height / 40.0),
            passwordTextFormField(),
          ],
        ),
      ),
    );
  }

  Widget emailTextFormField() {
    return AuthTextField(
      keyboardType: TextInputType.emailAddress,
      textEditingController: _emailController,
      icon: Icons.email,
      hint: "Email",
    );
  }

  Widget passwordTextFormField() {
    return AuthTextField(
      keyboardType: TextInputType.emailAddress,
      textEditingController: _passwordController,
      icon: Icons.lock,
      obscureText: true,
      hint: "Password",
    );
  }

  Widget button(SignInState state) {
    return RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () => isSignInEnabled(state) ? _onFormSubmitted() : print('Null'),
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width: _large? _width/4 : (_medium? _width/3.75: _width/3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[Colors.orange[200], Colors.pinkAccent],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text('SIGN IN',style: TextStyle(fontSize: _large? 16: (_medium? 12: 14))),
      ),
    );
  }

  Widget signUpTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 120.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Don't have an account?",
            style: TextStyle(fontWeight: FontWeight.w400,fontSize: _large? 10: (_medium? 12: 14)),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                SlideRoute(page: Scaffold(
                  body : BlocProvider<RegisterBloc>(
                    create: (origContext) => RegisterBloc(),
                    child: Register(),
                  ),
                )),
                // SlideRoute(builder: (context) {
                //   return Scaffold(
                    // body : BlocProvider<RegisterBloc>(
                    //   create: (origContext) => RegisterBloc(),
                    //   child: Register(),
                    // ),
                //   );
                // }),
              );
              print("Routing to Sign up screen");
            },
            child: Text(
              "Sign up",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.orange[200], fontSize: _large? 19: (_medium? 16: 15)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void checkState(BuildContext context, SignInState state) {
    var connectionStatus = Provider.of<Local.ConnectionState>(context, listen: false);

    if(state.isFailure) failureOverlay(context);
    else if(state.isSubmitting) {
      GlobalWidgets.loadingOverlay(context);
    }
    //else if(state.isSuccess) Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
