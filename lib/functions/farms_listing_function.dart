import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;
//var localhost = Endpoints.localhost;

class FarmAPI {
  static Future getFarms() async {
    var orgId = await getOrganizationIDFromSF();
    print(orgId);
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
      'Content-Type': 'multipart/form-data'
    };
    var url = serverUrl + '/api/v1.0/farm/listing/?org_id=$orgId';
    return http.get(url, headers: requestHeaders);
  }
}

// Class to Hold farm queue data
class FarmDataTable {
  static final String farmDataId = 'farmDataId';
  static final String farmOrgId = 'farmOrgId';
  static final String farmName = 'farmName';
  static final String farmLocation = 'farmLocation';
  static final String farmCreatedDate = 'farmCreatedDate';

  String farmId;
  String organization;
  String name;
  String location;
  String createdDate;
  String plotCount;

  FarmDataTable({
    this.farmId,
    this.organization,
    this.name,
    this.location,
    this.createdDate,
    this.plotCount,
  });

  // Data to Map
  Map toMap() {
    Map<String, dynamic> map = {
      farmOrgId: organization,
      farmName: name,
      farmLocation: location,
      farmCreatedDate: createdDate
    };
    return map;
  }

  factory FarmDataTable.fromJson(Map<String, dynamic> json) {
    return FarmDataTable(
      farmId: json['id'].toString(),
      organization: json['organization'].toString(),
      name: json['name'],
      location: json['location'],
      createdDate: json['created_date'],
      plotCount: json['plot_count'].toString(),
    );
  }
}
