import 'package:agscoutapp/screens/intro_screen.dart';
import 'package:agscoutapp/screens/invite_employee_screen.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:agscoutapp/screens/crop_scout_screen.dart';

String os = Platform.operatingSystem;

void displayDialog(context, title, message) {
  if (Platform.isIOS) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "Cerca",
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  } else {
    // For Android
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

void showInfoOption(context) {
  if (Platform.isIOS) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Ajustes'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text('Invitar empleado'),
            onPressed: () {
//                cameraOption = false;
              Navigator.of(context).pop();
              showEmployeeInviteInput(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Cerrar sesión'),
            onPressed: () {
              logoutFunction();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                // the new route
                MaterialPageRoute(
                  builder: (BuildContext context) => IntroScreen(),
                ),
                (Route route) => false,
              );
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cerca'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  } else if (Platform.isAndroid) {
    // Android
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajustes'),
        content: Container(
          height: 70,
          margin: EdgeInsets.only(
            right: 70,
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(right: 60.0),
                  child: Text(
                    'Invitar empleado',
                    textAlign: TextAlign.left,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  showEmployeeInviteInput(context);
                },
              ),
              Divider(),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(right: 90.0),
                  child: Text(
                    'Cerrar sesión',
                    textAlign: TextAlign.left,
                  ),
                ),
                onTap: () {
                  logoutFunction();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    // the new route
                    MaterialPageRoute(
                      builder: (BuildContext context) => IntroScreen(),
                    ),
                    (Route route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cerca'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Invitación'),
            onPressed: () {
              Navigator.of(context).pop();
              showEmployeeInviteInput(context);
            },
          ),
        ],
      ),
    );
  }
  //Android alert boxes
}
