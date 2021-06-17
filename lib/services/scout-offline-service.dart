import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/api_urls.dart';
import 'package:agscoutapp/functions/crop_scout_function.dart';
import 'package:agscoutapp/functions/farms_listing_function.dart';
import 'package:agscoutapp/functions/new_plot_function.dart';
import 'package:agscoutapp/utilities/check-internet-connection.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class ScoutOfflineService {
  final dbHelper = DatabaseHelper.instance;
  static const String KEY_LAST_FETCH = "last_fetch";
  static const int MILLISECONDS_IN_AN_HOUR = 360000;
  static const int REFRESH_THRESHOLD = 3 * MILLISECONDS_IN_AN_HOUR;
  bool hasInternetConnection = true;
  File _image;
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

  addNewScoutToLocalDBAndQueueTable(
      plotId,
      typeOfScout,
      rowNumber,
      plantNumber,
      numberOfLaterals,
      numberOfBranches,
      numberOfCounts,
      cropImage,
      lat,
      lon,
      accuracy,
      scoutDate) async {
    if (hasInternetConnection) {
      int scoutQueueDbTable =
          await DatabaseHelper.instance.insertScoutDataToQueue({
        DatabaseHelper.scoutPlotId: plotId,
        DatabaseHelper.typeOfScout: typeOfScout,
        DatabaseHelper.rowNumber: rowNumber,
        DatabaseHelper.plantNumber: plantNumber,
        DatabaseHelper.numberOfLaterals: numberOfLaterals,
        DatabaseHelper.numberOfBranches: numberOfBranches,
        DatabaseHelper.numberOfCounts: numberOfCounts,
        DatabaseHelper.cropImage: cropImage,
        DatabaseHelper.lat: lat,
        DatabaseHelper.lon: lon,
        DatabaseHelper.accuracy: accuracy,
        DatabaseHelper.scoutedDate: scoutDate,
      });
      int scoutDbTable = await DatabaseHelper.instance.insertScoutData({
        DatabaseHelper.scoutPlotId: plotId,
        DatabaseHelper.typeOfScout: typeOfScout,
        DatabaseHelper.rowNumber: rowNumber,
        DatabaseHelper.plantNumber: plantNumber,
        DatabaseHelper.numberOfLaterals: numberOfLaterals,
        DatabaseHelper.numberOfBranches: numberOfBranches,
        DatabaseHelper.numberOfCounts: numberOfCounts,
        DatabaseHelper.cropImage: cropImage,
        DatabaseHelper.lat: lat,
        DatabaseHelper.lon: lon,
        DatabaseHelper.accuracy: accuracy,
        DatabaseHelper.scoutedDate: scoutDate,
      });
      return scoutQueueDbTable;
    }
  }

  uploadScoutQueueDataToAPI() async {
    /// Upload saved data in queue to server
    /* Check if has internet connection
    check if Queue table is not empty
    Upload data from queue table to api
    If response is 201(Created)
      Delete the object in the queue table
    */
    if (hasInternetConnection) {
      var queryQueueRow =
          await DatabaseHelper.instance.queryAllDataScoutLocalQueueTable();
      if (queryQueueRow.isNotEmpty) {
        queryQueueRow.forEach((element) async {
          var response = await NewCropScoutAPI.createNewCropScout(
              element['scoutPlotId'],
              element['typeOfScout'],
              element['rowNumber'],
              element['plantNumber'],
              element['numberOfLaterals'],
              element['numberOfBranches'],
              element['numberOfCounts'],
              element['cropImage'] != null
                  ? await MultipartFile.fromFile(element['cropImage'])
                  : null,
              element['lat'],
              element['lon'],
              element['accuracy'],
              element['scoutedDate']);
          // After successful upload check if response status code is 201
          if (response.statusCode == 201) {
            // If successful response, delete object from queue
            await DatabaseHelper.instance
                .deleteObjectInScoutQueue(element['id']);
          }
          return response;
        });
      }
    }
  }

  Future getScoutDataFromLocalDB(plotId) async {
    hasInternetConnection = await checkInternetConnection();
    var response = await CropScoutAPI.cropScoutListing(plotId);
    try {
      if (response.statusCode == 200) {
        final items = json.decode(response.body)['data'];
        print("Scout  Items >>>>>> $items");
        List<ScoutData> listOfScoutData = items.map<ScoutData>((json) {
          return ScoutData.fromJson(json);
        }).toList();
        var queryRow = await DatabaseHelper.instance.queryAllScout();
        if (hasInternetConnection == true) {
          if (queryRow.isEmpty) {
            return insertScoutDataFromApiToLocalDatabase(listOfScoutData);
          } else {
            await DatabaseHelper.instance.deleteScoutDataContent().then((_) {
              insertScoutDataFromApiToLocalDatabase(listOfScoutData);
            });
//            insertScoutDataFromApiToLocalDatabase(listOfScoutData);
          }
        } // Else internet is off// Else internet is off

        return listOfScoutData;
      } else {
        throw Exception('No se pudo cargar, no hay Internet');
      }
    } catch (e) {
      print(e);
    }
  }

  insertScoutDataFromApiToLocalDatabase(List<ScoutData> items) async {
    // Drop table before another insert

    items.forEach((items) async {
      await Future.delayed(Duration(seconds: 3), () {
        DatabaseHelper.instance.insertScoutData({
          DatabaseHelper.scoutId: items.id,
          DatabaseHelper.scoutPlotId: items.plotId,
          DatabaseHelper.scoutPlotName: items.plotName,
          DatabaseHelper.typeOfScout: items.scoutType,
          DatabaseHelper.rowNumber: items.rowNumber,
          DatabaseHelper.plantNumber: items.plantNumber,
          DatabaseHelper.numberOfLaterals: items.numberOfLaterals,
          DatabaseHelper.numberOfBranches: items.numberOfBranches,
          DatabaseHelper.numberOfCounts: items.countNumber,
          DatabaseHelper.cropImage: items.cropImage,
          DatabaseHelper.lat: items.lat,
          DatabaseHelper.lon: items.lon,
          DatabaseHelper.accuracy: items.accuracyLevel,
          DatabaseHelper.scoutUser: items.scouter,
          DatabaseHelper.scoutedDate: items.scoutDate,
        });
      });
    });
  }
//
//  Future clearFarmDBForNewSync() async {
//    var queryRow = await DatabaseHelper.instance.queryFarmAll();
//    if (queryRow.isNotEmpty) {
////      await Future.delayed(Duration(seconds: 2), () {
//      DatabaseHelper.instance.deleteFarmTable();
////      });
//    }
//  }
//

//  }
//
//  // Not using yet
//  updateLastFetchTime() async {
//    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//    sharedPreferences.setInt(
//        KEY_LAST_FETCH, DateTime.now().millisecondsSinceEpoch);
//  }
}
