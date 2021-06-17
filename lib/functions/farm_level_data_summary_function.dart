import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;

class GetFarmDataAnalysisSummaryAPI {
  static Future getFarmDataAnalysisSummaryData(farmId) async {
    var token = await getAuthToken();
    var orgId = await getOrganizationIDFromSF();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
//    var url = serverUrl +
//        '/api/v1.0/scout-analysis/farm-data-tcpp-cph/?farm_id=$farmId&org_id=$orgId';
    var url =
        '$serverUrl/api/v1.0/scout-analysis/org/$orgId/farm/$farmId/farm-view-calculation/';
    return http.get(url, headers: requestHeaders);
  }
}

class FilterFarmDataSummaryFromAPI {
  static Future filterFarmDataSummaryByYearAndScoutType(
      farmId, year, scoutType) async {
    var token = await getAuthToken();
    var orgId = await getOrganizationIDFromSF();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url =
        '$serverUrl/api/v1.0/scout-analysis/org/$orgId/farm/$farmId/farm-view-calculation-filter/?year=$year&scout_type=$scoutType';

    return http.get(url, headers: requestHeaders);
  }
}

/// Used as drop down on farm data summary filter
class FarmScoutType {
  int id;
  String scoutType;

  FarmScoutType({
    this.id,
    this.scoutType,
  });

  factory FarmScoutType.fromJson(Map<String, dynamic> json) {
    return FarmScoutType(
      id: json['id'],
      scoutType: json['scout_type'],
    );
  }
}

class ScoutYearsListOnFarmAPI {
  static Future scoutYearsListOnFarm(farmId) async {
    var token = await getAuthToken();
    var orgId = await getOrganizationIDFromSF();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url =
        '$serverUrl/api/v1.0/scouts/org/$orgId/farm/$farmId/plot/0/years/';

    return http.get(url, headers: requestHeaders);
  }
}

class ScoutYearsListOnFarmClass {
  String scoutYears;
  String count;

  ScoutYearsListOnFarmClass({
    this.scoutYears,
    this.count,
  });

  factory ScoutYearsListOnFarmClass.fromJson(Map<String, dynamic> json) {
    return ScoutYearsListOnFarmClass(
      count: json['dcount'].toString(),
      scoutYears: json['scouted_date__year'].toString(),
    );
  }
}
