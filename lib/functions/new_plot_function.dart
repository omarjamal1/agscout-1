import 'dart:async';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

var serverUrl = Endpoints.serverUrl;

class API {
  static Future createNewPlot(
    farmId,
    name,
    variety,
    area,
    centroDeCosto,
    plantsPerHectare,
    typeOfCrop,
  ) async {
    var token = await getAuthToken();
    Map<String, String> requestBody = {
      'farm': farmId.toString(),
      'name': name,
      'type_of_crop': typeOfCrop,
      'variety': variety,
      'area': area,
      'centro_de_costo': centroDeCosto,
      'plants_per_hectare': plantsPerHectare
    };
    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl + '/api/v1.0/plot/create/';
    return http.post(url, body: requestBody, headers: requestHeaders);
  }
}

class CropTypeAPI {
  static Future cropTypes() async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl + '/api/v1.0/crop-types/list/';
    return http.get(url, headers: requestHeaders);
  }
}

class CropType {
  int id;
  String cropType;

  CropType({
    this.id,
    this.cropType,
  });

  factory CropType.fromJson(Map<String, dynamic> json) {
    return CropType(
      id: json['id'],
      cropType: json['crop_type'],
    );
  }
}

class LoadCropType {
  static final String cropTypeId = 'cropTypeId';
  static final String cropTypeName = 'cropTypeName';
  static final String cropTypeCreatedDate = 'cropTypeCreatedDate';
  int id;
  String cropType;
  String createdDate;

  LoadCropType({
    this.id,
    this.cropType,
    this.createdDate,
  });

  Map toMap() {
    Map<String, dynamic> map = {
      cropTypeId: id,
      cropTypeName: cropType,
      cropTypeCreatedDate: createdDate,
    };
    return map;
  }

  factory LoadCropType.fromJson(Map<String, dynamic> json) {
    return LoadCropType(
      id: json['id'],
      cropType: json['crop_type'],
      createdDate: json['created_date'],
    );
  }
}
