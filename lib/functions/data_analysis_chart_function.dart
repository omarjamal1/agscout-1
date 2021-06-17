import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;
//var localhost = Endpoints.localhost;

class GetChartDataAPI {
  static Future getChartData(plotId) async {
    var token = await getAuthToken();
    var orgId = await getOrganizationIDFromSF();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl +
        '/api/v1.0/scout-analysis/chart-data/?plot_id=$plotId&org_id=$orgId';
    return http.get(url, headers: requestHeaders);
  }
}

//import 'dart:convert';
//
//import 'package:agscoutapp/helpers/chart_helpers.dart';
//import 'package:flutter/material.dart';
//import 'data_analysis_summary_function.dart';
//import 'package:charts_flutter/flutter.dart' as charts;
//
///// Example of a grouped bar chart with three series, each rendered with
///// different fill colors.
//
///// Sample ordinal data type.
//
///// Create series list with multiple series
////  _createSampleData() {
//////    averageCountAnalysis.forEach((element) {
////    final desktopSalesData = [
////      new OrdinalSales('2014', 5),
////      new OrdinalSales('2015', 25),
////      new OrdinalSales('2016', 100),
////      new OrdinalSales('2017', 75),
////    ];
////    final tableSalesData = [
////      new OrdinalSales('2014', 25),
////      new OrdinalSales('2015', 50),
////      new OrdinalSales('2016', 10),
////      new OrdinalSales('2017', 20),
////    ];
////
////    final mobileSalesData = [
////      new OrdinalSales('2014', 10),
////      new OrdinalSales('2015', 50),
////      new OrdinalSales('2016', 50),
////      new OrdinalSales('2017', 45),
////    ];
//////    });
////    newSeriesList.add(
////      charts.Series(
////        id: 'Desktop',
////        domainFn: (OrdinalSales sales, _) => sales.year,
////        measureFn: (OrdinalSales sales, _) => sales.sales,
////        data: desktopSalesData,
////        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
////        fillColorFn: (_, __) =>
////            charts.MaterialPalette.blue.shadeDefault.lighter,
////      ),
////    );
////    newSeriesList.add(
////      charts.Series(
////        id: 'Tablet',
////        measureFn: (OrdinalSales sales, _) => sales.sales,
////        data: tableSalesData,
////        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
////        domainFn: (OrdinalSales sales, _) => sales.year,
////      ),
////    );
////    newSeriesList.add(
////      charts.Series(
////        id: 'Mobile',
////        domainFn: (OrdinalSales sales, _) => sales.year,
////        measureFn: (OrdinalSales sales, _) => sales.sales,
////        data: mobileSalesData,
////        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
////        fillColorFn: (_, __) => charts.MaterialPalette.transparent,
////      ),
////    );
////    return [
////      // Blue bars with a lighter center color.
////      new charts.Series<OrdinalSales, String>(
////        id: 'Desktop',
////        domainFn: (OrdinalSales sales, _) => sales.year,
////        measureFn: (OrdinalSales sales, _) => sales.sales,
////        data: desktopSalesData,
////        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
////        fillColorFn: (_, __) =>
////            charts.MaterialPalette.blue.shadeDefault.lighter,
////      ),
////      // Solid red bars. Fill color will default to the series color if no
////      // fillColorFn is configured.
////      new charts.Series<OrdinalSales, String>(
////        id: 'Tablet',
////        measureFn: (OrdinalSales sales, _) => sales.sales,
////        data: tableSalesData,
////        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
////        domainFn: (OrdinalSales sales, _) => sales.year,
////      ),
////      // Hollow green bars.
////      new charts.Series<OrdinalSales, String>(
////        id: 'Mobile',
////        domainFn: (OrdinalSales sales, _) => sales.year,
////        measureFn: (OrdinalSales sales, _) => sales.sales,
////        data: mobileSalesData,
////        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
////        fillColorFn: (_, __) => charts.MaterialPalette.transparent,
////      ),
////    ];
//
////Future averageCountData(plotId) async {
////  var averageCountData =
////  await GetDataAnalysisSummaryAPI.getDataAnalysisSummaryData(plotId);
////  averageCountAnalysis = json.decode(averageCountData.body)['average_count'];
////  print(" >>>>>>>>> $averageCountAnalysis");
////  if (averageCountAnalysis !=null) {
////    averageCountAnalysis.forEach((element) {
////      var desktopSalesData = [
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 25.0, year: '2015'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 100.0, year: '2016'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 75.0, year: '2017'),
////      ];
////      var tableSalesData = [
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////      ];
////
////      var mobileSalesData = [
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////        new AverageCountAnalysisData(type: 'CropType', averageCount: 5.0, year: '2018'),
////      ];
////      newSeriesList.add(
////        charts.Series(
////          id: 'Desktop',
////          domainFn: (AverageCountAnalysisData avgCountData, _) => avgCountData.year,
////          measureFn: (AverageCountAnalysisData avgCountData, _) => avgCountData.averageCount,
////          data: desktopSalesData,
////          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
////          fillColorFn: (_, __) =>
////          charts.MaterialPalette.blue.shadeDefault.lighter,
////        ),
////      );
////      newSeriesList.add(
////        charts.Series(
////          id: 'Tablet',
////          measureFn: (AverageCountAnalysisData avgCountData, _) => avgCountData.averageCount,
////          data: tableSalesData,
////          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
////          domainFn: (AverageCountAnalysisData sales, _) => sales.year,
////        ),
////      );
////      newSeriesList.add(
////        charts.Series(
////          id: 'Mobile',
////          domainFn: (AverageCountAnalysisData avgCountData, _) => avgCountData.year,
////          measureFn: (AverageCountAnalysisData avgCountData, _) => avgCountData.averageCount,
////          data: mobileSalesData,
////          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
////          fillColorFn: (_, __) => charts.MaterialPalette.transparent,
////        ),
////      );
////    });
////  }
////  return averageCountAnalysis;
////}
//
//class OrdinalSales {
//  final String year;
//  final int sales;
//
//  OrdinalSales(this.year, this.sales);
//}
//
//class AverageCountChart extends StatefulWidget {
//  @override
//  _AverageCountChartState createState() => _AverageCountChartState();
//}
//
//class _AverageCountChartState extends State<AverageCountChart> {
//  List averageCountAnalysis;
//  String plotId;
//  List<charts.Series<OrdinalSales, String>> newSeriesList;
//  bool animate;
//  Future averageCountData(plotId) async {
//    var averageCountData =
//        await GetDataAnalysisSummaryAPI.getDataAnalysisSummaryData(plotId);
//    averageCountAnalysis = json.decode(averageCountData.body)['average_count'];
//    print(" >>>>>>>>> $averageCountAnalysis");
//    if (averageCountAnalysis != null) {
//      averageCountAnalysis.forEach((element) {
//        final desktopSalesData = [
//          new OrdinalSales('2014', 5),
//          new OrdinalSales('2015', 25),
//          new OrdinalSales('2016', 100),
//          new OrdinalSales('2017', 75),
//        ];
//        final tableSalesData = [
//          new OrdinalSales('2014', 25),
//          new OrdinalSales('2015', 50),
//          new OrdinalSales('2016', 10),
//          new OrdinalSales('2017', 20),
//        ];
//
//        final mobileSalesData = [
//          new OrdinalSales('2014', 10),
//          new OrdinalSales('2015', 50),
//          new OrdinalSales('2016', 50),
//          new OrdinalSales('2017', 45),
//        ];
//        newSeriesList.add(
//          charts.Series(
//            id: 'Desktop',
//            domainFn: (OrdinalSales sales, _) => sales.year,
//            measureFn: (OrdinalSales sales, _) => sales.sales,
//            data: desktopSalesData,
//            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//            fillColorFn: (_, __) =>
//                charts.MaterialPalette.blue.shadeDefault.lighter,
//          ),
//        );
//        newSeriesList.add(
//          charts.Series(
//            id: 'Tablet',
//            measureFn: (OrdinalSales sales, _) => sales.sales,
//            data: tableSalesData,
//            colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
//            domainFn: (OrdinalSales sales, _) => sales.year,
//          ),
//        );
//        newSeriesList.add(
//          charts.Series(
//            id: 'Mobile',
//            domainFn: (OrdinalSales sales, _) => sales.year,
//            measureFn: (OrdinalSales sales, _) => sales.sales,
//            data: mobileSalesData,
//            colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
//            fillColorFn: (_, __) => charts.MaterialPalette.transparent,
//          ),
//        );
//      });
//    }
//    return averageCountAnalysis;
//  }
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//    newSeriesList = List<charts.Series<OrdinalSales, String>>();
//    averageCountData(plotId);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new charts.BarChart(
//      newSeriesList,
//      animate: animate,
//      // Configure a stroke width to enable borders on the bars.
//      behaviors: [
//        new charts.SeriesLegend(),
//      ],
//      defaultRenderer: new charts.BarRendererConfig(
//        groupingType: charts.BarGroupingType.grouped,
//        strokeWidthPx: 2.0,
//      ),
//    );
//  }
//}

