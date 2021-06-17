import 'dart:convert';

import 'package:agscoutapp/commons/background_overlays.dart';
import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/organization_function.dart';
import 'package:agscoutapp/screens/invite_employee_screen.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:commons/commons.dart';

class ViewOrganizationProfile extends StatefulWidget {
  static const String routeName = 'view_organization_profile';

  @override
  _ViewOrganizationProfileState createState() =>
      _ViewOrganizationProfileState();
}

class _ViewOrganizationProfileState extends State<ViewOrganizationProfile> {
  final dbHelper = DatabaseHelper.instance;
  var createdDate;
  var dataCount;
  var employeesCount, farmsCount, plotsCount, scoutsCount;
  Future<List<Map<String, dynamic>>> getOrgProfileData() async {
    var orgId = await getOrganizationIDFromSF();
    employeesCount = await getEmployeesCountFromSF();
    farmsCount = await getFarmsCountFromSF();
    plotsCount = await getPlotsCountFromSF();
    scoutsCount = await getScoutsCountFromSF();
    var queryRow = await DatabaseHelper.instance.queryOne(int.parse(orgId));
    createdDate = DateFormat("yyyy-MM-dd").parse(queryRow[0]['createdDate']);

    return queryRow;
  }

  Future _getOrgDataCount() async {
    var response = await GetOrganizationDataCountAPI.getOrganizationDataCount();
    dataCount = json.decode(response.body)['data'];
    setState(() {
      employeesCount = setEmployeesCountToSF(dataCount['employees_count']);
      plotsCount = setPlotCountToSF(dataCount['plots_count']);
      scoutsCount = setScoutCountToSF(dataCount['scouts_count']);
      farmsCount = setFarmsCountToSF(dataCount['farms_count']);
    });
    try {
      if (dataCount == null) return;
    } catch (error) {
      print(error);
    }
    return dataCount;
  }

//  var orgCreatedDate = DateTime.parse(createdDate);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOrgDataCount();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Perfil'),
        height: 50,
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            FutureBuilder(
              future: getOrgProfileData(),
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
                                  BackgroundOverlays(
                                    imageURL: 'images/background_image.jpg',
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 30, left: 5),
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
//
                                        ),
                                        ClipOval(
                                          child: CircleAvatar(
                                            child: snapshot.data[0]['logo'] !=
                                                    null
                                                ? Image.network(
                                                    snapshot.data[0]['logo'],
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image(
                                                    image: AssetImage(
                                                        'images/new_org_profile.png'),
                                                  ),
                                            backgroundColor: Colors.white,
                                            maxRadius: 60,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          snapshot.data[0]['name'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          snapshot.data[0]['location'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            height: 100,
                                            width: 180,
//                        color: Colors.blue,
                                            child: Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0,
                                                              right: 8),
                                                      child: Image.asset(
                                                        'images/farms.png',
                                                        height: 40,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Campos: ',
                                                    ),
                                                    Text(
                                                      farmsCount.toString(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              elevation: 3,
                                            ),
                                          ),
                                          Container(
                                            height: 100,
                                            width: 155,
//                        color: Colors.blue,
                                            child: Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 0.0,
                                                              right: 0),
                                                      child: Image.asset(
                                                        'images/plots.png',
                                                        height: 40,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Cuartel:  ',
                                                    ),
                                                    Text(plotsCount.toString()),
                                                  ],
                                                ),
                                              ),
                                              elevation: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            height: 100,
                                            width: 180,
//                                            margin: EdgeInsets.only(left: 33),
                                            child: Card(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 0.0,
                                                              right: 8),
                                                      child: Image.asset(
                                                        'images/scouts.png',
                                                        height: 40,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Scouts:  ',
                                                    ),
                                                    Text(
                                                        scoutsCount.toString()),
                                                  ],
                                                ),
                                              ),
                                              elevation: 3,
                                            ),
                                          ),
                                          Container(
                                            height: 100,
                                            width: 156,
//                                            margin: EdgeInsets.only(left: 33),
                                            child: GestureDetector(
                                              child: Card(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0,
                                                                right: 8),
                                                        child: Image.asset(
                                                          'images/new_employee.png',
                                                          height: 40,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Empleados',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                elevation: 3,
                                              ),
                                              onTap: () {
                                                showEmployeeInviteInput(
                                                    context);
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
                          ],
                        ),
                        Positioned(
                          top: screenHeight * (4 / 9) - 145 / 2,
                          left: 16,
                          right: 16,
                          child: Container(
                            height: 80,
//              color: Colors.white,
                            child: Card(
                              child: Row(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Image.asset(
                                          'images/employees.png',
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0.0, top: 25, right: 60),
                                            child: Text(
                                              'Empleados: ${employeesCount.toString()}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4D4D4D),
                                              ),
                                            ),
                                          ),
//
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 50),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  'Fecha de unión: ',
                                                  style: TextStyle(
                                                    fontSize: 8,
//                                      color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat("dd-MM-yy")
                                                      .format(createdDate),
                                                  style: TextStyle(
                                                    fontSize: 8,
//                                      color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  'Código de organización: ',
                                                  style: TextStyle(
                                                    fontSize: 10,
//                                      color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  snapshot.data[0]
                                                      ['organizationCode'],
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold
//                                      color: Colors.grey,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              elevation: 4,
                            ),
                          ),
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
    );
  }
}
