import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;

class PlotAPI {
  static Future plotListing(farmId) async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
      // 'Content-Type': 'multipart/form-data'
    };
    var url = serverUrl + '/api/v1.0/plot/listing/?farm_id=$farmId';
    return http.get(url, headers: requestHeaders);
  }
}

class PlotDetailAPI {
  static Future plotDetail(plotId) async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    Map<String, String> requestBody = {
      'plot_id': plotId.toString(),
    };
    var url = serverUrl + '/api/v1.0/plot/detail?plot_id=$plotId';
    return http.get(url, headers: requestHeaders);
  }
}

// Class to Hold  Plot data
class PlotDataTable {
  String plotFarmId;
  String plotId;
  String plotName;
  String cropTypeName;
  String variety;
  String area;
  String centroDeCosto;
  String plantPerHectare;
  String user;
  String cropScoutCount;
  String createdDate;

  PlotDataTable({
    this.plotFarmId,
    this.plotId,
    this.plotName,
    this.cropTypeName,
    this.variety,
    this.area,
    this.centroDeCosto,
    this.plantPerHectare,
    this.cropScoutCount,
    this.createdDate,
  });

  factory PlotDataTable.fromJson(Map<String, dynamic> json) {
    return PlotDataTable(
      plotFarmId: json['farm'].toString(),
      plotId: json['id'].toString(),
      plotName: json['name'],
      cropTypeName: json['crop_type_name'],
      variety: json['variety'],
      area: json['area'].toString(),
      plantPerHectare: json['plants_per_hectare'].toString(),
      centroDeCosto: json['centro_de_costo'],
      cropScoutCount: json['crop_scout_count'].toString(),
      createdDate: json['created_date'].toString(),
    );
  }
}

//class PlotAPIOnMap {
//  static Future getPlotIds() async {
//    var token = await getAuthToken();
//
//    Map<String, String> requestHeaders = {
//      'Authorization': 'Token $token',
//      'Content-Type': 'multipart/form-data'
//    };
//    var url = serverUrl + '/api/v1.0/plot/listing/';
//    return http.get(url, headers: requestHeaders);
//  }
//}
