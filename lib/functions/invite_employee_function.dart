import 'dart:async';
import 'dart:convert';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';
import 'package:agscoutapp/utilities/dialogue_alert_utilities.dart';

var serverUrl = Endpoints.serverUrl;

class InviteEmployeeAPI {
  static Future inviteEmployeeFunction(
    phoneNumber,
  ) async {
    var token = await getAuthToken();
    Map<String, String> requestBody = {
      'phone_number': phoneNumber,
    };
    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl + '/api/v1.0/org-profile/invite-employee/';
//    print(">>>> Request sent");
    var request = http.post(url, body: requestBody, headers: requestHeaders);
    return request;
  }
}
