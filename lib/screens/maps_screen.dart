import 'dart:convert';
import 'package:agscoutapp/functions/crop_scout_map_coordinates_function.dart';
import 'package:agscoutapp/functions/crop_search_on_map_function.dart';
import 'package:agscoutapp/functions/get_current_location_function.dart';
import 'package:agscoutapp/functions/plot_listing_function.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

const kActiveCardColor = Color(0xFF1D133);
const kInactiveCardColor = Color(0xFF111328);

class ViewMap extends StatefulWidget {
  static const String routeName = 'map_screen';
  @override
  _ViewMapState createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  bool isSelected = false;
  String selectedScoutTypeChoice = '';
  String scoutTypeValue;
  List myMarkers = [];
  bool showSpinner = false;
  List cropScoutList;
  List searchList;
  String year;
  double lat = -33.4224049;
  double lon = -70.5794799;
  BitmapDescriptor pinLocationIcon;
  GoogleMapController mapController;
  List recordedScoutTypes;
  var _controller = TextEditingController();

  Future _filterScoutOnMap(year, scoutType) async {
    setState(() {
      showSpinner = true;
    });
    var orgId = await getOrganizationIDFromSF();
    var response =
        await CropSearchOnMapAPI.cropSearchOnMapData(orgId, year, scoutType);
    searchList = json.decode(response.body)['data'];

    try {
      if (searchList.length == 0) {
        setState(() {
          showSpinner = false;
        });

        displayDialog(context, 'Alert',
            'No se encontraron registros para $scoutTypeValue  en $year');
      }
      if (searchList != null) {
        showSpinner = false;
        setState(() {
          lat = double.parse(searchList.first['lat']);
          lon = double.parse(searchList.first['lon']);
        });
        searchList.forEach((element) {
          myMarkers.add(
            Marker(
              markerId: MarkerId(
                'MarkerId${element['id']}',
              ),
              infoWindow: InfoWindow(
                title:
                    'Conteo: ${element['type_of_scout']} ${element['number_of_counts']}',
                snippet:
                    'Conteo: ${element['type_of_scout']}/ha ${element['plants_per_hectare']}',
              ),
              icon: pinLocationIcon,
              draggable: false,
              position: LatLng(
                double.parse(element['lat']),
                double.parse(
                  element['lon'],
                ),
              ),
              onTap: () {
                setState(() {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(double.parse(element['lat']),
                            double.parse(element['lon'])),
                        zoom: 19.0,
                        tilt: 50.0,
                        bearing: 45.0,
                      ),
                    ),
                  );
                });
              },
            ),
          );
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lon),
                zoom: 19.0,
                tilt: 50.0,
                bearing: 45.0,
              ),
            ),
          );
        });
      }
    } catch (error) {
      print('$error');
    }
    return searchList;
  }

  Future _chipChoiceSearchScoutOnMap(scoutType) async {
    setState(() {
      showSpinner = true;
    });
    var orgId = await getOrganizationIDFromSF();
    var response = await ChipChoiceCropSearchOnMapAPI.cropSearchOnMapData(
        orgId, scoutType);
    searchList = json.decode(response.body)['data'];

    try {
      if (searchList.length == 0) {
        setState(() {
          showSpinner = false;
        });

        displayDialog(context, 'Alert', 'No records found for $year');
//        showSpinner = false;
      }
      if (searchList != null) {
        showSpinner = false;
        setState(() {
          lat = double.parse(searchList.first['lat']);
          lon = double.parse(searchList.first['lon']);
        });
        searchList.forEach((element) {
          myMarkers.add(
            Marker(
              markerId: MarkerId(
                'MarkerId${element['id']}',
              ),
              infoWindow: InfoWindow(
                title:
                    'Conteo: ${element['type_of_scout']} ${element['number_of_counts']}',
                snippet:
                    'Conteo: ${element['type_of_scout']}/ha ${element['plants_per_hectare']}',
              ),
              icon: pinLocationIcon,
              draggable: false,
              position: LatLng(
                double.parse(element['lat']),
                double.parse(
                  element['lon'],
                ),
              ),
              onTap: () {
                setState(() {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(double.parse(element['lat']),
                            double.parse(element['lon'])),
                        zoom: 19.0,
                        tilt: 50.0,
                        bearing: 45.0,
                      ),
                    ),
                  );
                });
              },
            ),
          );
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lon),
                zoom: 19.0,
                tilt: 50.0,
                bearing: 45.0,
              ),
            ),
          );
        });
      }
    } catch (error) {
      print('$error');
    }
    return searchList;
  }

  Future<List<ScoutTypeCollectedList>> _scoutTypesRecorded() async {
    var orgId = await getOrganizationIDFromSF();
    final response =
        await ScoutTypeCollectedListFromAPI.scoutTypeCollectedList(orgId);
    if (response.statusCode == 200) {
      recordedScoutTypes = json.decode(response.body)['scout_types'];
      return recordedScoutTypes
          .map((job) => new ScoutTypeCollectedList.fromJson(job))
          .toList();
    } else {
      throw Exception('Failed to load scout types from API');
    }
  }

  Future _getCropScoutMapCoordinates() async {
    var orgId = await getOrganizationIDFromSF();
    var response =
        await CropScoutMapCoordinatesAPI.cropScoutMapCoordinates(orgId);
    cropScoutList = json.decode(response.body)['data'];
    try {
      if (cropScoutList != null) {
        setState(() {
          lat = double.parse(cropScoutList.first['lat']);
          lon = double.parse(cropScoutList.first['lon']);
        });
        cropScoutList.forEach((element) {
          myMarkers.add(
            Marker(
              markerId: MarkerId(
                'MarkerId${element['id']}',
              ),
              infoWindow: InfoWindow(
                title:
                    'Conteo: ${element['type_of_scout']} ${element['number_of_counts']}',
                snippet:
                    'Conteo: ${element['type_of_scout']}/ha ${element['plants_per_hectare']}',
              ),
              icon: pinLocationIcon,
              draggable: false,
              position: LatLng(
                double.parse(element['lat']),
                double.parse(
                  element['lon'],
                ),
              ),
              onTap: () {
                setState(() {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(double.parse(element['lat']),
                            double.parse(element['lon'])),
                        zoom: 19.0,
                        tilt: 50.0,
                        bearing: 45.0,
                      ),
                    ),
                  );
                });
              },
            ),
          );
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lon),
                zoom: 19.0,
                tilt: 50.0,
                bearing: 45.0,
              ),
            ),
          );
        });
      } else {
        var position = await getCurrentLocation();
        setState(() {
          lat = position.latitude;
          lon = position.longitude;
          myMarkers.add(
            Marker(
              markerId: MarkerId(
                'markerId$lat',
              ),
              position: LatLng(lat, lon),
            ),
          );
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lon),
                zoom: 18.0,
                tilt: 50.0,
                bearing: 45.0,
              ),
            ),
          );
        });
        displayDialog(context, 'Alert',
            'Sin perfil. Únase a la organización o cree una.');
      }
    } catch (error) {
      print('$error');
    }
    return cropScoutList;
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/crop_marker.png');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCropScoutMapCoordinates();
    setCustomMapPin();
    _scoutTypesRecorded();
    selectedScoutTypeChoice = "";
    scoutTypeValue = '';

    recordedScoutTypes = List<dynamic>();
  }

  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lon),
                    zoom: 10.0,
                  ),
                  mapType: MapType.hybrid,
                  markers: Set.from(myMarkers),
                ),
                Container(
                  height: 120.0,
                  child: ListView.builder(
                      padding: EdgeInsets.only(left: 10.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: recordedScoutTypes.length == null
                          ? "Loading"
                          : recordedScoutTypes.length,
//                    itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 70.0,
                            left: 15.0,
                            bottom: 10,
                          ),
                          child: ChoiceChip(
                            selected: selectedScoutTypeChoice ==
                                recordedScoutTypes[index]
                                    ['type_of_scout__scout_type'],
                            label: Text(
                                '${recordedScoutTypes[index]['type_of_scout__scout_type']} (${recordedScoutTypes[index]['dcount']}) '),
                            labelStyle: TextStyle(color: Colors.black54),
                            avatar: Icon(
                              Icons.radio_button_checked,
                              color: Colors.white,
                              size: 12,
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: Colors.green,
                            onSelected: (bool selected) {
                              _chipChoiceSearchScoutOnMap(
                                  recordedScoutTypes[index]
                                      ['type_of_scout__scout_type']);
                              setState(() {
                                isSelected = selected;
                                if (selected) {
                                  selectedScoutTypeChoice =
                                      recordedScoutTypes[index]
                                          ['type_of_scout__scout_type'];
                                  scoutTypeValue = selectedScoutTypeChoice;
                                } else {
                                  isSelected = false;
                                  selectedScoutTypeChoice = '';
                                  scoutTypeValue = 'selectedScoutTypeChoice';
                                }
                              });
                            },
                          ),
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                        borderSide: BorderSide(width: 0.8, color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(width: 1, color: Colors.green),
                      ),
                      focusColor: Colors.green,
                      hintText: 'Search for scouts by year',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                        borderSide: BorderSide(
                          width: 0.8,
                          color: Colors.green,
                        ),
                      ),
                      prefixIcon: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.green,
                        ),
                        onPressed: () =>
                            _filterScoutOnMap(year, scoutTypeValue),
                      ),
                      suffixIcon: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.green,
                          ),
                          onPressed: () => {
                                _controller.clear(),
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode())
                              }),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (value) {
                      year = value;
                    },
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      year = value;
                      _filterScoutOnMap(year, scoutTypeValue);
                    },
                  ),
                ),
//            SizedBox(
//              height: 40,
//            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
