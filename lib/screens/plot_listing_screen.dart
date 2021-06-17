import 'dart:convert';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/date_convert_function.dart';
import 'package:agscoutapp/functions/plot_listing_function.dart';
import 'package:agscoutapp/screens/new_plot_screen.dart';
import 'package:agscoutapp/screens/crop_scout_screen.dart';
import 'package:agscoutapp/services/plot-offline-services.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/widgets.dart';

import 'data_summary_chart.dart';

class PlotListing extends StatefulWidget {
  final farmId;
  final farmName;
  PlotListing({this.farmId, this.farmName});

  static const String routeName = 'plot_listing_screen';
  @override
  _PlotListingState createState() => _PlotListingState();
}

class _PlotListingState extends State<PlotListing> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List plots = [];
  var createdDate;
  var farmName;
  bool isLoading = true;

  _getPlotList(bool firstInstance) async {
    plots = await DatabaseHelper.instance.queryPlotByFarm(widget.farmId);
    farmName = widget.farmName;
    isLoading = firstInstance;
    setState(() {});
  }

//  getPlotId(index) {
//    var id = plots[index]['_plotId'];
//    return id;
//  }

  getPlotDataFromLocalDB() async {
    setState(() {
      isLoading = true;
    });
    var c = PlotOfflineService();
    await c.getPlotFromLocalDB(widget.farmId);
    _getPlotList(false);
  }

  initState() {
    super.initState();
    _getPlotList(true);
    getPlotDataFromLocalDB();
  }

  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.4;
    return Scaffold(
        appBar: CustomAppBar(
          title: Text('Cuartel'),
          height: 50,
        ),
        body: Stack(
          children: <Widget>[
            (isLoading && plots.length == 0)
                ? Center(child: CircularProgressIndicator())
                : (!isLoading && plots.length == 0)
                    ? Center(
                        child: Text('Sin contenido'),
                      )
                    : ListView.builder(
                        itemCount: plots.length,
                        itemBuilder: (context, index) {
//                      var plot = int.parse(plots[index]['_plotId']);

//                      print(">>>>> plot ${plot.runtimeType}");
                          return Container(
                            height: 200,
                            child: GestureDetector(
                              child: Card(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                      child: ClipOval(
                                        child: Image(
                                          width: 50,
                                          height: 50,
                                          image: AssetImage(
                                            'images/plots.png',
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
                                                  'Nombre: ${plots[index]['plotName']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  'Tipo de cultivo: ${plots[index]['plotCropType'] != null ? plots[index]['plotCropType'] : "Not available"}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  'Superficie (ha): ${plots[index]['area']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  'Plantas (ha): ${plots[index]['plantPerHectare']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  'Variedad: ${plots[index]['variety']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
//
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  'Centro de costo: ${plots[index]['centroDeCosto'] == null ? "0" : plots[index]['centroDeCosto']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
//
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.insert_chart,
                                                  color: Colors.green,
                                                ),
                                                GestureDetector(
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.only(top: 0),
                                                    child: Text(
                                                      ' vista del informe',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DataSummaryChart(
                                                          plotId: plots[index]
                                                              ['_plotId'],
                                                          plotName: plots[index]
                                                              ['plotName'],
                                                          farmName: farmName,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 0),
                                              child: Text(
                                                'Fecha Agregada: ${convertDateTimeDisplay(plots[index]['plotCreatedDate'])}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
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
                                          MaterialPageRoute(builder: (context) {
                                            return CropScout(
                                              plotId: plots[index]['_plotId']
                                                  .toString(),
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
                                    return CropScout(
                                      plotId:
                                          plots[index]['_plotId'].toString(),
                                    );
                                  }),
                                );
                              },
                            ),
                          );
                        },
                      ),
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
                            builder: (context) => NewPlot(
                              farmId: widget.farmId,
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
        ));
  }
}
