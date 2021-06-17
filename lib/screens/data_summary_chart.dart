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

class DataSummaryChart extends StatefulWidget {
  static const String routeName = 'data_summary_chart_page';
  final plotId;
  final plotName;
  final farmName;

//  final List<charts.Series> seriesList;
//  final bool animate;

  DataSummaryChart({this.plotId, this.plotName, this.farmName});

  @override
  _DataSummaryChartState createState() => _DataSummaryChartState();
}

class _DataSummaryChartState extends State<DataSummaryChart> {
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
  String dropdownShowText = 'Tipo de Conteo';
  final numberFormatter = new NumberFormat("#,###.#");
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

  Future<List<ScoutYearsListOnPlotClass>> _getScoutYearsListOnPlot() async {
    var response =
        await ScoutYearsListOnPlotAPI.scoutYearsListOnPlot(widget.plotId);
//    print("${json.decode(response.body)['scout_years']}");
    if (response.statusCode == 200) {
      final items = json.decode(response.body)['scout_years'];
      List<ScoutYearsListOnPlotClass> listOfScoutYears =
          items.map<ScoutYearsListOnPlotClass>((json) {
        return ScoutYearsListOnPlotClass.fromJson(json);
      }).toList();
      return listOfScoutYears;
    } else {
      throw Exception('No se pudo cargar, no hay Internet');
    }
  }

  Future _getTcppDataAnalysisSummary() async {
    var response = await GetDataAnalysisSummaryAPI.getDataAnalysisSummaryData(
        widget.plotId);
    tcppAnalysis = json.decode(response.body)['total_count_per_plot'];
    return tcppAnalysis;
  }

  Future _getCphDataAnalysisSummary() async {
    // counts_per_hectare
    var response = await GetDataAnalysisSummaryAPI.getDataAnalysisSummaryData(
        widget.plotId);
    cphAnalysis = json.decode(response.body)['counts_per_hectare'];

    return cphAnalysis;
  }

  Future _getAverageCountDataAnalysisSummary() async {
    // counts_per_hectare
    var response = await GetDataAnalysisSummaryAPI.getDataAnalysisSummaryData(
        widget.plotId);
    averageCountAnalysis = json.decode(response.body)['average_count'];

    return averageCountAnalysis;
  }

  /// Chart data
  Future totalCountPerPlotChartData() async {
    var tcppChartData = await GetChartDataAPI.getChartData(widget.plotId);
    List colors = [
      charts.MaterialPalette.blue.shadeDefault.lighter,
      charts.MaterialPalette.teal.shadeDefault.lighter,
      charts.MaterialPalette.red.shadeDefault.lighter,
      charts.MaterialPalette.green.shadeDefault.lighter,
      charts.MaterialPalette.deepOrange.shadeDefault.lighter,
      charts.MaterialPalette.purple.shadeDefault.lighter
    ];
    List lineColors = [
      charts.MaterialPalette.blue.shadeDefault,
      charts.MaterialPalette.teal.shadeDefault,
      charts.MaterialPalette.red.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
      charts.MaterialPalette.deepOrange.shadeDefault,
      charts.MaterialPalette.purple.shadeDefault
    ];
    Map tcppDataMap = Map<String, List<TotalCountPerPlotClassData>>();
    tcppChartDataResult =
        json.decode(tcppChartData.body)['tcpp_chart_data_result'];

    tcppChartDataResult.forEach((key, value) {
      List<TotalCountPerPlotClassData> tcppDataList = [];

      for (var i in value) {
        var totalVariable = TotalCountPerPlotClassData(
          year: '${i['scouted_date__year'].toString()}',
          averageCount: double.parse('${i['tcpp_chart_data']}'),
        );
        tcppDataList.add(totalVariable);
      }
      tcppDataMap.putIfAbsent(key, () => tcppDataList);
    });

    tcppDataMap.forEach((key, value) {
      int randomColor = Random().nextInt(colors.length);
      newSeriesList.add(
        charts.Series(
          id: key,
          domainFn: (TotalCountPerPlotClassData tcppData, _) => tcppData.year,
          measureFn: (TotalCountPerPlotClassData tcppData, _) =>
              tcppData.averageCount,
          data: value,
          colorFn: (_, __) => lineColors[randomColor],
          fillColorFn: (_, __) => colors[randomColor],
        ),
      );
    });
  }

  /// Filtered Data
  Future _filterCalculatedDataSummary() async {
    setState(() {
      _IsSearching = true;
    });

    var response =
        await FilterDataSummaryFromAPI.filterDataSummaryByYearAndScoutType(
            widget.plotId, filterScoutYear, filterScoutType);
    try {
      if (response.statusCode == 200) {
        filterTcppAnalysis = json.decode(response.body)['total_count_per_plot'];
        filterAverageCountAnalysis =
            json.decode(response.body)['average_count'];
        filterCountPerHaAnalysis =
            json.decode(response.body)['counts_per_hectare'];

        return filterTcppAnalysis;
      } else {
        displayDialog(context, 'Alert', 'Informacion no disponible.');
      }
    } catch (e) {
      print(e);
    }
  }

