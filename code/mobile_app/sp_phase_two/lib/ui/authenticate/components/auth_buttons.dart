import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/sign_in/bloc.dart';
import '../../../blocs/register/bloc.dart';

import '../register.dart';

class AuthButtons {
  AuthButtons._();

  static Widget registerSubmit({VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 12.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Text('Submit', style: TextStyle(fontSize: 16.0)),
        onPressed: onPressed,
      ),
    );
  }

  static Widget loginSubmit({VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 12.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Text('Login', style: TextStyle(fontSize: 14)),
        onPressed: onPressed,
      ),
    );
  }

  static Widget registerButton(BuildContext origContext) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 12.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text('Create an Account', style: TextStyle(fontSize: 14)),
        color: Colors.green,
        onPressed: () => _registerPressed(origContext),
      ),
    );
  }

  static void _registerPressed(BuildContext origContext) {
    Navigator.push(
      origContext,
      MaterialPageRoute(builder: (origContext) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('Register'),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(origContext),
            ),
          ),
          body: BlocProvider<RegisterBloc>(
            create: (origContext) => RegisterBloc(),
            child: Register(),
          ),
        );
      }),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: RaisedButton.icon(
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        icon: Icon(Icons.people, color: Colors.white),
        label:
            Text('Sign in with Google', style: TextStyle(color: Colors.white)),
        color: Colors.redAccent,
        onPressed: () {
          BlocProvider.of<SignInBloc>(context).add(SignInWithGooglePressed());
        },
      ),
    );
  }
}

class Guest extends StatelessWidget {
  const Guest();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: RaisedButton.icon(
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        icon: Icon(Icons.people, color: Colors.white),
        label: Text('Sign in as Guest', style: TextStyle(color: Colors.white)),
        color: Colors.redAccent,
        onPressed: () => BlocProvider.of<SignInBloc>(context).add(SignInWithGuest()),
      ),
    );
  }
}