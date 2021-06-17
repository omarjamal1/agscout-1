import 'dart:convert';

import 'package:agscoutapp/functions/api_urls.dart';
import 'package:agscoutapp/screens/new_plot_screen.dart';
import 'package:agscoutapp/services/farm-offline-service.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/utilities/sharedPreference.dart';

var serverUrl = Endpoints.serverUrl;
var url = '$serverUrl/api/v1.0/farm/create/';

class AddNewFarm extends StatefulWidget {
  static const String routeName = 'new_farm';
  @override
  _AddNewFarmState createState() => _AddNewFarmState();
}

class _AddNewFarmState extends State<AddNewFarm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final farmNameTextField = TextEditingController();
  final locationTextField = TextEditingController();
  clearTextInput() {
    farmNameTextField.clear();
    locationTextField.clear();
  }

//  String organizationId;
  String farmName;
  bool showSpinner = false;
  String location;

  void addNewFarmFunction(farmName, location) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        showSpinner = true;
      });
      var token = await getAuthToken();
//      print
      var orgID = await getOrganizationIDFromSF();
      var userId = await getLoggedInUserFromSF();
//      var farm = FarmOfflineService().addNewFarmToLocalDBAndQueueTable(
//          orgID, farmName, location, userId, DateTime.now().toString());
//      print("Code passed here to create >>>>>> $farm");
      Map<String, String> requestHeaders = {
        'Authorization': 'Token $token',
//        'Content-Type': 'application/json'
      };
      var response = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'organization': orgID,
          'name': farmName,
          'location': location,
        },
      );
      if (response.statusCode == 201) {
        setState(() {
          showSpinner = false;
        });
        var farmId = jsonDecode(response.body)['data']['id'];
        await setFarmIDToSF(farmId.toString());

//        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => NewPlot(
                      farmId: farmId.toString(),
                    )));
      } else {
        setState(() {
          showSpinner = false;
        });
        var data = jsonDecode(response.body)['message'];
        displayDialog(context, 'Alert', '$data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Add your farm'),
        height: 50,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'images/farm.png',
                        height: 150,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50.0,
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
                        controller: farmNameTextField,
                        decoration: kTextFieldInputDecoration.copyWith(
                            hintText: 'Nombre de la Campo'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Ingrese el nombre de la Campo';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          farmName = value;
                        },
                      ),
                    ),
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
                        controller: locationTextField,
                        decoration: kTextFieldInputDecoration.copyWith(
                            hintText: 'Ubicación'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Proporcionar una ubicación';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          location = value;
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
                        buttonText: 'Agregar nueva campo',
                        borderSide: BorderSide(color: Colors.green),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          addNewFarmFunction(farmName, location);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
//      bottomNavigationBar: MyBottomNavigator(),
    );
  }
}
