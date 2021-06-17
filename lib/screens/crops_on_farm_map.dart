import 'dart:async';
import 'dart:convert';
import 'package:agscoutapp/functions/crops_on_farm_map_function.dart';
import 'package:agscoutapp/functions/get_current_location_function.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluster/fluster.dart';

class CropsOnFarmMapView extends StatefulWidget {
  final farmId;
  CropsOnFarmMapView({this.farmId});
  static const String routeName = 'view_crops_on_farm_map_screen';
  @override
  _CropsOnFarmMapViewState createState() => _CropsOnFarmMapViewState();
}

class _CropsOnFarmMapViewState extends State<CropsOnFarmMapView> {
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController mapController;
  List myMarkers = [];
  List cropScoutList;
  double lat = -33.4224049;
  double lon = -70.5794799;
  BitmapDescriptor pinLocationIcon;
  List cropsScoutOnFarmMarkers;

  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _cropsOnFarmMapCoordinates() async {
    var response = await CropsOnFarmMapCoordinatesAPI.cropsOnFarmMapCoordinates(
        widget.farmId);
    cropsScoutOnFarmMarkers = json.decode(response.body)['data'];
    if (cropsScoutOnFarmMarkers.length != 0) {
      setState(() {
        lat = double.parse(cropsScoutOnFarmMarkers.first['lat']);
        lon = double.parse(cropsScoutOnFarmMarkers.first['lon']);
      });
      cropsScoutOnFarmMarkers.forEach((element) {
        myMarkers.add(
          Marker(
            markerId: MarkerId('${element['id']}'),
            icon: pinLocationIcon,
            infoWindow: InfoWindow(
              title:
                  'Conteo: ${element['type_of_scout']} ${element['number_of_counts']}',
              snippet:
                  'Conteo: ${element['type_of_scout']}/ha ${element['number_of_counts'] * element['plants_per_hectare']}',
            ),
            onTap: () {
              setState(() {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(double.parse(element['lat']),
                          double.parse(element['lon'])),
                      zoom: 18.0,
                      tilt: 50.0,
                      bearing: 45.0,
                    ),
                  ),
                );
              });
            },
            position: LatLng(
              double.parse(element['lat']),
              double.parse(
                element['lon'],
              ),
            ),
          ),
        );
        setState(() {
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
      });
    } else {
      var position = await getCurrentLocation();
      setState(() {
        lat = position.latitude;
        lon = position.longitude;
        myMarkers.add(
          Marker(
            markerId: MarkerId('markerId$lat'),
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
    }
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
//  Future<void> _updateMarkers([double updatedZoom]) async {
//    if (_clusterManager == null || updatedZoom == _currentZoom) return;
//
//    if (updatedZoom != null) {
//      _currentZoom = updatedZoom;
//    }
//
//    setState(() {
//      _areMarkersLoading = true;
//    });
//
//    final updatedMarkers = await MapHelper.getClusterMarkers(
//      _clusterManager,
//      _currentZoom,
//      _clusterColor,
//      _clusterTextColor,
//      80,
//    );
//
//    _markers
//      ..clear()
//      ..addAll(updatedMarkers);
//
//    setState(() {
//      _areMarkersLoading = false;
//    });
//  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/crop_marker.png');
  }

  @override
  void initState() {
    setCustomMapPin();
    _cropsOnFarmMapCoordinates();

    super.initState();
  }

  dispose() {
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Cultivos en la granja'),
        height: 50,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lon),
              zoom: 15.0,
            ),
            mapType: MapType.hybrid,
            markers: Set.from(myMarkers),
          ),
        ],
      ),
    );
  }
}
