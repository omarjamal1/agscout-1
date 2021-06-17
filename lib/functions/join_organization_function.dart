import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;

class API {
  static Future joinOrganizationWithCodeFunction(
    organizationCode,
  ) async {
    var token = await getAuthToken();
    Map<String, String> requestBody = {
      'organization_code': organizationCode,
    };
    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl + '/api/v1.0/org-profile/join-organization/';
    return http.post(url, body: requestBody, headers: requestHeaders);
  }
}
