import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/authentication/bloc.dart';
import '../../blocs/sign_in/bloc.dart';

/// Issues
/// 1. Not yet refactored

class HomeProfile extends StatefulWidget {
  //final AnimationController animationController;

  const HomeProfile({Key key}) : super(key: key);

  @override
  _HomeProfileState createState() => _HomeProfileState();
}

class _HomeProfileState extends State<HomeProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              //fit: FlexFit.loose,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _logoutButton(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _logoutButton() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              color: Colors.red.withOpacity(0.8),
              child: Text(
                'Log Out',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              onPressed: () => BlocProvider.of<SignInBloc>(context).add(SignOut()),
            ),
          );
        }

        return Container();
      },
    );
  }
}
