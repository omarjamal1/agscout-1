//import 'dart:html';
import 'dart:io';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/api_urls.dart';
import 'package:agscoutapp/screens/new_farm_screen.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:agscoutapp/utilities/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';

import 'bottom_navigator_entry.dart';

var serverUrl = Endpoints.serverUrl;
Dio dio = new Dio();

var url = '$serverUrl/api/v1.0/org-profile/create/';

class NewOrganization extends StatefulWidget {
  static const String routeName = 'new_organization_profile';

  @override
  _NewOrganizationState createState() => _NewOrganizationState();
}

class _NewOrganizationState extends State<NewOrganization> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _image;
  final picker = ImagePicker();
  String profileImage;
  String organizationName;
  String location;
  String email;
  String address;
  bool showSpinner = false;

  // Create a new organization profile
  void newOrganizationFunction(
      organizationName, location, address, email) async {
    String filename = "";
    FormData formData = new FormData();
    if (_formKey.currentState.validate()) {
      setState(() {
        showSpinner = true;
      });
      var token = await getAuthToken();
      Map<String, String> requestHeaders = {
        'Authorization': 'Token $token',
        'Content-Type': 'multipart/form-data'
      };

      try {
        if (_image != null) {
          filename = _image.path.split('/').last;
        }

        formData = FormData.fromMap({
          'name': organizationName,
          'location': location,
          'current_address': address,
          'email': email,
          'organization_logo': _image != null
              ? await MultipartFile.fromFile(_image.path, filename: filename)
              : null,
        });
        Response response = await dio.post(
          url,
          data: formData,
          options: Options(
              headers: requestHeaders, contentType: 'multipart/form-data'),
        );

        if (response.statusCode == 201) {
          setState(() {
            showSpinner = false;
          });
          var orgResponseID = response.data['data']['id'];
          setOrganizationIDToSF(orgResponseID.toString());
          // Save data to internal Database after result
          int org = await DatabaseHelper.instance.insert({
            DatabaseHelper.orgId: response.data['data']['id'],
            DatabaseHelper.orgName: response.data['data']['name'],
            DatabaseHelper.location: response.data['data']['location'],
            DatabaseHelper.email: response.data['data']['email'],
            DatabaseHelper.organizationCode: response.data['data']
                ['join_org_code'],
            DatabaseHelper.address: response.data['data']['current_address'],
            DatabaseHelper.logo: response.data['data']['organization_logo'],
            DatabaseHelper.user: response.data['data']['user'],
            DatabaseHelper.createdDate: response.data['data']['created_date']
          });
          Navigator.pushReplacementNamed(
              context, BottomNavigatorEntry.routeName);
        } else {
          setState(() {
            showSpinner = false;
          });
          var data = response.data;
          displayDialog(context, 'Alert', '$data');
        }
      } catch (e) {
        displayDialog(context, 'Alert', e);
        print(e);
      }
    }
  }

  Future<void> getImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_image == null) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Nueva organización'),
        height: 50,
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 150.0,
                            width: 150.0,
                            child: GestureDetector(
                              child: ClipOval(
                                child: _image == null
                                    ? Image.asset('images/new_org_profile.png')
                                    : Image.file(_image),
                              ),
                              onTap: () {
                                getImage();
                              },
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              margin: EdgeInsets.only(top: 130, left: 140),
                              child: Icon(
                                Icons.add_a_photo,
                                size: 30,
                                color: Colors.green,
                              ),
                            ),
                            onTap: () {
                              getImage();
                            },
                          ),
                        ],
                      )),
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
                          decoration: kTextFieldInputDecoration.copyWith(
                              hintText: 'Nombre de la Organización'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingrese el nombre de la organización';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            organizationName = value;
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
                          keyboardType: TextInputType.emailAddress,
                          decoration: kTextFieldInputDecoration.copyWith(
                              hintText:
                                  'Correo electrónico de la organización'),
                          onChanged: (value) {
                            email = value;
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
                          decoration: kTextFieldInputDecoration.copyWith(
                              hintText: 'Dirección'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Dirección de la organización.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            address = value;
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
                        width: 350,
                        height: 50,
                        child: AccountButtons(
//                      backgroundColor: Colors.white,
                          textColor: Color.fromRGBO(0, 107, 43, 10),
                          buttonText: 'Crear organización',
                          borderSide: BorderSide(color: Colors.green),
                          onPressed: () {
                            newOrganizationFunction(
                                organizationName, location, address, email);
                          },
                        ),
                      ),
                    ],
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
