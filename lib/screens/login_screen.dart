import 'dart:convert';
import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/screens/bottom_navigator_entry.dart';
import 'package:agscoutapp/screens/new_organization.dart';
import 'package:agscoutapp/screens/select_new_org_or_existing_org.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
//import 'package:commons/commons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:agscoutapp/utilities/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;
var url = '$serverUrl/api/v1.0/user/login/';

class Login extends StatefulWidget {
  static const String routeName = 'login_screen';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String phoneNumber;
  String password;
  bool showSpinner = false;
  String token = '';
  String tokenValue;
  String countryCode;
  final countryCodeController = TextEditingController(text: "+56");
//  void displayDialog(message) {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) => CupertinoAlertDialog(
//        title: Text("Alert"),
//        content: Text(message),
//        actions: [
//          CupertinoDialogAction(
//            isDefaultAction: true,
//            child: new Text(
//              "Close",
//            ),
//            onPressed: () {
//              Navigator.of(context).pop();
//            },
//          )
//        ],
//      ),
//    );
//  }

  void loginFunction(countryCode, phoneNumber, password) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        showSpinner = true;
      });

      var response = await http.post(url, body: {
        'phone_number': '$countryCode$phoneNumber',
        'password': password
      });
      if (response.statusCode == 200) {
        setState(() {
          showSpinner = false;
        });
        var loggedInUserId = jsonDecode(response.body)['data']['id'];
        setLoggedInUserIDToSF(loggedInUserId.toString());
        token = jsonDecode(response.body)['data']['auth_token'];
        setAuthTokenToSF(token);
        var employeeProfile = jsonDecode(response.body)['data']['employees'];
        if (employeeProfile == null) {
          Navigator.pushReplacementNamed(
              context, SelectNewOrgOrOldOrg.routeName);
          return;
        }
        var orgId = employeeProfile['organization']['id'];
        setOrganizationIDToSF(orgId.toString());
//         Update the local storage here when user logs in.
        int updatedId = await DatabaseHelper.instance.insert({
          DatabaseHelper.orgId: employeeProfile['organization']['id'],
          DatabaseHelper.orgName: employeeProfile['organization']['name'],
          DatabaseHelper.location: employeeProfile['organization']['location'],
          DatabaseHelper.email: employeeProfile['organization']['email'],
          DatabaseHelper.organizationCode: employeeProfile['organization']
              ['join_org_code'],
          DatabaseHelper.address: employeeProfile['organization']
              ['current_address'],
          DatabaseHelper.logo: employeeProfile['organization']
              ['organization_logo'],
          DatabaseHelper.user: employeeProfile['organization']['user'],
          DatabaseHelper.createdDate: employeeProfile['organization']
              ['created_date']
        });

        Navigator.pushReplacementNamed(context, BottomNavigatorEntry.routeName);
      } else {
        setState(() {
          showSpinner = false;
        });

        var data = jsonDecode(response.body)['message'];

        displayDialog(context, 'Alert', '$data');
//        errorDialog(context, "$data");
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countryCode = countryCodeController.text;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                Navigator.pop(context);
                              })
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 150,
                    ),
                    Column(
                      children: <Widget>[
                        Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'images/ag-viewer-logo.png',
                            height: 100,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 100,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 50.0,
                                  right: 10.0,
                                  top: 20,
                                  bottom: 0,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
//                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  decoration: kTextFieldInputDecoration
                                      .copyWith(hintText: 'Código'),
                                  controller: countryCodeController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Ingrese su código';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    countryCode = value;
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 0.0,
                                  right: 50.0,
                                  top: 20,
                                  bottom: 0,
                                ),
                                child: Container(
                                  width: 200,
                                  margin: EdgeInsets.only(left: 0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                    decoration:
                                        kTextFieldInputDecoration.copyWith(
                                            hintText:
                                                'Ingrese su número telefónico'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Ingrese su número telefónico';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      phoneNumber = value;
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 50.0,
                                right: 50.0,
                                top: 20,
                                bottom: 0,
                              ),
                              child: TextFormField(
                                obscureText: true,
                                decoration: kTextFieldInputDecoration.copyWith(
                                    hintText: 'Ingresa tu contraseña'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'La contraseña no puede estar vacía';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  password = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 5),
                                  child: GestureDetector(
                                    child: Text(
                                      'Olvidó tu contraseña ?',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    onTap: () {
                                      print('forgot pass');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              width: 260,
                              height: 50,
                              child: AccountButtons(
//                      backgroundColor: Colors.white,
                                textColor: Color.fromRGBO(0, 107, 43, 10),
                                buttonText: 'Iniciar sesión',
                                borderSide: BorderSide(color: Colors.green),
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  loginFunction(
                                      countryCode, phoneNumber, password);
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
