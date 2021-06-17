import 'dart:async';
import 'dart:convert';
import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/functions/plot_listing_function.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlotOfflineService {
  static const String KEY_LAST_FETCH = "last_fetch";
  static const int MILLISECONDS_IN_AN_HOUR = 360000;
  static const int REFRESH_THRESHOLD = 3 * MILLISECONDS_IN_AN_HOUR;
  bool hasInternetConnection = true;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static Future<bool> _shouldRefreshPlotData() async {
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

  Future getPlotFromLocalDB(farmId) async {
    await checkInternetConnection();
    var response = await PlotAPI.plotListing(farmId);
    try {
      if (response.statusCode == 200) {
        final items = json.decode(response.body)['data'];
        List<PlotDataTable> listOfPlotData = items.map<PlotDataTable>((json) {
          return PlotDataTable.fromJson(json);
        }).toList();
//        if (hasInternetConnection == true) {
        var queryRow = await DatabaseHelper.instance.queryPlotByFarm(farmId);

        if (queryRow.isEmpty) {
          insertPlotFromApiToLocalDatabase(listOfPlotData);
        } else {
          await DatabaseHelper.instance.deletePlotTable();
          await Future.delayed(Duration(seconds: 2), () {
            insertPlotFromApiToLocalDatabase(listOfPlotData);
          });
        }
//        } // Else internet is off// Else internet is off
        return listOfPlotData;
      } else {
        throw Exception('No se pudo cargar, no hay Internet');
      }
    } catch (e) {
      print(e);
    }
  }

  insertPlotFromApiToLocalDatabase(List<PlotDataTable> items) async {
    // Drop table before another insert

    items.forEach((items) async {
      await DatabaseHelper.instance.insertPlotData({
        DatabaseHelper.plotFarmId: items.plotFarmId,
        DatabaseHelper.plotId: items.plotId,
        DatabaseHelper.plotName: items.plotName,
        DatabaseHelper.variety: items.variety,
        DatabaseHelper.plotCropType: items.cropTypeName,
        DatabaseHelper.centroDeCosto: items.centroDeCosto,
        DatabaseHelper.area: items.area,
        DatabaseHelper.plantPerHectare: items.plantPerHectare,
        DatabaseHelper.plotCreatedDate: items.createdDate,
      });
    });
  }

//  Future clearPlotDBForNewSync() async {
//    var queryRow = await DatabaseHelper.instance.queryPlotAll();
//    if (queryRow.isNotEmpty) {
//      DatabaseHelper.instance.deletePlotTable();
//    }
//  }

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
