import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;
//var localhost = Endpoints.localhost;

class CropSearchOnMapAPI {
  static Future cropSearchOnMapData(orgId, year, scoutType) async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl +
        '/api/v1.0/search-scout/by-year-and-scout-type/?org_id=$orgId&year=$year&scout_type=$scoutType';

    return http.get(url, headers: requestHeaders);
  }
}

class ChipChoiceCropSearchOnMapAPI {
  static Future cropSearchOnMapData(orgId, scoutType) async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl +
        '/api/v1.0/search-scout/by-year-and-scout-type/?org_id=$orgId&scout_type=$scoutType';
    return http.get(url, headers: requestHeaders);
  }
}

class ScoutTypeCollectedListFromAPI {
  static Future scoutTypeCollectedList(orgId) async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl +
        '/api/v1.0/crop-scout-types/collected-during-scouting/?org_id=$orgId';
    return http.get(url, headers: requestHeaders);
  }
}

class ScoutTypeCollectedList {
  final scoutTypes;
  final count;
  ScoutTypeCollectedList({this.scoutTypes, this.count});
  factory ScoutTypeCollectedList.fromJson(Map<String, dynamic> json) {
    return ScoutTypeCollectedList(
        scoutTypes: json['type_of_scout__scout_type'], count: json['dcount']);
  }
}
