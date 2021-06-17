import 'dart:convert';

import 'package:agscoutapp/functions/api_urls.dart';
import 'package:agscoutapp/screens/select_new_org_or_existing_org.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
//import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:agscoutapp/utilities/constants.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';

var serverUrl = Endpoints.serverUrl;
var url = '$serverUrl/api/v1.0/user/new/';

class SignUp extends StatefulWidget {
  static const String routeName = 'signup_screen';
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String fullName;
  String countryCode;
  String phoneNumber;
  String password;
  bool showSpinner = false;
  String token;
  final countryCodeController = TextEditingController(text: "+56");
  void userRegistration(fullName, countryCode, phoneNumber, password) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        showSpinner = true;
      });

      var response = await http.post(url, body: {
        'full_name': fullName,
        'phone_number': '$countryCode$phoneNumber',
        'password': password
      });
      if (response.statusCode == 201) {
        token = jsonDecode(response.body)['data']['auth_token'];
        setAuthTokenToSF(token);
        setState(() {
          showSpinner = false;
        });

        Navigator.pushReplacementNamed(context, SelectNewOrgOrOldOrg.routeName);
      } else {
        setState(() {
          showSpinner = false;
        });
        var data = jsonDecode(response.body)['phone_number'][0];
        displayDialog(context, 'Alert', '$data');
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
//      resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: ModalProgressHUD(
          inAsyncCall: showSpinner,
//        color: Colors.green,
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Hero(
                            tag: 'logo',
                            child: Image.asset(
                              'images/ag-viewer-logo.png',
                              height: 100,
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 50.0,
                                  right: 50.0,
                                  top: 0,
                                  bottom: 0,
                                ),
                                child: TextFormField(
                                  decoration:
                                      kTextFieldInputDecoration.copyWith(
                                          hintText:
                                              'Ingrese el nombre completo'),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Ingrese el nombre completo';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    fullName = value;
                                  },
                                ),
                              ),
                            ],
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
                                        WhitelistingTextInputFormatter
                                            .digitsOnly
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
                                  decoration:
                                      kTextFieldInputDecoration.copyWith(
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
                                  buttonText: 'Regístrate',
                                  borderSide: BorderSide(color: Colors.green),
                                  onPressed: () {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    userRegistration(fullName, countryCode,
                                        phoneNumber, password);
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
