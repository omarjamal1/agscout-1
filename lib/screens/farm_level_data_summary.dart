import 'package:agscoutapp/functions/crop_scout_function.dart';
import 'package:agscoutapp/functions/farm_level_data_summary_function.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:agscoutapp/functions/data_analysis_chart_function.dart';
import 'package:agscoutapp/functions/data_analysis_summary_function.dart';
import 'package:agscoutapp/helpers/chart_helpers.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

/// Sample ordinal data type.

class FarmDataSummary extends StatefulWidget {
  static const String routeName = 'farm_data_summary';
  final farmId;
  final farmName;

  FarmDataSummary({this.farmId, this.farmName});

  @override
  _FarmDataSummaryState createState() => _FarmDataSummaryState();
}

class _FarmDataSummaryState extends State<FarmDataSummary> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isSelected = false;
  String selectedScoutTypeChoice = '';
  String scoutTypeValue;
  List recordedScoutTypes;
  List tcppAnalysis;
  List filterTcppAnalysis;
  List filterAverageCountAnalysis;
  List filterCountPerHaAnalysis;
  List tcppPieData;
  List cphAnalysis;
  List averageCountAnalysis;
  List searchList;
  Map tcppChartDataResult;
  List<TotalCountPerPlotClassData> buildList;
  var tcppTypeOfScoutName = '';
  String emptyAnalysisText;
  String year = '';
  String filterScoutType = '';

  // Dropdown utils for scout years
  String filterScoutYear = '';
  String dropdownScoutYearsText = 'Seleccionar Años';
  dynamic _currentScoutYear;

  List<charts.Series<TcppAnalysisData, String>> _seriesTcppAnalysisData;
  List<charts.Series<BarTcppAnalysisData, String>>
      _seriesBarChartTcppAnalysisData;
