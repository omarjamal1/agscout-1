import 'dart:convert';

import 'package:agscoutapp/functions/invite_employee_function.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
//import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

String phoneNumber;
bool isSent;
Future inviteEmployee(BuildContext context, phoneNumber) async {
  var response = await InviteEmployeeAPI.inviteEmployeeFunction(phoneNumber);
  var responseMess = json.decode(response.body)['message'];

  if (response.statusCode == 200) {
    isSent = true;
  } else {
    isSent = false;
  }

  return responseMess;
}

void showEmployeeInviteInput(context) {
  if (Platform.isIOS) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("Invite employee"),
        content: Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Phone number",
                ),
                onChanged: (value) {
                  phoneNumber = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "Invite",
            ),
            onPressed: () {
              Navigator.of(context).pop();
              inviteEmployee(context, phoneNumber);
//              _successDialogue(context, 'Invite sent to $phoneNumber');
              if (isSent) {
//                successDialog(context, "Invite sent to $phoneNumber");
                displayDialog(context, "Alert", "Invite sent to $phoneNumber");
              } else {
//                errorDialog(context, "No se pudo enviar la invitación.");
                displayDialog(
                    context, "Alert", "No se pudo enviar la invitación.");
              }
            },
          ),
        ],
      ),
    );
  } else {
    // For Android
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite employee'),
        content: TextField(
          decoration: InputDecoration(
            labelText: "Phone number",
//                filled: true,
//                fillColor: Colors.grey.shade50,
          ),
          onChanged: (value) {
            phoneNumber = value;
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Invite'),
            onPressed: () {
              Navigator.of(context).pop();
              inviteEmployee(context, phoneNumber);
            },
          ),
        ],
      ),
    );
  }
}
