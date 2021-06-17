import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;

class API {
  static Future loginAPIFunction(
    phoneNumber,
    password,
  ) async {
    var token = await getAuthToken();
    Map<String, String> requestBody = {
      'phone_number': phoneNumber,
      'password': password,
    };

    var url = serverUrl + '/api/v1.0/plot/create/';
    return http.post(url, body: requestBody);
  }
}

// Code Not used yet.