//  dynamic tcppChartDataResult;
  dynamic _currentScoutType;
  final numberFormatter = new NumberFormat("#,###.#");
  String dropdownShowText = 'Tipo de Conteo';

  List<charts.Series<TotalCountPerPlotClassData, String>> newSeriesList;
  List<charts.Series> seriesList;
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget appBarTitle = new Text(
    "Data Analysis",
    style: new TextStyle(color: Colors.white),
  );
  bool _IsSearching = false;
  String _searchText = "";
  final TextEditingController _yearSearchQuery = new TextEditingController();
  final TextEditingController _scoutTypeSearchQuery =
      new TextEditingController();

  Future _getTcppDataAnalysisSummary() async {
    var response =
        await GetFarmDataAnalysisSummaryAPI.getFarmDataAnalysisSummaryData(
            widget.farmId);
    tcppAnalysis = json.decode(response.body)['total_count_per_farm'];
    print(tcppAnalysis);
    return tcppAnalysis;
  }

  Future _getCphDataAnalysisSummary() async {
    // counts_per_hectare
    var response =
        await GetFarmDataAnalysisSummaryAPI.getFarmDataAnalysisSummaryData(
            widget.farmId);
    cphAnalysis = json.decode(response.body)['total_count_ha'];

    return cphAnalysis;
  }

  Future _getFarmAverageCountDataAnalysisSummary() async {
    // Average Count per farm
    var response =
        await GetFarmDataAnalysisSummaryAPI.getFarmDataAnalysisSummaryData(
            widget.farmId);
    averageCountAnalysis = json.decode(response.body)['average_count'];

    return averageCountAnalysis;
  }

  /// Filtered Data
  Future _filterCalculatedDataSummary() async {
    setState(() {
      _IsSearching = true;
    });
    var response = await FilterFarmDataSummaryFromAPI
        .filterFarmDataSummaryByYearAndScoutType(
            widget.farmId, filterScoutYear, filterScoutType);

    try {
      if (response.statusCode == 200) {
        filterTcppAnalysis = json.decode(response.body)['total_count_per_plot'];
        filterAverageCountAnalysis =
            json.decode(response.body)['average_count'];
        filterCountPerHaAnalysis =
            json.decode(response.body)['counts_per_hectare'];
        return filterTcppAnalysis;
      }
    } catch (e) {
      print(e);
    }
  }

  void _handleSearchEnd() {
    /// Clear all input fields for search.
    setState(() {
      dropdownShowText = 'Seleccionar Conteo';
      _IsSearching = false;
      _yearSearchQuery.clear();
      _scoutTypeSearchQuery.clear();
      _currentScoutType = null;
      filterScoutType = '';
      // clear selected year on filter
      filterScoutYear = '';
      _currentScoutYear = null;
      dropdownScoutYearsText = 'Seleccionar Años';
    });
  }

  Future<List<FarmScoutType>> _getScoutTypeList() async {
    var response = await ScoutTypeAPI.scoutTypes();
    if (response.statusCode == 200) {
      final items = json.decode(response.body)['data'];
      List<FarmScoutType> listOfScoutTypes = items.map<FarmScoutType>((json) {
        return FarmScoutType.fromJson(json);
      }).toList();
      return listOfScoutTypes;
    } else {
      throw Exception('No se pudo cargar, no hay Internet');
    }
  }

  Future<List<ScoutYearsListOnFarmClass>> _getScoutYearsList() async {
    var response =
        await ScoutYearsListOnFarmAPI.scoutYearsListOnFarm(widget.farmId);
//    print("${json.decode(response.body)['scout_years']}");
    if (response.statusCode == 200) {
      final items = json.decode(response.body)['scout_years'];
      List<ScoutYearsListOnFarmClass> listOfScoutYears =
          items.map<ScoutYearsListOnFarmClass>((json) {
        return ScoutYearsListOnFarmClass.fromJson(json);
      }).toList();
      return listOfScoutYears;
    } else {
      throw Exception('No se pudo cargar, no hay Internet');
    }
  }

  Widget _averageCountDataAnalysisFilterResult() {
    /// Average count data analysis filter Result widget builder
    return FutureBuilder(
      future: _filterCalculatedDataSummary(),
      initialData: 'loading text...',
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 0,
                ),
                Card(
                  borderOnForeground: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  color: Colors.green,
                  child: new Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: ClipOval(
                              child: Image(
                                width: 50,
                                height: 50,
//                                              color: Colors.yellow,
                                image: AssetImage(
                                  'images/analytics_color_2.png',
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'Conteo promedio.',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                              Text(
                                // 'Total count per plot'
                                'Nombre del campo: ${widget.farmName}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 70,
                              width: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: filterAverageCountAnalysis == null
                                    ? 0
                                    : filterAverageCountAnalysis.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Text(
                                              '${numberFormatter.format(filterAverageCountAnalysis[index]['average_count'])}',
//                                                                'Some data',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text(
                                              '${filterAverageCountAnalysis[index]['type_of_scout__scout_type']}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // Counts per ha card
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error de conexión: la conexión al servidor terminó. "
                "Administrador de contacto",
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.data == null) {
            return Center();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text(''));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _tcppDataAnalysisFilterResult() {
    /// Total Count per farm Data analysis filter Result widget builder
    return FutureBuilder(
      future: _filterCalculatedDataSummary(),
      initialData: 'loading text...',
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                Card(
                  borderOnForeground: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  color: Colors.green,
                  child: new Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: ClipOval(
                              child: Image(
                                width: 50,
                                height: 50,
//                                              color: Colors.yellow,
                                image: AssetImage(
                                  'images/analytics_color_2.png',
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'Conteo  total Campo.',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                              Text(
                                // 'Total count per plot'
                                'Nombre del campo: ${widget.farmName}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 70,
                              width: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: filterTcppAnalysis == null
                                    ? 0
                                    : filterTcppAnalysis.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Text(
                                              '${numberFormatter.format(filterTcppAnalysis[index]['tcpp'])}',
//                                                                'Some data',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text(
                                              '${filterTcppAnalysis[index]['type_of_scout__scout_type']}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // Counts per ha card
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error de conexión: la conexión al servidor terminó. "
                "Administrador de contacto",
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.data == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
//                                  crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: Text(
                    'Análisis de datos resumidos no disponible.',
                  ),
                )
              ],
            );
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _countsPerHaDataAnalysisFilterResult() {
    /// Counts per Ha data analysis filter Result widget builder
    return FutureBuilder(
      future: _filterCalculatedDataSummary(),
      initialData: 'loading text...',
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 0,
                ),
                Card(
                  borderOnForeground: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  color: Colors.green,
                  child: new Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: ClipOval(
                              child: Image(
                                width: 50,
                                height: 50,
//                                              color: Colors.yellow,
                                image: AssetImage(
                                  'images/analytics_color_2.png',
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'Conteo por hectarea por campo.',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                              Text(
                                // 'Total count per plot'
                                'Nombre del campo: ${widget.farmName}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 70,
                              width: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: filterCountPerHaAnalysis == null
                                    ? 0
                                    : filterCountPerHaAnalysis.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Text(
                                              '${numberFormatter.format(filterCountPerHaAnalysis[index]['counts_pha'])}',
//                                                                'Some data',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text(
                                              '${filterCountPerHaAnalysis[index]['type_of_scout__scout_type']}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // Counts per ha card
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error de conexión: la conexión al servidor terminó. "
                "Administrador de contacto",
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.data == null) {
            return Center();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text(''));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getCphDataAnalysisSummary();

    newSeriesList = List<charts.Series<TotalCountPerPlotClassData, String>>();
    _seriesTcppAnalysisData = List<charts.Series<TcppAnalysisData, String>>();
    _seriesBarChartTcppAnalysisData =
        List<charts.Series<BarTcppAnalysisData, String>>();
    buildList = List<TotalCountPerPlotClassData>();
    _getScoutTypeList();
    _getScoutYearsList();
    recordedScoutTypes = List<dynamic>();
    selectedScoutTypeChoice = "";
    scoutTypeValue = '';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Column(
                children: [
                  Container(
                    width: 240,
                    child: FutureBuilder<List<ScoutYearsListOnFarmClass>>(
                        future: _getScoutYearsList(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<ScoutYearsListOnFarmClass>>
                                snapshot) {
                          if (!snapshot.hasData)
                            return Text(
                              'Cargando años...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            );
                          return DropdownButton<ScoutYearsListOnFarmClass>(
                            items: snapshot.data
                                .map((scoutYearsData) =>
                                    DropdownMenuItem<ScoutYearsListOnFarmClass>(
                                      child: Container(
                                        width: 200,
                                        child: Text(
                                          '${scoutYearsData.scoutYears}',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      value: scoutYearsData,
                                    ))
                                .toList(),
                            onChanged: (value) {
                              _filterCalculatedDataSummary();
                              setState(() {
                                _currentScoutYear = value.scoutYears;
                                dropdownScoutYearsText = value.scoutYears;
                                filterScoutYear = value.scoutYears;
                                print(filterScoutYear);
                              });
                            },
                            isExpanded: false,
                            hint: Text('$dropdownScoutYearsText'),
                          );
                        }),
                  ),
                  Container(
                    width: 240,
                    child: FutureBuilder<List<FarmScoutType>>(
                        future: _getScoutTypeList(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<FarmScoutType>> snapshot) {
                          if (!snapshot.hasData)
                            return Text(
                              'Cargando tipo Scout...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            );
                          return DropdownButton<FarmScoutType>(
                            items: snapshot.data
                                .map((scoutTypeData) =>
                                    DropdownMenuItem<FarmScoutType>(
                                      child: Container(
                                        width: 200,
                                        child: Text(
                                          scoutTypeData.scoutType,
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      value: scoutTypeData,
                                    ))
                                .toList(),
                            onChanged: (value) {
                              _filterCalculatedDataSummary();
                              setState(() {
                                _currentScoutType = value.id;
                                dropdownShowText = value.scoutType;
                                filterScoutType = value.scoutType;
//                                  print(dropdownShowText);
                              });
                            },
                            isExpanded: false,
                            hint: Text('$dropdownShowText'),
                          );
                        }),
                  ),
                ],
              ),
              toolbarHeight: 150.0,
              backgroundColor: Colors.green,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _handleSearchEnd();
                  },
                  color: Colors.white,
                )
              ],
            ),
//        backgroundColor: Colors.white,
            body: !_IsSearching
                ? SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        FutureBuilder(
                          future: _getFarmAverageCountDataAnalysisSummary(),
                          initialData: 'loading text...',
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 0,
                                    ),
                                    Card(
                                      borderOnForeground: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      elevation: 5,
                                      color: Colors.green,
                                      child: new Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 10.0),
                                                child: ClipOval(
                                                  child: Image(
                                                    width: 50,
                                                    height: 50,
//                                              color: Colors.white,
                                                    image: AssetImage(
                                                      'images/analytics_color_2.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    // 'Avergage Count'
                                                    'Conteo promedio.',
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    // 'Avergage Count'
                                                    'Nombre del campo: ${widget.farmName}',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Container(
                                                  height: 70,
                                                  width: 350,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        averageCountAnalysis ==
                                                                null
                                                            ? 0
                                                            : averageCountAnalysis
                                                                .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20.0),
                                                                child: Text(
                                                                  '${numberFormatter.format(averageCountAnalysis[index]['average_count'])}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                  '${averageCountAnalysis[index]['scout_type']}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    // Counts per ha card
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Error de conexión: la conexión al servidor terminó. "
                                    "Administrador de contacto",
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              } else if (snapshot.data == null) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
//                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 200.0),
                                      child: Text(
                                        'Análisis de datos resumidos no disponible.',
                                      ),
                                    )
                                  ],
                                );
                              }
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
//                        return Center(child: CircularProgressIndicator());
                            }
                            return Center(child: Text(''));
                          },
                        ),
                        FutureBuilder(
                          future: _getTcppDataAnalysisSummary(),
                          initialData: 'loading text...',
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 0,
                                    ),
                                    Card(
                                      borderOnForeground: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      elevation: 5,
                                      color: Colors.green,
                                      child: new Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 10.0),
                                                child: ClipOval(
                                                  child: Image(
                                                    width: 50,
                                                    height: 50,
//                                              color: Colors.white,
                                                    image: AssetImage(
                                                      'images/analytics_color_2.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    'Conteo total por Campo.',
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    // 'Total count per plot'
                                                    'Nombre del campo: ${widget.farmName}',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Container(
                                                  height: 70,
                                                  width: 350,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemCount: tcppAnalysis ==
                                                            null
                                                        ? 0
                                                        : tcppAnalysis.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20.0),
                                                                child: Text(
//                                                              '${tcppAnalysis[index]['total_count_per_farm'].toString()}',
                                                                  '${numberFormatter.format(tcppAnalysis[index]['total_count_per_farm'])}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                  '${tcppAnalysis[index]['scout_type']}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    // Counts per ha card
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Error de conexión: la conexión al servidor terminó. "
                                    "Administrador de contacto",
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              } else if (snapshot.data == null) {
                                return Center(
//                                  child: Text(
//                                    'Análisis de datos resumidos no disponible.',
//                                  ),
                                    );
                              }
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
//                        return Center(child: CircularProgressIndicator());
                            }
                            return Center(child: Text(''));
                          },
                        ),
                        FutureBuilder(
                          future: _getCphDataAnalysisSummary(),
                          initialData: 'loading text...',
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 0,
                                    ),
                                    Card(
                                      borderOnForeground: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      elevation: 5,
                                      color: Colors.green,
                                      child: new Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 10.0),
                                                child: ClipOval(
                                                  child: Image(
                                                    width: 50,
                                                    height: 50,
//                                              color: Colors.yellow,
                                                    image: AssetImage(
                                                      'images/analytics_color_2.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    'Conteo  por hectarea por Campo.',
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    // 'Total count per plot'
                                                    'Nombre del campo: ${widget.farmName}',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Container(
                                                  height: 70,
                                                  width: 350,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemCount: cphAnalysis ==
                                                            null
                                                        ? 0
                                                        : cphAnalysis.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20.0),
                                                                child: Text(
                                                                  '${numberFormatter.format(cphAnalysis[index]['total_count_ha'])}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                  '${cphAnalysis[index]['scout_type']}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    // Counts per ha card
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Error de conexión: la conexión al servidor terminó. "
                                    "Administrador de contacto",
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              } else if (snapshot.data == null) {
                                return Center(
//                                  child: Text(
//                                    'Análisis de datos resumidos no disponible.',
//                                  ),
                                    );
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
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _averageCountDataAnalysisFilterResult(),
                        _tcppDataAnalysisFilterResult(),
                        _countsPerHaDataAnalysisFilterResult(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
