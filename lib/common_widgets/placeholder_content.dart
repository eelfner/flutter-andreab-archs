import 'package:flutter/material.dart';

class PlaceHolderContent extends StatelessWidget {
  final String title;
  final String message;

  PlaceHolderContent({
    this.title: 'Nothing',
    this.message: 'Add the first item',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 32.0, color: Colors.black54), textAlign: TextAlign.center,),
          Text(message, style: TextStyle(fontSize: 16.0, color: Colors.black54), textAlign: TextAlign.center,),
        ],
      )
    );
  }
}