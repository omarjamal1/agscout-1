import 'dart:async';
import 'dart:convert';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/data_models/cropTypeDatabaseHelper.dart';
import 'package:agscoutapp/functions/new_plot_function.dart';
import 'package:agscoutapp/screens/plot_listing_screen.dart';
import 'package:agscoutapp/services/crop-type-offline-service.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/constants.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class NewPlot extends StatefulWidget {
  final farmId;
  NewPlot({this.farmId});

  static const String routeName = 'new_plot_screen';
  @override
  _NewPlotState createState() => _NewPlotState();
}

class _NewPlotState extends State<NewPlot> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var value;
  String dropdownShowText = 'Seleccionar tipo de cultivo';
  bool isExpanded = false;
  bool showSpinner = false;
  String name, variety, area, centroDeCosto, typeOfCrop, plantsPerHectare;
  dynamic _currentCropType;

//  For connectivity checking
  bool isOffline = false;
  var connectionStatus = 'Unknown';

  Future createPlot() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        showSpinner = true;
      });
      var response = await API.createNewPlot(
        widget.farmId,
        name,
        variety,
        area,
        centroDeCosto,
        plantsPerHectare,
        _currentCropType.toString(),
      );

      if (response.statusCode == 201) {
        setState(() {
          showSpinner = false;
        });
        var plotId = jsonDecode(response.body)['data']['id'];
        setPlotIdToSF(plotId.toString());
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PlotListing(
                      farmId: widget.farmId,
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

  Future<List<CropType>> getCropTypeList() async {
    var response = await CropTypeAPI.cropTypes();
    if (response.statusCode == 200) {
      final items = json.decode(response.body)['data'];
      List<CropType> listOfCropTypes = items.map<CropType>((json) {
        return CropType.fromJson(json);
      }).toList();

      return listOfCropTypes;
    } else {
      throw Exception('No se pudo cargar, no hay Internet');
    }
  }

  getDataFromCropTypeLocalDB() async {
    var c = await DatabaseHelper.instance.queryCropTypeAll();
    print(">>> Inside of plot for crop type list $c");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Load Crop type to db on navigating to this page.
//    CropTypeOfflineService().getCropTypeList();
    getDataFromCropTypeLocalDB();
    getCropTypeList();
  }

//  @override
//  void dispose() {
//    // TODO: implement dispose
//    subscription.cancel();
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Agregar nueva cuartel'),
        height: 50,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'images/new_plot.png',
                        height: 100,
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
                        decoration: kTextFieldInputDecoration.copyWith(
                            hintText: 'Nombre de la cuartel'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Ingrese el nombre de la cuartel';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          name = value;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 30.0,
                        left: 50,
                        right: 50,
                        bottom: 10,
                      ),
                      child: Container(
                        width: 270,
                        child: FutureBuilder<List<CropType>>(
                            future: getCropTypeList(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<CropType>> snapshot) {
                              if (!snapshot.hasData)
                                return Text('Cargando tipo Scout ...');
                              return DropdownButton<CropType>(
                                items: snapshot.data
                                    .map((cropTypeData) =>
                                        DropdownMenuItem<CropType>(
                                          child: Container(
                                            width: 240,
                                            child: Text(cropTypeData.cropType),
                                          ),
                                          value: cropTypeData,
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _currentCropType = value.id;
                                    dropdownShowText = value.cropType;
//                                    print(_currentCropType);
                                  });
                                },
                                isExpanded: false,
                                //value: _currentUser,
                                hint: Text('$dropdownShowText'),
                              );
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50.0,
                        right: 50.0,
                        top: 0,
                        bottom: 0,
                      ),
                      child: TextFormField(
                        decoration: kTextFieldInputDecoration.copyWith(
                            hintText: 'Variedad'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Agrega la variedad de cultivo';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          variety = value;
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
                            hintText: 'Superficie (ha)'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Proporcionar un Superficie';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          area = value;
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
                            hintText: 'Centro de costo'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Proporcionar centro de costo';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          centroDeCosto = value;
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
                            hintText: 'Plantas por hectárea (ha)'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Proporcionar un Superficie';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          plantsPerHectare = value;
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
                        buttonText: 'Agregar nueva cuartel',
                        borderSide: BorderSide(color: Colors.green),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          createPlot();
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
