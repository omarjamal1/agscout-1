import 'dart:async';
import 'dart:convert';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/data_models/FarmDatabaseHelper.dart';
import 'package:agscoutapp/functions/api_urls.dart';
import 'package:agscoutapp/functions/farms_listing_function.dart';
import 'package:agscoutapp/functions/new_plot_function.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class FarmOfflineService {
  final dbHelper = DatabaseHelper.instance;
  static const String KEY_LAST_FETCH = "last_fetch";
  static const int MILLISECONDS_IN_AN_HOUR = 360000;
  static const int REFRESH_THRESHOLD = 3 * MILLISECONDS_IN_AN_HOUR;
  bool hasInternetConnection = true;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static Future<bool> _shouldRefreshFarmData() async {
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

  Future getFarmFromLocalDB() async {
    await checkInternetConnection();
    var response = await FarmAPI.getFarms();
    try {
      if (response.statusCode == 200) {
        final items = json.decode(response.body)['data'];
        List<FarmDataTable> listOfFarmsData = items.map<FarmDataTable>((json) {
          return FarmDataTable.fromJson(json);
        }).toList();
//        var queryRow = await DatabaseHelper.instance.queryFarmAll();
//        if (hasInternetConnection == true) {
        await DatabaseHelper.instance.deleteFarmContent().then((_) async {
          await insertFarmFromApiToLocalDatabase(listOfFarmsData);
        });
//        }
        return listOfFarmsData;
      } else {
        // logic if interenet is off
      }
    } catch (e) {
      print(e);
    }
  }

  insertFarmFromApiToLocalDatabase(List<FarmDataTable> items) async {
    // Drop table before another insert

    items.forEach((items) async {
//      await Future.delayed(Duration(seconds: 1), () {
      DatabaseHelper.instance.insertFarmData({
        DatabaseHelper.farmId: items.farmId,
        DatabaseHelper.farmOrgId: items.organization,
        DatabaseHelper.farmName: items.name,
        DatabaseHelper.farmLocation: items.location,
        DatabaseHelper.plotCount: items.plotCount,
        DatabaseHelper.farmCreatedDate: items.createdDate,
      });
//      });
    });
  }

  Future clearFarmDBForNewSync() async {
    var queryRow = await DatabaseHelper.instance.queryFarmAll();
    if (queryRow.isNotEmpty) {
//      await Future.delayed(Duration(seconds: 2), () {
      DatabaseHelper.instance.deleteFarmTable();
//      });
    }
  }

  checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      hasInternetConnection = false;
    }

    return connectivityResult;
  }

  // Not using yet
  updateLastFetchTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(
        KEY_LAST_FETCH, DateTime.now().millisecondsSinceEpoch);
  }
}
