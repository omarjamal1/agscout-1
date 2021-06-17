import 'dart:async';
import 'dart:convert';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/new_plot_function.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class CropTypeOfflineService {
  static const String KEY_LAST_FETCH = "last_fetch";
  static const int MILLISECONDS_IN_AN_HOUR = 360000;
  static const int REFRESH_THRESHOLD = 3 * MILLISECONDS_IN_AN_HOUR;
  bool hasInternetConnection = true;

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

  Future getCropTypeList() async {
    await checkInternetConnection();
    var response = await CropTypeAPI.cropTypes();
    try {
      if (response.statusCode == 200) {
        final items = json.decode(response.body)['data'];
        List<LoadCropType> listOfCropTypes = items.map<LoadCropType>((json) {
          return LoadCropType.fromJson(json);
        }).toList();

        if (hasInternetConnection == true) {
          var queryRow = await DatabaseHelper.instance.queryCropTypeAll();
//          print(">>> has internet $queryRow");
          if (queryRow.isNotEmpty) {
            await Future.delayed(Duration(seconds: 2), () {
              DatabaseHelper.instance.deleteCropTypeTable();
            });
            await Future.delayed(Duration(seconds: 4), () {
              insertCropTypeInDatabase(listOfCropTypes);
            });
          } else {
//          print(false);
            await insertCropTypeInDatabase(listOfCropTypes);
          }
        } // Else internet is off

        return listOfCropTypes;
      } else {
        throw Exception('No se pudo cargar, no hay Internet');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<int> insertCropTypeInDatabase(List<LoadCropType> items) async {
    // Drop table before another insert
    var queryRow = await DatabaseHelper.instance.queryCropTypeAll();

    items.forEach((items) async {
      int cropType = await DatabaseHelper.instance.insertCropType({
        DatabaseHelper.cropTypeId: items.id,
        DatabaseHelper.cropType: items.cropType,
        DatabaseHelper.cropTypeCreatedDate: items.createdDate,
      });
    });
  }

  checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      hasInternetConnection = false;
    }

    return connectivityResult;
  }

  updateLastFetchTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(
        KEY_LAST_FETCH, DateTime.now().millisecondsSinceEpoch);
  }
}
