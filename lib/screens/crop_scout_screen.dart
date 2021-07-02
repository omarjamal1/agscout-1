import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/crop_scout_function.dart';
import 'package:agscoutapp/functions/plot_listing_function.dart';
import 'package:agscoutapp/screens/scout_list_screen.dart';
import 'package:agscoutapp/services/scout-offline-service.dart';
import 'package:agscoutapp/services/scout-type-offline-service.dart';
import 'package:agscoutapp/utilities/check-internet-connection.dart';
import 'package:agscoutapp/utilities/constants.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:agscoutapp/utilities/widgets.dart';
//import 'package:commons/commons.dart' as alertBox;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:location/location.dart' as LocationPackage;
//import 'package:gps/gps.dart';
//import 'package:path/path.dart' as Path;

class CropScout extends StatefulWidget {
  final String plotId;

  CropScout({this.plotId});

  static const String routeName = 'crop_scouting';
  @override
  _CropScoutState createState() => _CropScoutState();
}

class _CropScoutState extends State<CropScout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Completer<GoogleMapController> _controller = Completer();

  String dropdownShowText = 'Seleccione el tipo de Conteo';
  List data;
//  var value;
  File _image; //Image.file(File('images/new_org_profile.png'));
  final picker = ImagePicker();
  File savedImage;
  bool showSpinner = false;
  dynamic _currentScoutType;

  String plot,
      rowNumber = "0",
      plantNumber = "0",
      numberOfLaterals = "0",
      numberOfBranches = "0",
      countNumber = "0",
      cropImage = '';
  double lat = -33.0705;
  double lon = -70.1079;

  var accuracy = 0.0;
  bool cameraOption = false;
  List myMarkers = [];
  var mapAccuracy = 0.0;
  var gpsLocationData;
