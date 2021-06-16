import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ReportPost extends StatelessWidget {

  final imagePath, content, name, time, likes, comments, shares;

  ReportPost({
    this.imagePath, this.content, this.name, this.time, this.likes, this.comments, this.shares
  });

  @override
  Widget build(BuildContext context) {
    print('img: ' + imagePath);

    return new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: this.imagePath,
            //imageUrl: "http://192.168.1.7:3001/weather/images/?path=" + this.imagePath,
//            imageBuilder: (context, imageProvider) => FadeInImage(
//              image: imageProvider,
//              width: MediaQuery.of(context).size.width,
//            ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          // Container(
          //   padding: EdgeInsets.symmetric(vertical : 30),
          //   child: ListTile(
          //     title: Text(content),
          //   ),
          // ),

//          Container(
//            padding: new EdgeInsets.all(18.0),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                new Row(
//                  children: <Widget>[
//
//                    new CircleAvatar(
//                      radius: 10.0,
//                      backgroundColor: Color(0xff3b5998),
//                      child: new Icon(Icons.thumb_up, size: 12.0, color: Colors.white, ), ),
//
//                    new CircleAvatar(
//                      radius: 10.0,
//                      backgroundColor: Colors.red,
//                      child: new Icon(IconData(0xe9da, fontFamily: 'icomoon'), size: 12.0, color: Colors.white, ), ),
//
//                    new Padding(
//                      padding: const EdgeInsets.symmetric(
//                          vertical: 0.0,
//                          horizontal: 8.0
//                      ),
//                      child: new Text(likes),
//                    ),
//                  ],
//                ),
//                new Text(comments + " comments · " + shares + " share"),
//              ],
//            ),
//          )
        ],
      ),
    );
  }
}
