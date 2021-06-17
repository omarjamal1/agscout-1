import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;

class CropsOnFarmMapCoordinatesAPI {
  static Future cropsOnFarmMapCoordinates(farmId) async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl +
        '/api/v1.0/crop-scout/location-cordinates-by-farm/?farm_id=$farmId';
    return http.get(url, headers: requestHeaders);
  }
}