class ScoutTypeCollectedListByPlotFromAPI {
  static Future scoutTypeCollectedListByPlot(plotId) async {
    var token = await getAuthToken();
    var orgId = await getOrganizationIDFromSF();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl +
        '/api/v1.0/crop-scout-types/collected-during-scouting-by-plot/?org_id=$orgId&plot_id=$plotId';
    return http.get(url, headers: requestHeaders);
  }
}

class ScoutTypeCollectedListByPlot {
  final scoutTypes;
  final count;
  ScoutTypeCollectedListByPlot({this.scoutTypes, this.count});
  factory ScoutTypeCollectedListByPlot.fromJson(Map<String, dynamic> json) {
    return ScoutTypeCollectedListByPlot(
        scoutTypes: json['type_of_scout__scout_type'], count: json['dcount']);
  }
}

class ScoutTypes {
  int id;
  final count;
  String scoutType;

  ScoutTypes({
    this.id,
    this.count,
    this.scoutType,
  });

  factory ScoutTypes.fromJson(Map<String, dynamic> json) {
    return ScoutTypes(
      id: json['type_of_scout__id'],
      count: json['dcount'],
      scoutType: json['type_of_scout__scout_type'],
    );
  }
}

class FilterDataSummaryFromAPI {
  static Future filterDataSummaryByYearAndScoutType(
      plotId, year, scoutType) async {
    var token = await getAuthToken();
    var orgId = await getOrganizationIDFromSF();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl +
        '/api/v1.0/scout-analysis/filter-data-tcpp-cph/?plot_id=$plotId&org_id=$orgId&year=$year&scout_type=$scoutType';

    return http.get(url, headers: requestHeaders);
  }
}
