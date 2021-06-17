import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;
Dio dio = new Dio();

class GetOrganizationDataCountAPI {
  static Future getOrganizationDataCount() async {
    var orgProfileId = await getOrganizationIDFromSF();

    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
      'Content-Type': 'multipart/form-data'
    };
    var url = '$serverUrl/api/v1.0/org-data-count/summary?org_id=$orgProfileId';
    return http.get(url, headers: requestHeaders);
  }
}

class GetOrganizationProfileAPI {
  static Future getOrganizationProfile() async {
    var orgProfileId = await getOrganizationIDFromSF();

    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
      'Content-Type': 'multipart/form-data'
    };
    var url =
        '$serverUrl/api/v1.0/org-profile/my-profile?profile_id=$orgProfileId';
    return http.get(url, headers: requestHeaders);
  }
}

class UpdateOrganizationProfileAPI {
  static Future updateOrganizationProfile(
      name, location, address, email, logo) async {
    var orgProfileId = await getOrganizationIDFromSF();

    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
      'Content-Type': 'multipart/form-data'
    };
    FormData formData = new FormData();
    formData = FormData.fromMap({
      'name': name,
      'location': location,
      'current_address': address,
      'email': email,
      'organization_logo': logo
    });
    Response response = await dio.post(
      '$serverUrl/api/v1.0/org-profile/update/?profile_id=$orgProfileId',
      data: formData,
      options:
          Options(headers: requestHeaders, contentType: 'multipart/form-data'),
    );

    return response;
  }
}
