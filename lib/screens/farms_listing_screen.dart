import 'dart:ui';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/date_convert_function.dart';
import 'package:agscoutapp/functions/farms_listing_function.dart';
import 'package:agscoutapp/screens/crops_on_farm_map.dart';
import 'package:agscoutapp/screens/data_summary_chart.dart';
import 'package:agscoutapp/screens/edit-profile-screen.dart';
import 'package:agscoutapp/screens/farm_level_data_summary.dart';
import 'package:agscoutapp/screens/new_farm_screen.dart';
import 'package:agscoutapp/screens/plot_listing_screen.dart';
import 'package:agscoutapp/services/farm-offline-service.dart';
import 'package:agscoutapp/services/scout-type-offline-service.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'dart:convert';
import 'package:flutter_offline/flutter_offline.dart';

import 'package:intl/intl.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'invite_employee_screen.dart';

class ListOfFarmsView extends StatefulWidget {
  static const String routeName = 'list_of_farms';
  @override
  _ListOfFarmsViewState createState() => _ListOfFarmsViewState();
}

class _ListOfFarmsViewState extends State<ListOfFarmsView> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List farms = [];
  bool isLoading = true;
  var orgId;
  List orgProfile;
  bool _isContainerVisible = true;

  _getFarmsList(bool firstInstance) async {
    orgId = await getOrganizationIDFromSF();
    farms = await DatabaseHelper.instance.queryFarmAll();
    isLoading = firstInstance;
    setState(() {});
  }

  getFarmId(index) {
    var id = farms[index]['_farmId'];
    return id;
  }

  getFarmName(index) {
    var name = farms[index]['farmName'];
    return name;
  }

  Future<List<Map<String, dynamic>>> _getOrgProfileData() async {
    var orgId = await getOrganizationIDFromSF();

    orgProfile = await DatabaseHelper.instance.queryOne(int.parse(orgId));
    return orgProfile;
  }

  // Call function from offline class
  getDataFarmFromLocalDB() async {
    setState(() {
      isLoading = true;
    });
    var c = FarmOfflineService();
    await c.getFarmFromLocalDB();
    _getFarmsList(false);
  }

  loadScoutTypeOfflineService() async {
    var c = ScoutTypeOfflineService();
    await c.getScoutTypeList();
  }

  initState() {
    super.initState();
    orgProfile = List<dynamic>();
    dbHelper = DatabaseHelper.instance;
    _getFarmsList(true);
    _getOrgProfileData();
    getDataFarmFromLocalDB();
    loadScoutTypeOfflineService();
    // Hide / show container if internet is on or off
    Future.delayed(const Duration(seconds: 3), () {
      //asynchronous delay
      if (this.mounted) {
        //checks if widget is still active and not disposed
        setState(() {
          //tells the widget builder to rebuild again because ui has updated
          _isContainerVisible =
              false; //update the variable declare this under your class so its accessible for both your widget build and initState which is located under widget build{}
        });
      }
    });
  }

  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _getOrgProfileData();
    final maxWidth = MediaQuery.of(context).size.width * 0.4;
    return new Scaffold(
      appBar: CustomAppBar(
        title: Text('Tus Campos'),
        height: 50,
      ),
      drawer: Drawer(
        child: ListView(
// Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                  image: AssetImage("images/background_image.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder(
                    future: _getOrgProfileData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              EdgeInsets.only(top: 0, left: 5),
                                          child: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.centerLeft,
//
                                              ),
                                              ClipOval(
                                                child: CircleAvatar(
                                                  child: snapshot.data[0]
                                                              ['logo'] !=
                                                          null
                                                      ? Image.network(
                                                          snapshot.data[0]
                                                              ['logo'],
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image(
                                                          image: AssetImage(
                                                              'images/new_org_profile.png'),
                                                        ),
                                                  backgroundColor: Colors.white,
                                                  maxRadius: 35,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                snapshot.data[0]['name'],
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                snapshot.data[0]['location'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                snapshot.data[0]
                                                    ['organizationCode'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Server Error: ${snapshot.error}"));
                        } else if (snapshot.data == null) {
                          return Center(
                              child: Text(
                                  "No profile data, Check internet connection."));
                        }
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person_add,
                color: Colors.green,
              ),
              title: Text('Invitar empleados'),
              onTap: () {
                showEmployeeInviteInput(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.edit,
                color: Colors.green,
              ),
              title: Text('Editar perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditOrganizationProfile(),
                  ),
                );
//
              },
            ),
            ListTile(
              leading: Icon(
                Icons.vpn_key,
                color: Colors.green,
              ),
              title: Text('Cambia la contraseña'),
              onTap: () {
// Update the state of the app.
// ..
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.green,
              ),
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                showInfoOption(context);
              },
            ),
          ],
        ),
      ),
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
//
          return new Stack(
            fit: StackFit.expand,
            children: [
              (isLoading && farms.length == 0)
                  ? Center(child: CircularProgressIndicator())
                  : (!isLoading && farms.length == 0)
                      ? Center(
                          child: Text('Sin contenido'),
                        )
                      : ListView.builder(
                          itemCount: farms == null ? 0 : farms.length,
                          itemBuilder: (context, index) {
//          return ListTile(title: Text(data[index].name));
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 600) {
// Small screen
                                  return Container(
                                    height: 120,
                                    child: GestureDetector(
                                      child: Card(
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10.0),
                                              child: ClipOval(
                                                child: Image(
                                                  width: 50,
                                                  height: 50,
                                                  image: AssetImage(
                                                    'images/farms.png',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 15.0,
//                                        vertical: 15.0
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Container(
                                                        child: Text(
                                                          'Nombre: ${farms[index]['farmName']}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 30),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.location_on,
                                                            color: Colors.green,
                                                          ),
                                                          Flexible(
                                                            child: Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      maxWidth:
                                                                          maxWidth),
                                                              child: Text(
                                                                '${farms[index]['farmLocation']}',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.map,
                                                          size: 12,
                                                          color: Colors.green,
                                                        ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        GestureDetector(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 0),
                                                            child: Text(
                                                              ' Ver en el mapa',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CropsOnFarmMapView(
                                                                  farmId: farms[
                                                                          index]
                                                                      [
                                                                      '_farmId'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Icon(
                                                          Icons.data_usage,
                                                          size: 12,
                                                          color: Colors.green,
                                                        ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        GestureDetector(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 0),
                                                            child: Text(
                                                              ' Data summary',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        FarmDataSummary(
                                                                  farmId: farms[
                                                                          index]
                                                                      [
                                                                      '_farmId'],
                                                                  farmName: farms[
                                                                          index]
                                                                      [
                                                                      'farmName'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0),
                                                          child: Text(
                                                            'Fecha: ${convertDateTimeDisplay(farms[index]['farmCreatedDate'])}',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.arrow_forward_ios,
                                              ),
                                              iconSize: 30.0,
                                              color: Colors.grey,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                    return PlotListing(
                                                      farmId: getFarmId(index),
                                                      farmName: farms[index]
                                                          ['farmName'],
                                                    );
                                                  }),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return PlotListing(
                                              farmId: getFarmId(index),
                                              farmName: farms[index]
                                                  ['farmName'],
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  // Bigger screens
                                  return Container(
                                    height: 100,
                                    child: GestureDetector(
                                      child: Card(
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10.0),
                                              child: ClipOval(
                                                child: Image(
                                                  width: 50,
                                                  height: 50,
                                                  image: AssetImage(
                                                    'images/farms.png',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 15.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Container(
                                                        child: Text(
                                                          'Nombre: ${farms[index]['farmName']}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 30),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.location_on,
                                                            color: Colors.green,
                                                          ),
                                                          Flexible(
                                                            child: Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      maxWidth:
                                                                          maxWidth),
                                                              child: Text(
                                                                '${farms[index]['farmLocation']}',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0),
                                                          child: Text(
                                                            'Fecha: ${convertDateTimeDisplay(farms[index]['farmCreatedDate'])}',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Icon(
                                                          Icons.location_on,
                                                          size: 12,
                                                          color: Colors.green,
                                                        ),
                                                        GestureDetector(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 0),
                                                            child: Text(
                                                              ' view on map',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CropsOnFarmMapView(
                                                                  farmId: farms[
                                                                          index]
                                                                      [
                                                                      '_farmId'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.arrow_forward_ios,
                                              ),
                                              iconSize: 30.0,
                                              color: Colors.grey,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                    return PlotListing(
                                                      farmId: getFarmId(index),
                                                      farmName: farms[index]
                                                          ['farmName'],
                                                    );
                                                  }),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return PlotListing(
                                              farmId: farms[index]['_farmId'],
                                              farmName: farms[index]
                                                  ['farmName'],
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
//                  : FutureBuilder(
//                      future: _getFarmsList(),
//                      initialData: 'loading text...',
//                      builder: (context, AsyncSnapshot snapshot) {
//                        if (snapshot.connectionState == ConnectionState.done) {
//                          if (snapshot.hasData) {
//                            return
//                          } else if (snapshot.hasError) {
//                            return Center(child: Text('Snapshot has errors.'));
//                          } else if (snapshot.data == null) {
//                            return Center(
//                              child: Text(
//                                'Aún no se agregaron campos',
//                              ),
//                            );
//                          }
//                        } else if (snapshot.connectionState ==
//                            ConnectionState.waiting) {
//                          return Center(child: CircularProgressIndicator());
//                        }
//                        return Center(child: CircularProgressIndicator());
//                      },
//                    ),
              connected
                  ? Positioned(
                      height: 24.0,
                      left: 5.0,
                      right: 5.0,
                      top: 5.0,
                      child: Visibility(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 30,
                              width: 60,
                              decoration: new BoxDecoration(
                                  border: new Border.all(
//                                width: 30,
                                      color: Colors
                                          .transparent), //color is transparent so that it does not blend with the actual color specified
                                  borderRadius: const BorderRadius.all(
                                      const Radius.circular(30.0)),
                                  color: connected
                                      ? Color.fromRGBO(0, 107, 43, 0.5)
                                      : Color.fromRGBO(255, 0, 0,
                                          0.5) // Specifies the background color and the opacity
                                  ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 3.0,
                                ),
                                child: Text(
                                  "${'En Línea'}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: _isContainerVisible,
                      ),
                    )
                  : Positioned(
                      height: 24.0,
                      left: 5.0,
                      right: 5.0,
                      top: 5.0,
                      child: Visibility(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 30,
                              width: 100,
                              decoration: new BoxDecoration(
                                  border: new Border.all(
//                                width: 30,
                                      color: Colors
                                          .transparent), //color is transparent so that it does not blend with the actual color specified
                                  borderRadius: const BorderRadius.all(
                                      const Radius.circular(30.0)),
                                  color: connected
                                      ? Color.fromRGBO(0, 107, 43, 0.5)
                                      : Color.fromRGBO(255, 0, 0,
                                          0.5) // Specifies the background color and the opacity
                                  ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 3.0,
                                ),
                                child: Text(
                                  "${'Desconectado'}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: _isContainerVisible,
                      )),
//              Positioned(
//                height: 24.0,
//                left: 0.0,
//                right: 0.0,
//                child: Container(
//                  color: connected ? Color(0xFF00EE44) : Color(0xFFEE4400),
//                  child: Center(
////                      child: showToastMessage("Show Toast Message on Flutter")
//                    child: Text(
//                      "${connected ? 'ONLINE' : 'OFFLINE'}",
//                    ),
//                  ),
//                ),
//              ),
            ],
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'There are no bottons to push :)',
            ),
            new Text(
              'Just turn off your internet.',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddNewFarm()));
        },
      ),
    );
  }
}

//return Scaffold(
//appBar: CustomAppBar(
//title: Text('Tus Campos'),
//height: 50,
//),
//
////      body: FutureBuilder(
////        future: _getFarmsList(),
////        initialData: 'loading text...',
////        builder: (context, AsyncSnapshot snapshot) {
////          if (snapshot.connectionState == ConnectionState.done) {
////            if (snapshot.hasData) {
////              return ListView.builder(
////                itemCount: farms == null ? 0 : farms.length,
////                itemBuilder: (context, index) {
//////          return ListTile(title: Text(data[index].name));
////                  return LayoutBuilder(
////                    builder: (context, constraints) {
////                      if (constraints.maxWidth < 600) {
////                        // Small screen
////                        return Container(
////                          height: 120,
////                          child: GestureDetector(
////                            child: Card(
////                              child: Row(
////                                children: <Widget>[
////                                  Container(
////                                    margin:
////                                        EdgeInsets.symmetric(horizontal: 10.0),
////                                    child: ClipOval(
////                                      child: Image(
////                                        width: 50,
////                                        height: 50,
////                                        image: AssetImage(
////                                          'images/farms.png',
////                                        ),
////                                      ),
////                                    ),
////                                  ),
////                                  Expanded(
////                                    child: Container(
////                                      margin: EdgeInsets.symmetric(
////                                        horizontal: 15.0,
//////                                        vertical: 15.0
////                                      ),
////                                      child: Column(
////                                        crossAxisAlignment:
////                                            CrossAxisAlignment.start,
////                                        mainAxisAlignment:
////                                            MainAxisAlignment.center,
////                                        children: <Widget>[
////                                          Flexible(
////                                            child: Container(
////                                              child: Text(
////                                                'Nombre: ${farms[index]['name']}',
////                                                overflow: TextOverflow.ellipsis,
////                                                style: TextStyle(
////                                                  fontWeight: FontWeight.w600,
////                                                ),
////                                              ),
////                                            ),
////                                          ),
////                                          SizedBox(
////                                            height: 4,
////                                          ),
////                                          Container(
////                                            margin: EdgeInsets.only(right: 30),
////                                            child: Row(
////                                              mainAxisAlignment:
////                                                  MainAxisAlignment.start,
////                                              children: <Widget>[
////                                                Icon(
////                                                  Icons.location_on,
////                                                  color: Colors.green,
////                                                ),
////                                                Flexible(
////                                                  child: Container(
////                                                    constraints: BoxConstraints(
////                                                        maxWidth: maxWidth),
////                                                    child: Text(
////                                                      '${farms[index]['location']}',
////                                                      overflow:
////                                                          TextOverflow.ellipsis,
////                                                    ),
////                                                  ),
////                                                ),
////                                              ],
////                                            ),
////                                          ),
////                                          SizedBox(
////                                            height: 10,
////                                          ),
////                                          Row(
////                                            children: [
////                                              Icon(
////                                                Icons.map,
////                                                size: 12,
////                                                color: Colors.green,
////                                              ),
////                                              SizedBox(
////                                                width: 2,
////                                              ),
////                                              GestureDetector(
////                                                child: Container(
////                                                  margin:
////                                                      EdgeInsets.only(top: 0),
////                                                  child: Text(
////                                                    ' Ver en el mapa',
////                                                    style: TextStyle(
////                                                      fontSize: 12,
////                                                      color: Colors.green,
////                                                    ),
////                                                  ),
////                                                ),
////                                                onTap: () {
////                                                  Navigator.push(
////                                                    context,
////                                                    MaterialPageRoute(
////                                                      builder: (context) =>
////                                                          CropsOnFarmMapView(
////                                                        farmId: farms[index]
////                                                            ['id'],
////                                                      ),
////                                                    ),
////                                                  );
////                                                },
////                                              ),
////                                              SizedBox(
////                                                width: 10,
////                                              ),
////                                              Icon(
////                                                Icons.data_usage,
////                                                size: 12,
////                                                color: Colors.green,
////                                              ),
////                                              SizedBox(
////                                                width: 2,
////                                              ),
////                                              GestureDetector(
////                                                child: Container(
////                                                  margin:
////                                                      EdgeInsets.only(top: 0),
////                                                  child: Text(
////                                                    ' Data summary',
////                                                    style: TextStyle(
////                                                      fontSize: 12,
////                                                      color: Colors.green,
////                                                    ),
////                                                  ),
////                                                ),
////                                                onTap: () {
////                                                  Navigator.push(
////                                                    context,
////                                                    MaterialPageRoute(
////                                                      builder: (context) =>
////                                                          FarmDataSummary(
////                                                        farmId: farms[index]
////                                                            ['id'],
////                                                        farmName: farms[index]
////                                                            ['name'],
////                                                      ),
////                                                    ),
////                                                  );
////                                                },
////                                              )
////                                            ],
////                                          ),
////                                          SizedBox(
////                                            height: 10,
////                                          ),
////                                          Row(
////                                            children: <Widget>[
////                                              Container(
////                                                margin: EdgeInsets.only(top: 0),
////                                                child: Text(
////                                                  'Fecha: ${convertDateTimeDisplay(farms[index]['created_date'])}',
////                                                  style: TextStyle(
////                                                    fontSize: 11,
////                                                    color: Colors.grey,
////                                                  ),
////                                                ),
////                                              ),
////                                            ],
////                                          ),
////                                        ],
////                                      ),
////                                    ),
////                                  ),
////                                  IconButton(
////                                    icon: Icon(
////                                      Icons.arrow_forward_ios,
////                                    ),
////                                    iconSize: 30.0,
////                                    color: Colors.grey,
////                                    onPressed: () {
////                                      Navigator.push(
////                                        context,
////                                        MaterialPageRoute(builder: (context) {
////                                          return PlotListing(
////                                            farmId: getFarmId(index),
////                                            farmName: farms[index]['name'],
////                                          );
////                                        }),
////                                      );
////                                    },
////                                  ),
////                                ],
////                              ),
////                            ),
////                            onTap: () {
////                              Navigator.push(
////                                context,
////                                MaterialPageRoute(builder: (context) {
////                                  return PlotListing(
////                                    farmId: getFarmId(index),
////                                    farmName: farms[index]['name'],
////                                  );
////                                }),
////                              );
////                            },
////                          ),
////                        );
////                      } else {
////                        return Container(
////                          height: 100,
////                          child: GestureDetector(
////                            child: Card(
////                              child: Row(
////                                children: <Widget>[
////                                  Container(
////                                    margin:
////                                        EdgeInsets.symmetric(horizontal: 10.0),
////                                    child: ClipOval(
////                                      child: Image(
////                                        width: 50,
////                                        height: 50,
////                                        image: AssetImage(
////                                          'images/farms.png',
////                                        ),
////                                      ),
////                                    ),
////                                  ),
////                                  Expanded(
////                                    child: Container(
////                                      margin: EdgeInsets.symmetric(
////                                        horizontal: 15.0,
////                                      ),
////                                      child: Column(
////                                        crossAxisAlignment:
////                                            CrossAxisAlignment.start,
////                                        mainAxisAlignment:
////                                            MainAxisAlignment.center,
////                                        children: <Widget>[
////                                          Flexible(
////                                            child: Container(
////                                              child: Text(
////                                                'Nombre: ${farms[index]['name']}',
////                                                overflow: TextOverflow.ellipsis,
////                                                style: TextStyle(
////                                                  fontWeight: FontWeight.w600,
////                                                ),
////                                              ),
////                                            ),
////                                          ),
////                                          SizedBox(
////                                            height: 4,
////                                          ),
////                                          Container(
////                                            margin: EdgeInsets.only(right: 30),
////                                            child: Row(
////                                              mainAxisAlignment:
////                                                  MainAxisAlignment.start,
////                                              children: <Widget>[
////                                                Icon(
////                                                  Icons.location_on,
////                                                  color: Colors.green,
////                                                ),
////                                                Flexible(
////                                                  child: Container(
////                                                    constraints: BoxConstraints(
////                                                        maxWidth: maxWidth),
////                                                    child: Text(
////                                                      '${farms[index]['location']}',
////                                                      overflow:
////                                                          TextOverflow.ellipsis,
////                                                    ),
////                                                  ),
////                                                ),
////                                              ],
////                                            ),
////                                          ),
////                                          SizedBox(
////                                            height: 10,
////                                          ),
////                                          Row(
////                                            children: <Widget>[
////                                              Container(
////                                                margin: EdgeInsets.only(top: 0),
////                                                child: Text(
////                                                  'Fecha: ${convertDateTimeDisplay(farms[index]['created_date'])}',
////                                                  style: TextStyle(
////                                                    fontSize: 11,
////                                                    color: Colors.grey,
////                                                  ),
////                                                ),
////                                              ),
////                                              SizedBox(
////                                                width: 2,
////                                              ),
////                                              Icon(
////                                                Icons.location_on,
////                                                size: 12,
////                                                color: Colors.green,
////                                              ),
////                                              GestureDetector(
////                                                child: Container(
////                                                  margin:
////                                                      EdgeInsets.only(top: 0),
////                                                  child: Text(
////                                                    ' view on map',
////                                                    style: TextStyle(
////                                                      fontSize: 12,
////                                                      color: Colors.green,
////                                                    ),
////                                                  ),
////                                                ),
////                                                onTap: () {
////                                                  Navigator.push(
////                                                    context,
////                                                    MaterialPageRoute(
////                                                      builder: (context) =>
////                                                          CropsOnFarmMapView(
////                                                        farmId: farms[index]
////                                                            ['id'],
////                                                      ),
////                                                    ),
////                                                  );
////                                                },
////                                              )
////                                            ],
////                                          ),
////                                        ],
////                                      ),
////                                    ),
////                                  ),
////                                  IconButton(
////                                    icon: Icon(
////                                      Icons.arrow_forward_ios,
////                                    ),
////                                    iconSize: 30.0,
////                                    color: Colors.grey,
////                                    onPressed: () {
////                                      Navigator.push(
////                                        context,
////                                        MaterialPageRoute(builder: (context) {
////                                          return PlotListing(
////                                            farmId: getFarmId(index),
////                                            farmName: farms[index]['name'],
////                                          );
////                                        }),
////                                      );
////                                    },
////                                  ),
////                                ],
////                              ),
////                            ),
////                            onTap: () {
////                              Navigator.push(
////                                context,
////                                MaterialPageRoute(builder: (context) {
////                                  return PlotListing(
////                                    farmId: farms[index]['id'],
////                                    farmName: farms[index]['name'],
////                                  );
////                                }),
////                              );
////                            },
////                          ),
////                        );
////                      }
////                    },
////                  );
////                },
////              );
////            } else if (snapshot.hasError) {
////              return Center(
////                child: Text(
////                  "Error de conexión: la conexión al servidor terminó. "
////                  "Administrador de contacto",
////                  textAlign: TextAlign.center,
////                ),
////              );
////            } else if (snapshot.data == null) {
////              return Center(
////                child: Text(
////                  'Aún no se agregaron campos',
////                ),
////              );
////            }
////          } else if (snapshot.connectionState == ConnectionState.waiting) {
////            return Center(child: CircularProgressIndicator());
////          }
////          return Center(child: CircularProgressIndicator());
////        },
////      ),
////      floatingActionButton: FloatingActionButton(
////        child: Icon(Icons.add),
////        backgroundColor: Colors.green,
////        onPressed: () {
////          Navigator.push(
////              context, MaterialPageRoute(builder: (context) => AddNewFarm()));
////        },
////      ),
//body: Stack(
//children: [
//
//],
//),

//);
