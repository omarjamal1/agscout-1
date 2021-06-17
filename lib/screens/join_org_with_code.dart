import 'dart:convert';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/join_organization_function.dart';
import 'package:agscoutapp/screens/farms_listing_screen.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'bottom_navigator_entry.dart';

class JoinOrganizationWithCode extends StatefulWidget {
  static const String routeName = 'join_org_with_code';

  @override
  _JoinOrganizationWithCodeState createState() =>
      _JoinOrganizationWithCodeState();
}

class _JoinOrganizationWithCodeState extends State<JoinOrganizationWithCode> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String organizationCode;
  bool showSpinner = false;

  Future _joinOrganizationWithCode() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        showSpinner = true;
      });
      var response =
          await API.joinOrganizationWithCodeFunction(organizationCode);
      try {
        if (response.statusCode == 200) {
          setState(() {
            showSpinner = false;
          });

          var orgResponseID =
              json.decode(response.body)['data']['organization']['id'];
          print(orgResponseID.toString());
          setOrganizationIDToSF(orgResponseID.toString());
          // Save data to internal Database after result
          int org = await DatabaseHelper.instance.insert({
            DatabaseHelper.orgId: json.decode(response.body)['data']
                ['organization']['id'],
            DatabaseHelper.orgName: json.decode(response.body)['data']
                ['organization']['name'],
            DatabaseHelper.location: json.decode(response.body)['data']
                ['organization']['location'],
            DatabaseHelper.email: json.decode(response.body)['data']
                ['organization']['email'],
            DatabaseHelper.organizationCode: json.decode(response.body)['data']
                ['organization']['join_org_code'],
            DatabaseHelper.address: json.decode(response.body)['data']
                ['organization']['current_address'],
            DatabaseHelper.logo: json.decode(response.body)['data']
                ['organization']['organization_logo'],
            DatabaseHelper.user: json.decode(response.body)['data']
                ['organization']['user'],
            DatabaseHelper.createdDate: json.decode(response.body)['data']
                ['organization']['created_date']
          });

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BottomNavigatorEntry()));
        } else {
          setState(() {
            showSpinner = false;
          });
          var data = json.decode(response.body)['message'];
          displayDialog(context, 'Alert', '$data');
        }
      } catch (e) {
//          var data = jsonDecode(e.);
//          displayDialog('$e');
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Unirse a una organización',
        ),
        height: 50,
      ),
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Container(
            child: SingleChildScrollView(
              child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 80.0),
                    child: Image.asset(
                      'images/join_organization.png',
                      height: 100,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    'Solicite el código de la empresa al administrador de su organización.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 200,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Codigo de compañia",
                            fillColor: Colors.green,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),
//                    borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          onChanged: (value) {
                            organizationCode = value;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Container(
                    width: 350,
                    height: 50,
                    child: AccountButtons(
//                      backgroundColor: Colors.white,
                      textColor: Color.fromRGBO(0, 107, 43, 10),
                      buttonText: 'Unirse',
                      borderSide: BorderSide(color: Colors.green),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _joinOrganizationWithCode();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
