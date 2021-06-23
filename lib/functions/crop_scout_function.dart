import 'dart:async';
import 'package:agscoutapp/utilities/check-internet-connection.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:agscoutapp/functions/api_urls.dart';

Dio dio = new Dio();
FormData formData = new FormData();
var serverUrl = Endpoints.serverUrl;

class ScoutTypeAPI {
  static Future scoutTypes() async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl + '/api/v1.0/crop-scout-types/list/';
    return http.get(url, headers: requestHeaders);
  }
}

class NewCropScoutAPI {
  static Future createNewCropScout(
    plot,
    typeOfScout,
    rowNumber,
    plantNumber,
    numberOfLaterals,
    numberOfBranches,
    countNumber,
    cropImage,
    lat,
    lon,
    accuracyLevel,
    scoutDate,
  ) async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
//          'Accept': 'application/json',
      'Authorization': 'Token $token',
    };
    formData = FormData.fromMap({
      'plot': plot,
      'type_of_scout': typeOfScout,
      'row_number': rowNumber,
      'plant_number': plantNumber,
      'number_of_laterals': numberOfLaterals,
      'number_of_branches': numberOfBranches,
      'number_of_counts': countNumber,
      'crop_image': cropImage,
      'lat': lat,
      'lon': lon,
      'accuracy': accuracyLevel,
      'scouted_date': scoutDate,
    });
    print(">>>>>>>>>>>>> Response form data ${formData.fields}");

//    try {
//      if (checkInternetConnection() == true) {
    Response response = await dio.post(
      serverUrl + '/api/v1.0/crop-scout/new/',
      data: formData,
      options: Options(headers: requestHeaders),
    );
    print(">>>>>>>>>>>>> Response content ${response.statusMessage}");
    return response;
//      } else {
//        print("no Internet connection");
//      }
//    } catch (e) {
//      print(e);
//    }
  }
}

class CropScoutAPI {
  static Future cropScoutListing(plotId) async {
    var token = await getAuthToken();

    Map<String, String> requestHeaders = {
      'Authorization': 'Token $token',
    };
    var url = serverUrl + '/api/v1.0/crop-scout/list/?plot_id=$plotId';
    return http.get(url, headers: requestHeaders);
  }
}

class ScoutTypeDropDown {
  int id;
  String type;
  ScoutTypeDropDown(this.id, this.type);
}

class ScoutType {
//  static final String scoutTypeId = 'scoutTypeId';
//  static final String scoutTypeName = 'scoutType';
//  static final String scoutTypeCreatedDate = 'scoutTypeCreatedDate';

  int id;
  String scoutType;
  String createdDate;

  ScoutType({
    this.id,
    this.scoutType,
    this.createdDate,
  });

//  Map toMap() {
//    Map<String, dynamic> map = {
//      scoutTypeId: id,
//      scoutTypeName: scoutType,
//      scoutTypeCreatedDate: createdDate,
//    };
//    return map;
//  }

  factory ScoutType.fromJson(Map<String, dynamic> json) {
    return ScoutType(
      id: json['_scoutTypeId'],
      scoutType: json['scoutType'],
      createdDate: json['scoutTypeCreatedDate'],
    );
  }
}

// class to hold scout type from api.
class LoadScoutType {
  static final String scoutTypeId = 'scoutTypeId';
  static final String scoutTypeName = 'scoutType';
  static final String scoutTypeCreatedDate = 'scoutTypeCreatedDate';
  int id;
  String scoutType;
  String createdDate;

  LoadScoutType({
    this.id,
    this.scoutType,
    this.createdDate,
  });

  Map toMap() {
    Map<String, dynamic> map = {
      scoutTypeId: id,
      scoutTypeName: scoutType,
      scoutTypeCreatedDate: createdDate,
    };
    return map;
  }

  factory LoadScoutType.fromJson(Map<String, dynamic> json) {
    return LoadScoutType(
      id: json['id'],
      scoutType: json['scout_type'],
      createdDate: json['created_date'],
    );
  }
}

// class to hold scout type from api.
class ScoutData {
  static final String scoutId = 'scoutId';
  static final String scoutPlotId = 'scoutPlotId';
  static final String scoutPlotName = 'scoutPlotName';
  static final String typeOfScout = 'typeOfScout';
  static final String scoutRowNumber = 'scoutRowNumber';
  static final String scoutPlantNumber = 'scoutPlantNumber';
  static final String scoutNumberOfLaterals = 'scoutNumberOfLaterals';
  static final String scoutNumberOfBranches = 'scoutNumberOfBranches';
  static final String scoutCountNumber = 'scoutCountNumber';
  static final String scoutCropImage = 'scoutCropImage';
  static final String scoutLat = 'scoutLat';
  static final String scoutLon = 'scoutLon';
  static final String scoutAccuracyLevel = 'scoutAccuracyLevel';
  static final String scoutPersonName = 'scoutPersonName';
  static final String scoutingDate = 'scoutingDate';

  String id;
  String plotId;
  String plotName;
  String scoutType;
  String rowNumber;
  String plantNumber;
  String numberOfLaterals;
  String numberOfBranches;
  String countNumber;
  String cropImage;
  String lat;
  String lon;
  String accuracyLevel;
  String scouter;
  String scoutDate;

  ScoutData({
    this.id,
    this.plotId,
    this.plotName,
    this.scoutType,
    this.rowNumber,
    this.plantNumber,
    this.numberOfLaterals,
    this.numberOfBranches,
    this.countNumber,
    this.cropImage,
    this.lat,
    this.lon,
    this.accuracyLevel,
    this.scouter,
    this.scoutDate,
  });

  Map toMap() {
    Map<String, dynamic> map = {
      scoutId: id,
      scoutPlotId: plotId,
      scoutPlotName: plotName,
      typeOfScout: scoutType,
      scoutRowNumber: rowNumber,
      scoutPlantNumber: plantNumber,
      scoutNumberOfLaterals: numberOfLaterals,
      scoutNumberOfBranches: numberOfBranches,
      scoutCountNumber: countNumber,
      scoutCropImage: cropImage,
      scoutLat: lat,
      scoutLon: lon,
      scoutAccuracyLevel: accuracyLevel,
      scoutPersonName: scouter,
      scoutingDate: scoutDate,
    };
    return map;
  }

  factory ScoutData.fromJson(Map<String, dynamic> json) {
    return ScoutData(
      id: json['id'].toString(),
      plotId: json['plot'].toString(),
      plotName: json['plot_name'],
      scoutType: json['type_of_scout_name'],
      rowNumber: json['row_number'].toString(),
      plantNumber: json['plant_number'].toString(),
      numberOfLaterals: json['number_of_laterals'].toString(),
      numberOfBranches: json['number_of_branches'].toString(),
      countNumber: json['number_of_counts'].toString(),
      cropImage: json['crop_image'],
      lat: json['lat'].toString(),
      lon: json['lon'].toString(),
      accuracyLevel: json['accuracy'].toString(),
      scouter: json['scouter'],
      scoutDate: json['created_date'],
    );
  }
}
