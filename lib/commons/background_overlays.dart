import 'package:flutter/material.dart';

class BackgroundOverlays extends StatelessWidget {
  BackgroundOverlays({@required this.imageURL});
  final imageURL;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          imageURL,
          width: double.maxFinite,
          height: double.maxFinite,
          fit: BoxFit.fill,
        ),
        Container(
          color: Color.fromRGBO(0, 107, 43, 0.9),
        )
      ],
    );
  }
}
