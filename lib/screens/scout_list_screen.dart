import 'dart:convert';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/crop_scout_function.dart';
import 'package:agscoutapp/functions/date_convert_function.dart';
import 'package:agscoutapp/screens/crop_scout_screen.dart';
import 'package:agscoutapp/services/scout-offline-service.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScoutListScreen extends StatefulWidget {
  final plotId;
  ScoutListScreen({this.plotId});

  static const String routeName = 'scout_list';
  @override
  _ScoutListScreenState createState() => _ScoutListScreenState();
}

class _ScoutListScreenState extends State<ScoutListScreen> {
  final dbHelper = DatabaseHelper.instance;
  List cropScoutList = [];
  bool isLoading = true;
  _getCropScoutList(bool firstInstance) async {
    cropScoutList = await DatabaseHelper.instance.queryAllScout();
    isLoading = firstInstance;
    setState(() {});
    var dataqueue =
        await DatabaseHelper.instance.queryAllDataScoutLocalQueueTable();
    print("Data queuee  Items from data queue>>>>>> $dataqueue");
  }

  loadScoutDataFromLocalAPI() async {
    setState(() {
      isLoading = true;
    });
    var localScoutData = ScoutOfflineService();
    await localScoutData.getScoutDataFromLocalDB(widget.plotId);
    _getCropScoutList(false);
  }

  initState() {
    super.initState();
    _getCropScoutList(true);
  }

  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Listado conteo',
        ),
        height: 50,
      ),
      body: SafeArea(
        child: Container(
            child: Stack(
          children: <Widget>[
            (isLoading && cropScoutList.length == 0)
                ? Center(child: CircularProgressIndicator())
                : (!isLoading && cropScoutList.length == 0)
                    ? Center(
                        child: Text('No Content'),
                      )
                    : ListView.builder(
                        itemCount: cropScoutList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 1,
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: cropScoutList[index]['cropImage'] !=
                                            null
                                        ? Image.network(
                                            cropScoutList[index]['cropImage'],
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'images/plots.png',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'Cuartel: ${cropScoutList[index]['scoutPlotName'].toString()}',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      //RatingStars(),
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'tipo de conteo: ${cropScoutList[index]['typeOfScout']}',
                                            style: TextStyle(
                                              fontSize: 14.0,
//                                            fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'Fila No: ${cropScoutList[index]['rowNumber'].toString()} ',
                                            style: TextStyle(
                                              fontSize: 14.0,
//                                            fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 20.0,
//                                            vertical: 10.0,
                                            ),
                                            child: Text(
                                              'Laterales No: ${cropScoutList[index]['numberOfLaterals'].toString() == '0' ? "No data" : cropScoutList[index]['numberOfLaterals'].toString()}',
                                              style: TextStyle(
                                                fontSize: 13.0,
//                                            fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'Planta No: ${cropScoutList[index]['plantNumber'].toString()}',
                                            style: TextStyle(
                                              fontSize: 13.0,
//                                            fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 20.0,
//                                            vertical: 10.0,
                                                ),
                                                child: Text(
                                                  'Ramas No: '
                                                  '${cropScoutList[index]['numberOfBranches'].toString() == '0' ? "No data" : cropScoutList[index]['numberOfBranches'].toString()}',
                                                  style: TextStyle(
                                                    fontSize: 13.0,
//                                            fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'No. conteo: ${cropScoutList[index]['numberOfCounts'].toString()}',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'Nombre contador: ${cropScoutList[index]['scoutUser'].toString()}',
                                            style: TextStyle(
                                                fontSize: 11.0,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 1.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'Fecha: ${convertDateTimeDisplay(
                                              cropScoutList[index]
                                                          ['scoutedDate'] ==
                                                      null
                                                  ? '2020-10-21T10:46:39.687414-03:00'
                                                  : cropScoutList[index]
                                                      ['scoutedDate'],
                                            )}',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
//            FutureBuilder(
//              future: _getCropScoutList(),
//              initialData: 'loading text...',
//              builder: (context, AsyncSnapshot snapshot) {
//                if (snapshot.connectionState == ConnectionState.done) {
//                  if (snapshot.hasData) {
//
//                    return
//                  } else if (snapshot.hasError) {
//                    return Center(
//                      child: Text(
//                        "Error de conexión: la conexión al servidor terminó. "
//                        "Administrador de contacto",
//                        textAlign: TextAlign.center,
//                      ),
//                    );
//                  } else if (snapshot.data == null) {
//                    return Center(
//                      child: Text(
//                        'No se toman exploradores para esta trama.',
//                      ),
//                    );
//                  }
//                } else if (snapshot.connectionState ==
//                    ConnectionState.waiting) {
//                  return Center(child: CircularProgressIndicator());
//                }
//                return Center(child: CircularProgressIndicator());
//              },
//            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                    height: 56, // 56
                    width: 56, // 56 big screen
//                  // margin: EdgeInsets.only(left: 342, bottom: 16), Big screen
                    margin: EdgeInsets.only(left: 305, bottom: 16),
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CropScout(
                              plotId: widget.plotId,
                            ),
                          ),
                        );
                      },
                      elevation: 6.0,
                      fillColor: Colors.green,
                      child: Icon(
                        Icons.add,
                        size: 23.0,
                        color: Colors.white,
                      ),
//                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    )),
              ],
            )
          ],
        )),
      ),
    );
  }
}
