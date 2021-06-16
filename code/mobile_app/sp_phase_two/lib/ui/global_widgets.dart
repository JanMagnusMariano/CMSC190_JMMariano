import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';

// TODO: Create another overlay for errors besides network connectivity

//void loadingOverlay(BuildContext context) {
//  showDialog(
//    barrierDismissible: false,
//    context: context,
//    builder: (BuildContext subContext) {
//      return Container(
//        child: SpinKitThreeBounce(
//          itemBuilder: (BuildContext context, int index) {
//            return DecoratedBox(
//              decoration: BoxDecoration(
//                shape: BoxShape.circle,
//                color: index.isEven ? Colors.blue : Colors.green,
//              ),
//            );
//          },
//        ),
//      );
//    },
//  );
//}

void noConnectionOverlay(BuildContext context, {Function whenRetry, whenOffline}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text('No network connection detected\nSwitch to offline mode?'),
        actions: <Widget>[
          FlatButton(
            child: Text('Retry'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              whenRetry();
            },
          ),
          FlatButton(
            child: Text('Switch to offline mode'),
            onPressed: () {
              //Navigator.of(context).pop('dialog');
              whenOffline();
              // Might change
            },
          ),
        ],
      );
    },
  );
}

void failureOverlay(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext subContext) {
      return Dialog(
        backgroundColor: Colors.white,
        child: Container(width: 200, height: 200, child: Text('')),
      );
    },
  );
//  showDialog(
//    context: context,
//    barrierDismissible: false,
//    builder: (BuildContext subContext) {
//      return AlertDialog(
//        content: Text('No network connection detected\nSwitch to offline mode?'),
//        actions: <Widget>[
//          FlatButton(
//            child: Text('Retry'),
//            onPressed: () {
//              Navigator.of(context).pop();
//              //whenRetry.call();
//            },
//          ),
//          FlatButton(
//            child: Text('Switch to offline mode'),
//            onPressed: () {
//              Navigator.of(context).pop();
//            },
//          ),
//        ],
//      );
//    },
//  );
//  showDialog(
//    context: context,
//    barrierDismissible: false,
//    builder: (BuildContext subContext) {
//      return AlertDialog(
//        content:
//            Text('No network connection detected.\nSwitch to offline mode?'),
//        actions: <Widget>[
//          FlatButton(
//            child: Text('Retry'),
//            onPressed: () {
//              //_onFormSubmitted();
//              Navigator.of(context).pop();
////                setState(() {
////                  Navigator.of(context).pop();
////                  _onFormSubmitted();
////                });
//            },
//          ),
//          FlatButton(
//            child: Text('Switch to Offline mode'),
//            onPressed: () {
//              Navigator.of(context).pop();
//              BlocProvider.of<SignInBloc>(context).add(
//                SignInWithGuest(),
//              );
//            },
//          ),
//        ],
//      );
}
//
//void onlineSnackbar(BuildContext context, bool isOnline) {
//  const onlineNotice = SnackBar(
//    content: Text("Back online"),
//    duration: Duration(milliseconds: 750),
//  );
//
//  Scaffold.of(context).hideCurrentSnackBar();
//  Scaffold.of(context).showSnackBar(onlineNotice);
//  Scaffold.of(context).hideCurrentSnackBar();
//}

class GlobalWidgets {
  GlobalWidgets._();

  static onlineSnackbar(BuildContext context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Back online'),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  static offlineSnackbar(BuildContext context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Currently offline'),
        duration: Duration(days: 1),
      ),
    );
  }

  static loadingOverlay(BuildContext context) {
    if (Get.isDialogOpen) {
      print('Tried to open dialog');
      return;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext subContext) {
        return SpinKitThreeBounce(
          itemBuilder: (BuildContext context, int index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index.isEven ? Colors.blue : Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  // Utility functions

  static bool isScreenLarge(double width, double pixel) {
    return width * pixel >= 1440;
  }

  static bool isScreenMedium(double width, double pixel) {
    return width * pixel < 1440 && width * pixel >=1080;
  }

  static bool isScreenSmall(double width, double pixel) {
    return width * pixel <= 720;
  }
}
