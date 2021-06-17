import 'dart:async';
import 'dart:convert';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/crop_scout_function.dart';
import 'package:agscoutapp/functions/new_plot_function.dart';
import 'package:agscoutapp/utilities/check-internet-connection.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ScoutTypeOfflineService {
  final dbHelper = DatabaseHelper.instance;
  static const String KEY_LAST_FETCH = "scout_type_last_fetch";
  static const int MILLISECONDS_IN_AN_HOUR = 360000;
  static const int REFRESH_THRESHOLD = 3 * MILLISECONDS_IN_AN_HOUR;
  bool hasInternetConnection = true;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static Future<bool> _shouldRefreshCropTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastFetchTime = prefs.getInt(KEY_LAST_FETCH);

    // Definitely refresh db because we don't have a last fetch time.
    if (lastFetchTime == null) {
      return true;
    }
    // If last fetch time is also more than 3hrs, return true: refresh db
    return ((new DateTime.now().millisecondsSinceEpoch - lastFetchTime) >
        REFRESH_THRESHOLD);
  }

//  Future<List<LoadCropType>> _getScoutTypeList() async {
//    var response = await CropTypeAPI.cropTypes();
//    print(">>>>>> Response ${response.statusCode}");
//    if (response.statusCode == 200) {
//      final items = json.decode(response.body)['data'];
//      List<LoadCropType> listOfCropTypes = items.map<LoadCropType>((json) {
//        return LoadCropType.fromJson(json);
//      }).toList();
//
//      // Remove this query row. not using
//      var queryRow = await DatabaseHelper.instance.queryCropTypeAll();
//      print(queryRow);
//      return listOfCropTypes;
//    } else {
//      throw Exception('No se pudo cargar, no hay Internet');
//    }
//  }

  Future getScoutTypeList() async {
    hasInternetConnection = await checkInternetConnection();
    var response = await ScoutTypeAPI.scoutTypes();
    try {
      if (response.statusCode == 200) {
        final items = json.decode(response.body)['data'];

        List<LoadScoutType> listOfScoutTypes = items.map<LoadScoutType>((json) {
          return LoadScoutType.fromJson(json);
        }).toList();
//        var queryRow = await DatabaseHelper.instance.queryScoutTypeAll();

//        if (hasInternetConnection == true) {
//          if (queryRow.isEmpty) {
//            await insertScoutTypeInDatabase(listOfScoutTypes);
//          } else {
        await DatabaseHelper.instance.deleteScoutTypeContent();
        await insertScoutTypeInDatabase(listOfScoutTypes);

//            await DatabaseHelper.instance.deleteScoutTypeTable();
//            await Future.delayed(Duration(seconds: 2), () {
//              insertScoutTypeInDatabase(listOfScoutTypes);
//            });
//          }
//        } // Else internet is off

        return listOfScoutTypes;
      } else {
        throw Exception('No se pudo cargar, no hay Internet');
      }
    } catch (e) {
      print(e);
    }
  }

  Future insertScoutTypeInDatabase(List<LoadScoutType> items) async {
    items.forEach((items) async {
      int cropType = await DatabaseHelper.instance.insertScoutType({
        DatabaseHelper.scoutTypeId: items.id,
        DatabaseHelper.scoutType: items.scoutType,
        DatabaseHelper.scoutTypeCreatedDate: items.createdDate,
      });
      return cropType;
    });
  }

  updateLastFetchTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(
        KEY_LAST_FETCH, DateTime.now().millisecondsSinceEpoch);
  }
}
