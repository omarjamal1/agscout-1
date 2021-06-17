//import 'dart:html';

import 'dart:convert';
//import 'dart:html';
import 'dart:io';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/api_urls.dart';
import 'package:agscoutapp/functions/organization_function.dart';
import 'package:agscoutapp/screens/farms_listing_screen.dart';
import 'package:agscoutapp/utilities/constants.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image_picker/image_picker.dart';

import 'bottom_navigator_entry.dart';

var serverUrl = Endpoints.serverUrl;

class EditOrganizationProfile extends StatefulWidget {
  static const String routeName = 'edit_organization_profile';
  @override
  _EditOrganizationProfileState createState() =>
      _EditOrganizationProfileState();
}

class _EditOrganizationProfileState extends State<EditOrganizationProfile> {
  bool showSpinner = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _image;

  final picker = ImagePicker();
  String profileImage;
  String organizationName;
  String location;
  String email;
  String address;
  var logo;
  TextEditingController currentOrganizationName = TextEditingController();
  TextEditingController currentLocation = TextEditingController();
  TextEditingController currentEmail = TextEditingController();
  TextEditingController currentAddress = TextEditingController();
  var currentImage;
  var backupImageIfNotUploaded;

  _getOrganizationProfile() async {
    var response = await GetOrganizationProfileAPI.getOrganizationProfile();
    try {
      if (response.statusCode == 200) {
        response = json.decode(response.body);
        print(response['data']);
        setState(() {
          currentOrganizationName.text = response['data']['name'];
          currentLocation.text = response['data']['location'];
          currentEmail.text = response['data']['email'];
          currentAddress.text = response['data']['current_address'];
          currentImage = response['data']['organization_logo'];
          backupImageIfNotUploaded = response['data']['organization_logo'];
        });

        print(currentOrganizationName.text);
//        print(currentImage);
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateOrganizationProfile() async {
    String filename = "";

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        showSpinner = true;
      });
      try {
        if (_image != null) {
          filename = _image.path.split('/').last;
        }
        var response =
            await UpdateOrganizationProfileAPI.updateOrganizationProfile(
          organizationName,
          location,
          address,
          email,
          _image != null
              ? await MultipartFile.fromFile(_image.path, filename: filename)
              : null,
        );

        if (response.statusCode == 200) {
          setState(() {
            showSpinner = false;
          });

//          setOrganizationIDToSF(response.data['data']['id']);
//          // Update organization profile data to internal Database after result
          int updatedId = await DatabaseHelper.instance.update({
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

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListOfFarmsView(),
            ),
          );
          displayDialog(context, 'Alert', '${response.data['message']}');
        } else {
          setState(() {
            showSpinner = false;
          });
          displayDialog(context, 'Alert', '${response.data['message']}');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> getImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
//      print(_image.toString());
      });
    } else {
      currentImage = backupImageIfNotUploaded;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOrganizationProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Organización Perfil'),
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
                                child: currentImage != null
                                    ? Image.network(
                                        currentImage,
                                        fit: BoxFit.cover,
                                      )
                                    : _image != null
                                        ? Image.file(_image)
                                        : Image.asset(
                                            'images/new_org_profile.png'),
                              ),
                              onTap: () {
                                setState(() {
                                  currentImage = null;
                                });
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
                              setState(() {
                                currentImage = null;
                              });
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
//                          initialValue: currentOrganizationName.text,
                          controller: currentOrganizationName,
                          decoration: kTextFieldInputDecoration.copyWith(
                              hintText: 'Nombre de la Organización'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingrese el nombre de la organización';
                            }
                            return null;
                          },
                          onSaved: (value) {
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
                          controller: currentLocation,
                          decoration: kTextFieldInputDecoration.copyWith(
                              hintText: 'Ubicación'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Proporcionar una ubicación';
                            }
                            return null;
                          },
                          onSaved: (value) {
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
                          controller: currentEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: kTextFieldInputDecoration.copyWith(
                              hintText:
                                  'Correo electrónico de la organización'),
                          onSaved: (value) {
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
                          controller: currentAddress,
                          decoration: kTextFieldInputDecoration.copyWith(
                              hintText: 'Dirección'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Dirección de la organización.';
                            }
                            return null;
                          },
                          onSaved: (value) {
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
                          buttonText: 'Editar Perfil',
                          borderSide: BorderSide(color: Colors.green),
                          onPressed: () {
                            _updateOrganizationProfile();
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