  void _handleSearchEnd() {
    /// Clear all input fields for search.
    setState(() {
      dropdownShowText = 'Tipo de Conteo';
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

  Future<List<ScoutTypes>> _getScoutTypeList() async {
    final response =
        await ScoutTypeCollectedListByPlotFromAPI.scoutTypeCollectedListByPlot(
            widget.plotId);
    if (response.statusCode == 200) {
      final items = json.decode(response.body)['scout_types'];
      List<ScoutTypes> listOfScoutTypes = items.map<ScoutTypes>((json) {
        return ScoutTypes.fromJson(json);
      }).toList();
      return listOfScoutTypes;
    } else {
      throw Exception('No se pudo cargar, no hay Internet');
    }
  }

  Widget _tcppDataAnalysisFilterResult() {
    /// Total Count per plot Data analysis filter Result widget builder
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
                                'Conteo  por hectarea.',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                              Text(
                                // 'Total count per plot'
                                'Nombre del campo: ${widget.farmName}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                'Nombre cuartel: ${widget.plotName}',
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
            return Center(
              child: Text(
                'Análisis de datos resumidos no disponible.',
              ),
            );
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
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
                                'Average Count.',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                              Text(
                                // 'Total count per plot'
                                'Nombre del campo: ${widget.farmName}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                'Nombre cuartel: ${widget.plotName}',
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
            return Center(
              child: Text(
                'Análisis de datos resumidos no disponible.',
              ),
            );
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text(''));
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
                                'Counts per Hectare.',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                              Text(
                                // 'Total count per plot'
                                'Nombre del campo: ${widget.farmName}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                'Nombre cuartel: ${widget.plotName}',
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
            return Center(
              child: Text(
                'Análisis de datos resumidos no disponible.',
              ),
            );
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
    totalCountPerPlotChartData();
    _getCphDataAnalysisSummary();

    newSeriesList = List<charts.Series<TotalCountPerPlotClassData, String>>();
    _seriesTcppAnalysisData = List<charts.Series<TcppAnalysisData, String>>();
    _seriesBarChartTcppAnalysisData =
        List<charts.Series<BarTcppAnalysisData, String>>();
    buildList = List<TotalCountPerPlotClassData>();
    _getScoutTypeList();
    _getScoutYearsListOnPlot();
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
                    child: FutureBuilder<List<ScoutYearsListOnPlotClass>>(
                        future: _getScoutYearsListOnPlot(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<ScoutYearsListOnPlotClass>>
                                snapshot) {
                          if (!snapshot.hasData)
                            return Text(
                              'Cargando años...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            );
                          return DropdownButton<ScoutYearsListOnPlotClass>(
                            items: snapshot.data
                                .map((scoutYearsData) =>
                                    DropdownMenuItem<ScoutYearsListOnPlotClass>(
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
                    child: FutureBuilder<List<ScoutTypes>>(
                        future: _getScoutTypeList(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<ScoutTypes>> snapshot) {
                          if (!snapshot.hasData)
                            return Text(
                              'Cargando tipo Scout...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            );
                          return DropdownButton<ScoutTypes>(
                            items: snapshot.data
                                .map((scoutTypeData) =>
                                    DropdownMenuItem<ScoutTypes>(
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
                                print(dropdownShowText);
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
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Tab(icon: Icon(Icons.data_usage)),
//                Tab(icon: Icon(Icons.pie_chart)),
                  Tab(icon: Icon(Icons.show_chart)),
                ],
              ),
            ),
//        backgroundColor: Colors.white,
            body: TabBarView(children: <Widget>[
              !_IsSearching
                  ? SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          FutureBuilder(
                            future: _getAverageCountDataAnalysisSummary(),
                            initialData: 'loading text...',
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  return Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5,
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
                                                    Text(
                                                      // 'Avergage Count'
                                                      'Nombre cuartel: ${widget.plotName}',
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets
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
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          10.0),
                                                                  child: Text(
                                                                    '${averageCountAnalysis[index]['type_of_scout__scout_type']}',
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
                                    child: Text(
                                      'Análisis de datos resumidos no disponible.',
                                    ),
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
                                                      'Conteo total por cuartel.',
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
                                                    Text(
                                                      'Nombre cuartel: ${widget.plotName}',
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          20.0),
                                                                  child: Text(
                                                                    '${numberFormatter.format(tcppAnalysis[index]['tcpp'])}',
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
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          10.0),
                                                                  child: Text(
                                                                    '${tcppAnalysis[index]['type_of_scout__scout_type']}',
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
                                    child: Text(
                                      'Análisis de datos resumidos no disponible.',
                                    ),
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
                                                      'Conteo por hectarea.',
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
                                                    Text(
                                                      'Nombre cuartel: ${widget.plotName}',
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          20.0),
                                                                  child: Text(
                                                                    '${numberFormatter.format(cphAnalysis[index]['counts_pha'])}',
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
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          10.0),
                                                                  child: Text(
                                                                    '${cphAnalysis[index]['type_of_scout__scout_type']}',
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
                                    child: Text(
                                      'Análisis de datos resumidos no disponible.',
                                    ),
                                  );
                                }
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
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
                          _tcppDataAnalysisFilterResult(),
                          _averageCountDataAnalysisFilterResult(),
                          _countsPerHaDataAnalysisFilterResult(),
                        ],
                      ),
                    ),
              Padding(
                padding: EdgeInsets.all(28.0),
                child: Column(
                  children: <Widget>[
                    Text('Total Count per plot - Bar Chart'),
                    SizedBox(
                      height: 0,
                    ),
                    Expanded(
                      child: Card(
                        child: charts.BarChart(
                          newSeriesList,
                          animate: true,
                          // Configure a stroke width to enable borders on the bars.
                          behaviors: [
                            new charts.SeriesLegend(
                                desiredMaxRows: 3, horizontalFirst: false),
                          ],
                          defaultRenderer: new charts.BarRendererConfig(
                            groupingType: charts.BarGroupingType.grouped,
                            strokeWidthPx: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