//  Geo geoLocator;
//  LocationOptions locationOptions;
  List<ScoutType> listOfScoutTypes;
  Position position;
  String base64Image;
  var scoutCount;
  List offlineScoutType = [];

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void showMapAccuracyDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          if (Theme.of(context).platform == TargetPlatform.iOS) {
            return new CupertinoAlertDialog(
              title: new Text("Precisión del mapa"),
              content: new Text(
                  "El nivel de precisión del mapa es ${mapAccuracy.toStringAsFixed(2)} m. Por favor refresca ubicación"),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: new Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                    }),
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: new Text("Continuar"),
                    onPressed: () {
                      addNewCropScout();
                      Navigator.pop(context, 'Cancel');
                    })
              ],
            );
          } else {
            return AlertDialog(
              title: new Text("Precisión del mapa"),
              content: new Text(
                  "El nivel de precisión del mapa es  ${mapAccuracy.toStringAsFixed(2)} m. Por favor refresca ubicación"),
              actions: <Widget>[
                RaisedButton(
                  child: new Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  },
                ),
                RaisedButton(
                  child: new Text(
                    "Continuar",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    addNewCropScout();
                    Navigator.pop(context, 'Cancel');
                  },
                ),
              ],
            );
          }
        });
  }

  Future<void> getCropScoutCurrentLocation() async {
    GoogleMapController mapController = await _controller.future;
    myMarkers.clear();

    try {
      position = await getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );

      lat = position.latitude;
      lon = position.longitude;
      mapAccuracy = position.accuracy;

      setState(() {
        accuracy = position.accuracy;
        myMarkers.add(
          Marker(
            markerId: MarkerId(
              'Id:$lat$lon',
            ),
            draggable: false,
            position: LatLng(
              double.parse(position.latitude.toString()),
              double.parse(
                position.longitude.toString(),
              ),
            ),
          ),
        );
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 19.0,
              tilt: 45.0,
              bearing: 90.0,
            ),
          ),
        );
      });
    } catch (e) {
      print(e);
    }
    return position;
  }

  void showCameraOptions() {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
                title: Text('Cosecha imagen'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text('Cargar imagen'),
                    onPressed: () {
                      cameraOption = false;
                      Navigator.of(context).pop();
                      uploadImageOptions();
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: Text('Toma una foto.'),
                    onPressed: () {
                      cameraOption = true;
                      Navigator.of(context).pop();
                      uploadImageOptions();
                    },
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('Cerca'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ));
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Opciones de cámara'),
          content: Container(
            height: 70,
            margin: EdgeInsets.only(
              right: 70,
            ),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Text(
                      'Imagen de la galería',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  onTap: () {
                    cameraOption = false;
                    Navigator.of(context).pop();
                    uploadImageOptions();
                  },
                ),
                Divider(),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Text(
                      'Captura de cámara',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  onTap: () {
                    cameraOption = true;
                    Navigator.of(context).pop();
                    uploadImageOptions();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cerca'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  var plotDetail;
  Future plotDetailFunction() async {
    plotDetail = await DatabaseHelper.instance
        .queryOnePlotById(int.parse(widget.plotId));
//    setState(() {});
//    print("plot >>>>>> Details $plotDetail");
    return plotDetail;
//    print(widget.plotId.runtimeType);
//    print(widget.plotId);
  }

//  Future<List<ScoutType>> getScoutTypeList() async {
//    var response = await ScoutTypeAPI.scoutTypes();
//    if (response.statusCode == 200) {
//      final items = json.decode(response.body)['data'];
////      var items = await DatabaseHelper.instance.queryScoutTypeAll();
//      print(">>>>> Items from api $items");
//      List<ScoutType> listOfScoutTypes = items.map<ScoutType>((json) {
//        return ScoutType.fromJson(json);
//      }).toList();
////      listOfScoutTypes.forEach((element) {
////        print(element.scoutType);
////      });
//      return listOfScoutTypes;
//    } else {
//      throw Exception('No se pudo cargar, no hay Internet');
//    }
//  }

  getScoutTypeListsFromDB() async {
    var offlineScoutType = await DatabaseHelper.instance.queryScoutTypeAll();
    this.offlineScoutType = offlineScoutType.map<ScoutType>((json) {
      return ScoutType.fromJson(json);
    }).toList();
    setState(() {});
  }

  void addNewCropScout() async {
    if (_formKey.currentState.validate()) {
      String filename = "";
      setState(() {
        showSpinner = true;
      });
      try {
        if (_image != null) {
//          final appDir = awaot sysp
//          final appDir = await syspaths.getApplicationDocumentsDirectory();
          filename = _image.path.split('/').last;
          final imageBytes = _image.readAsBytesSync();
          print("Location of the file >>>>>>>>>> $filename");
          base64Image = base64Encode(imageBytes);
          final appDir = await getApplicationDocumentsDirectory();
          savedImage = await _image.copy('${appDir.path}/$filename');
          setState(() {
            savedImage = savedImage;
          });

          print(">>>>>>>>>>>> savedImage $savedImage");
        }

        ///          Original upload to api
//        var response = await NewCropScoutAPI.createNewCropScout(
//            widget.plotId,
//            _currentScoutType,
//            rowNumber,
//            plantNumber,
//            numberOfLaterals,
//            numberOfBranches,
//            countNumber,
//            _image != null
//                ? await MultipartFile.fromFile(_image.path, filename: filename)
//                : null,
//            lat,
//            lon,
//            accuracy,
//            DateTime.now().toUtc());

//        if (response.data['status'] == 201) {
//         Add the collected data to local db and Queue table
        var response =
            await ScoutOfflineService().addNewScoutToLocalDBAndQueueTable(
          widget.plotId,
          _currentScoutType,
          rowNumber,
          plantNumber,
          numberOfLaterals,
          numberOfBranches,
          countNumber,
//          base64Image,
//          _image.toString(),
          savedImage != null ? savedImage.path : null,
//          _image != null
//              ? await MultipartFile.fromFile(_image.path, filename: filename)
//              : null,
          lat,
          lon,
          accuracy.toStringAsFixed(2),
          DateTime.now().toUtc().toString(),
        );
        setState(() {
          showSpinner = false;
        });
        print(">>>>>>>>>>>>>> Scout type $_currentScoutType");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return ScoutListScreen(
              plotId: widget.plotId,
            );
          }),
        );
//          var data = response.data['message'];
        displayDialog(context, 'Alert', 'Data added successfully.');
//          alertBox.successDialog(context, "$data");
//          Navigator.pushReplacement(
//            context,
//            MaterialPageRoute(builder: (context) {
//              return ScoutListScreen(
//                plotId: widget.plotId,
//              );
//            }),
//          );
//        } else {
//          setState(() {
//            showSpinner = false;
//          });
//          var data = response.data['message'];
//          displayDialog(context, 'Alert', '$data');
//        }
      } catch (e) {
        print(e);
      }
//      }
    }
//      else {
//      displayDialog(context, 'Alert', ' Map accuracy is $mapAccuracy');
//    }
  }

  Future<void> uploadImageOptions() async {
    var pickedFile;
    cameraOption
        ? pickedFile = await picker.getImage(source: ImageSource.camera)
        : pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
      if (_image == null) return;

//      print(">>>>>>>>>> Uploaded image $_image");
    });
  }

  getCropScoutCountFromAPIToSF() async {
    var hasInternet = await checkInternetConnection();
    if (hasInternet == true) {
      var response = await PlotDetailAPI.plotDetail(widget.plotId);
      if (response.statusCode == 200) {
        var plotDetail = json.decode(response.body)['data'];
        await setScoutCountToSF(plotDetail['crop_scout_count']);
      } else {
        await setScoutCountToSF("0");
      }
    }
    scoutCount = await getScoutsCountFromSF();
  }

  loadScoutDataOfflineService() async {
    var saveLocalDataFromAPI = ScoutOfflineService();
    await saveLocalDataFromAPI.getScoutDataFromLocalDB(widget.plotId);
  }

  // Call this function to upload data to the server on app start

  uploadScoutDataFromQueueService() async {
//    try {
    var uploadData = ScoutOfflineService();
    await uploadData.uploadScoutQueueDataToAPI();
//    } catch (e) {
//      print(e);
//    }
  }

  @override
  void initState() {
    super.initState();
    getCropScoutCurrentLocation();
//    this.getScoutTypeList();
    this.plotDetailFunction();
    getCropScoutCountFromAPIToSF();
    getScoutTypeListsFromDB();
    loadScoutDataOfflineService();
    // uploadScoutDataFromQueueService();

    // Call scout type list offline function.
//    loadScoutTypeOfflineService();

//    this.getLocationGps();

    if (_image == null) return;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text('Conteo de cultivos'),
          height: 50,
        ),
        body: Column(
          children: <Widget>[
            plotDetail == null
                ? CircularProgressIndicator()
                : FutureBuilder(
                    future: plotDetailFunction(), // async work
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return CardSkeleton(
                            style: SkeletonStyle(
                              theme: SkeletonTheme.Light,
                              isShowAvatar: true,
                              isCircleAvatar: false,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                              padding: EdgeInsets.all(32.0),
                              barCount: 2,
                              isAnimation: false,
                            ),
                          );
                        case ConnectionState.waiting:
                          return // card skeleton
                              Center(
                            child: CardSkeleton(
                              style: SkeletonStyle(
                                theme: SkeletonTheme.Light,
                                isShowAvatar: true,
                                isCircleAvatar: false,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                                padding: EdgeInsets.all(32.0),
                                barCount: 2,
                                isAnimation: false,
                              ),
                            ),
                          );
                        default:
//                          if (snapshot.hasError)
//                            return Center(
//                                child: Text('Error: ${snapshot.error}'));

                          return Container(
                            height: 180,
                            child: Card(
                              elevation: 5,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 30),
                                        child: ClipOval(
                                          child: Image.asset(
                                            'images/plot_icon.png',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0.0, top: 30),
                                            child: Container(
                                              width: 260,
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          'Nombre: ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            snapshot.data[0]
                                                                    ['plotName']
                                                                .toString(),
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          'Tipo de cultivo: ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          snapshot.data[0][
                                                                      'plotCropType'] ==
                                                                  null
                                                              ? "No disponible"
                                                              : snapshot.data[0]
                                                                  [
                                                                  'plotCropType'],
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          'Variedad: ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            snapshot.data[0]
                                                                ['variety'],
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          'Superficie (ha): ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${snapshot.data[0]['area'].toString()}',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          'Plantas (ha): ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          snapshot.data[0][
                                                                  'plantPerHectare']
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(left: 80, top: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Numero de conteos: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '$scoutCount.',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '${scoutCount != "0" ? 'vertodo' : ''}'
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return ScoutListScreen(
                                            plotId: widget.plotId,
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                      }
                    },
                  ),
            Expanded(
              child: ModalProgressHUD(
                inAsyncCall: showSpinner,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  child: Container(
                                    height: 70.0,
                                    width: 70.0,
                                    color: Colors.grey[200],
                                    child: _image == null
                                        ? Image.asset(
                                            'images/new_org_profile.png')
                                        : Image.file(_image),
                                  ),
                                  onTap: () {
                                    showCameraOptions();
                                  },
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  'Upload crop image',
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 50.0,
                                  right: 50.0,
                                  top: 10,
                                  bottom: 0,
                                ),
                                child: Container(
                                  width: 270,
                                  child: offlineScoutType.length == 0
                                      ? Text('Cargando tipo Scout ...')
                                      : DropdownButton<ScoutType>(
                                          items: offlineScoutType
                                              .map((scoutTypeData) =>
                                                  DropdownMenuItem<ScoutType>(
                                                    child: Container(
                                                      width: 240,
                                                      child: Text(scoutTypeData
                                                          .scoutType
                                                          .toString()),
                                                    ),
                                                    value: scoutTypeData,
                                                  ))
                                              .toList(),

                                          onChanged: (value) {
                                            setState(() {
                                              _currentScoutType = value.id;
                                              dropdownShowText =
                                                  value.scoutType;
//                                              print(
//                                                  "Scout tyype 22>>>>> $_currentScoutType");
                                            });
                                            if (_currentScoutType == null)
                                              displayDialog(context, "Alert",
                                                  "Seleccione un tipo de explorador.");
                                          },
//                                      value: _currentScoutType,
//                                      validator: (value) => value == null? 'Please fill in your gender' : null,
                                          isExpanded: false,
                                          //value: _currentUser,
                                          hint: Text('$dropdownShowText'),
                                        ),
//                                  FutureBuilder<List<ScoutType>>(
//                                          future: getScoutTypeListsFromDB(),
//                                          builder: (BuildContext context,
//                                              AsyncSnapshot<List<ScoutType>>
//                                                  snapshot) {
//                                            if (!snapshot.hasData)
//                                              return Text(
//                                                  'Cargando tipo Scout ...');
//                                            return
//
//
//
//                                          }),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                width: 210,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 50.0,
                                    right: 50.0,
                                    top: 0,
                                    bottom: 0,
                                  ),
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                    decoration: kTextFieldInputDecoration
                                        .copyWith(hintText: 'Fila Número'),
                                    onChanged: (value) {
                                      rowNumber = value;
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                width: 140,
                                child: Padding(
                                  padding: const EdgeInsets.only(
//                            left: 50.0,
                                    right: 30.0,
                                    top: 0,
                                    bottom: 0,
                                  ),
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                    decoration: kTextFieldInputDecoration
                                        .copyWith(hintText: 'Planta Núme..'),
                                    onChanged: (value) {
                                      plantNumber = value;
                                    },
                                  ),
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
                                  top: 10,
                                  bottom: 0,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  decoration:
                                      kTextFieldInputDecoration.copyWith(
                                    hintText: 'Número de laterales',
                                  ),
                                  onChanged: (value) {
                                    numberOfLaterals = value;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 50.0,
                                  right: 50.0,
                                  top: 10,
                                  bottom: 0,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  decoration: kTextFieldInputDecoration
                                      .copyWith(hintText: 'Número de Ramas'),
                                  onChanged: (value) {
                                    numberOfBranches = value;
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
                                  top: 10,
                                  bottom: 0,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  decoration: kTextFieldInputDecoration
                                      .copyWith(hintText: 'Número de conteo'),
                                  onChanged: (value) {
                                    countNumber = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50.0, right: 50),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${mapAccuracy.toStringAsFixed(2)} m',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.refresh,
                                        size: 40,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        getCropScoutCurrentLocation();
                                        setState(() {
                                          accuracy = mapAccuracy;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 270,
                            height: 200,
                            child: Stack(
                              children: <Widget>[
                                GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(lat, lon),
                                    zoom: 13.0,
                                  ),
                                  myLocationButtonEnabled: true,
                                  myLocationEnabled: true,
                                  markers: Set.from(myMarkers),
                                  mapType: MapType.satellite,
//                                        mapToolbarEnabled: true,
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 30.0,
                              ),
                              Container(
                                width: 260,
                                height: 50,
                                child: AccountButtons(
//                      backgroundColor: Colors.white,
                                  textColor: Color.fromRGBO(0, 107, 43, 10),
                                  buttonText: 'Agregar datos',
                                  borderSide: BorderSide(color: Colors.green),
                                  onPressed: () {
                                    if (mapAccuracy > 8) {
                                      displayDialog(context, 'Alert',
                                          'Por favor refresca ubicación');
                                    } else if (mapAccuracy > 5.00) {
                                      showMapAccuracyDialog();
                                    } else {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      addNewCropScout();
                                    }
                                    if (_currentScoutType == null)
                                      displayDialog(context, "Alert",
                                          "Seleccione un tipo de explorador");
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
              ),
            ),
          ],
        ),
//      bottomNavigationBar: MyBottomNavigator(),
      ),
    );
  }
}
