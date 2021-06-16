import 'package:flutter/material.dart';

import '../../app_theme.dart';

// TODO : Finalize design

/// General utility widget used to render a cell divided into three rows
/// First row displays [label]
/// second row displays [iconData]
/// third row displays [value]
class ValueTile extends StatelessWidget {
  final String label, value, unit;
  final IconData iconData;

  ValueTile(this.label, this.value, this.unit, {this.iconData});

  @override
  Widget build(BuildContext context) {
    // String currLabel = label.replaceAll(' ', '');
    //
    // print(currLabel);
    List<String> _timeSplit = (label.split(' '));
    //print(_timeSplit);
    // List<String> _timeSplit = [_strSplit[1].substring(0, 2), _strSplit[1].substring(2, 4)];
    int _hr = int.parse(_timeSplit[3]);
    double _period = (_hr / 6);
    int _op = _hr % 6;
    if (_op == 0) _op = 6;

    Color shadowColor;
    List<Color> gradientColor;

    //print(unit);
    //
    // print(_timeSplit[3]);
    // print('hr: ' + _hr.toString());

    //0,36,90 - 0,24,42
    //8,112,160 - 230, 238, 142 //8,112,160 - 255, 235, 61 //8,112,160 - 230, // 238, 142

    //155 165 255 - 250 178 15

    //255, 172, 112 - 243, 136, 106
    //90, 42, 131 - 0, 36, 89

    if (_period <= 1) {
      Color _start = Color.fromRGBO(0, 36 - ((_op - 1) * 2), 90 - ((_op - 1) * 8), 1);
      Color _end = Color.fromRGBO(0, 36 - (_op * 2), 90 - (_op * 8), 1);
      gradientColor = [_start, _end];
      shadowColor = _start;
    } else if (_period <= 2) {
      Color _start = Color.fromRGBO(148 + ((_op - 1) * 17), 166 + ((_op - 1) * 2), 255 - ((_op - 1) * 40), 1);
      Color _end = Color.fromRGBO(148 + (_op * 17), 166 + (_op * 2), 255 - (_op * 40), 1);
      // print(_start);
      // print(_end);
      gradientColor = [_start, _end];
      shadowColor = _start;
    } else if (_period <= 3) {
      Color _start = Color.fromRGBO(255 - ((_op - 1) * 2), 172 - ((_op - 1) * 6), 112 - ((_op - 1) * 1), 1);
      Color _end = Color.fromRGBO(255 - (_op * 2), 172 - (_op * 6), 112 - (_op * 1), 1);
      gradientColor = [_start, _end];
      shadowColor = _start;
    } else if (_period <= 4) {
      Color _start = Color.fromRGBO(90 - ((_op - 1) * 15), 42 - ((_op - 1) * 1), 131 - ((_op - 1) * 7), 1);
      Color _end = Color.fromRGBO(90 - (_op * 15), 42 - (_op * 1), 131 - (_op * 7), 1);
      gradientColor = [_start, _end];
      shadowColor = _start;
    }

    return SizedBox(
      width: 130,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: shadowColor.withOpacity(0.6),
                    // color: HexColor(mealsListData.endColor).withOpacity(0.6),
                    offset: const Offset(1.1, 4.0),
                    blurRadius: 8.0,
                  ),
                ],
                gradient: LinearGradient(
                  // colors: <HexColor>[
                  //   HexColor(mealsListData.startColor),
                  //   HexColor(mealsListData.endColor),
                  // ],
                  colors: gradientColor,
                  //colors: [Colors.lightBlue[200], Colors.lightBlue[300]],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(54.0),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(
                    top: 80, left: 16, right: 16, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _timeSplit[0],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.2,
                        color: AppTheme.white,
                      ),
                    ),
                    Text(
                      _timeSplit[1] + _timeSplit[2],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.2,
                        color: AppTheme.white,
                      ),
                    ),
                    // Expanded(
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(top: 8, bottom: 8),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: <Widget>[
                    //         Text(
                    //           mealsListData.meals.join('\n'),
                    //           style: TextStyle(
                    //             fontFamily: AppTheme.fontName,
                    //             fontWeight: FontWeight.w500,
                    //             fontSize: 10,
                    //             letterSpacing: 0.2,
                    //             color: AppTheme.white,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                            letterSpacing: 0.2,
                            color: AppTheme.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 4, bottom: 3),
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              letterSpacing: 0.2,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 0,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppTheme.nearlyWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: <Widget>[
    //     Text(this.label),
    //     SizedBox(height: 5.0),
    //     this.iconData != null
    //         ? Icon(
    //             iconData,
    //             color: Theme.of(context).accentColor,
    //             size: 20,
    //           )
    //         : Container(),
    //     SizedBox(height: 10.0),
    //     Text(this.value),
    //   ],
    // );
  }
}
