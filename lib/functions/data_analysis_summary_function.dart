import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;
//var localhost = Endpoints.localhost;

// Data analysis api for plot.
class GetDataAnalysisSummaryAPI {
  static Future getDataAnalysisSummaryData(plotId) async {
    var token = await getAuthToken();
    var orgId = await getOrganizationIDFromSF();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl +
        '/api/v1.0/scout-analysis/data-tcpp-cph/?plot_id=$plotId&org_id=$orgId';
    return http.get(url, headers: requestHeaders);
  }
}

class TcppAnalysisData {
  String type;
  double tcppData;
//  final Color dataColor;

  TcppAnalysisData({
    this.type,
    this.tcppData,
//    this.dataColor,
  });
}

class BarTcppAnalysisData {
  String type;
  double tcppData;
//  final Color dataColor;

  BarTcppAnalysisData({
    this.type,
    this.tcppData,
//    this.dataColor,
  });
}

class BarAverageCountAnalysisData {
  String type;
  double averageCountData;
//  final Color dataColor;

  BarAverageCountAnalysisData({
    this.type,
    this.averageCountData,
//    this.dataColor,
  });
}

class ScoutYearsListOnPlotAPI {
  static Future scoutYearsListOnPlot(plotId) async {
    var token = await getAuthToken();
    var orgId = await getOrganizationIDFromSF();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url =
        '$serverUrl/api/v1.0/scouts/org/$orgId/farm/0/plot/$plotId/years/';

    return http.get(url, headers: requestHeaders);
  }
}

class ScoutYearsListOnPlotClass {
  String scoutYears;
  String count;

  ScoutYearsListOnPlotClass({
    this.scoutYears,
    this.count,
  });

  factory ScoutYearsListOnPlotClass.fromJson(Map<String, dynamic> json) {
    return ScoutYearsListOnPlotClass(
      count: json['dcount'].toString(),
      scoutYears: json['scouted_date__year'].toString(),
    );
  }
}
