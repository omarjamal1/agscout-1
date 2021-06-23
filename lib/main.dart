import 'dart:convert';
import 'dart:async';
import 'package:agscoutapp/functions/api_urls.dart';
import 'package:agscoutapp/functions/crops_on_farm_map_function.dart';
import 'package:agscoutapp/screens/bottom_navigator_entry.dart';
import 'package:agscoutapp/screens/crops_on_farm_map.dart';
import 'package:agscoutapp/screens/data_summary_chart.dart';
import 'package:agscoutapp/screens/edit-profile-screen.dart';
import 'package:agscoutapp/screens/farm_level_data_summary.dart';
import 'package:agscoutapp/screens/farms_listing_screen.dart';
import 'package:agscoutapp/screens/join_org_with_code.dart';
import 'package:agscoutapp/screens/login_screen.dart';
import 'package:agscoutapp/screens/maps_screen.dart';
import 'package:agscoutapp/screens/new_farm_screen.dart';
import 'package:agscoutapp/screens/new_organization.dart';
import 'package:agscoutapp/screens/new_plot_screen.dart';
import 'package:agscoutapp/screens/plot_listing_screen.dart';
import 'package:agscoutapp/screens/scout_list_screen.dart';
import 'package:agscoutapp/screens/crop_scout_screen.dart';
import 'package:agscoutapp/screens/select_new_farm_or_existing_farm.dart';
import 'package:agscoutapp/screens/select_new_org_or_existing_org.dart';
import 'package:agscoutapp/screens/select_organization.dart';
import 'package:agscoutapp/screens/signup_screen.dart';
import 'package:agscoutapp/screens/splash_screen.dart';
import 'package:agscoutapp/services/crop-type-offline-service.dart';
import 'package:agscoutapp/services/farm-offline-service.dart';
import 'package:agscoutapp/services/plot-offline-services.dart';
import 'package:agscoutapp/services/scout-offline-service.dart';
import 'package:agscoutapp/services/scout-type-offline-service.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:flutter/material.dart';
import 'data_models/DatabaseHelper.dart';
import 'functions/plot_listing_function.dart';
import 'screens/intro_screen.dart';
import 'package:http/http.dart' as http;

import 'screens/view_organization_profile_screen.dart';
// import 'package:flutter_stetho/flutter_stetho.dart';

getDataFromCropTypeLocalDB() async {
  var c = CropTypeOfflineService();
  await c.getCropTypeList();
}

loadScoutTypeOfflineService() async {
  var c = ScoutTypeOfflineService();
  await c.getScoutTypeList();
}

uploadScoutDataToServer() async {
  var uploadData = ScoutOfflineService();
  await uploadData.uploadScoutQueueDataToAPI();
}

void main() async {
  const thirtySeconds = const Duration(seconds: 30);
  new Timer.periodic(thirtySeconds, (Timer t) => {uploadScoutDataToServer()});

  final dbHelper = DatabaseHelper.instance;
  // Stetho.initialize();
  WidgetsFlutterBinding.ensureInitialized();

  // Load crop type into db on app start.
//  getDataFromCropTypeLocalDB();

  // Get farm from local db
//  await FarmOfflineService().getFarmFromLocalDB();
//  getDataFarmFromLocalDB();

  // Call scout type list offline function.
  await loadScoutTypeOfflineService();
//  await ScoutTypeOfflineService().getScoutTypeList();

  var loggedIn = await getAuthToken() != "no_token";
  var hasProfile = await getOrganizationIDFromSF() != "";

  runApp(
    MyApp(
      isLoggedIn: loggedIn,
      hasProfile: hasProfile,
      serverUrl: Endpoints.serverUrl,
      client: new http.Client(),
    ),
  );
}

class MyApp extends StatefulWidget {
  final http.Client client;
  final bool isLoggedIn;
  final bool hasProfile;
  final String serverUrl;

  MyApp({this.isLoggedIn, this.hasProfile, this.serverUrl, this.client});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: !widget.isLoggedIn
//          ? SplashScreen.routeName
          ? IntroScreen.routeName
          : !widget.hasProfile
              ? SelectNewOrgOrOldOrg.routeName
              : BottomNavigatorEntry.routeName,
      routes: {
        BottomNavigatorEntry.routeName: (context) => BottomNavigatorEntry(),
        IntroScreen.routeName: (context) => IntroScreen(),
        SignUp.routeName: (context) => SignUp(),
        JoinOrganizationWithCode.routeName: (context) =>
            JoinOrganizationWithCode(),
        Login.routeName: (context) => Login(),
        SelectNewOrgOrOldOrg.routeName: (context) => SelectNewOrgOrOldOrg(),
        NewOrganization.routeName: (context) => NewOrganization(),
        SelectOrganization.routeName: (context) => SelectOrganization(),
        SelectNewFarmOrExistingFarm.routeName: (context) =>
            SelectNewFarmOrExistingFarm(),
        AddNewFarm.routeName: (context) => AddNewFarm(),
        ListOfFarmsView.routeName: (context) => ListOfFarmsView(),
        PlotListing.routeName: (context) => PlotListing(),
        NewPlot.routeName: (context) => NewPlot(),
        ViewOrganizationProfile.routeName: (context) =>
            ViewOrganizationProfile(),
        ViewMap.routeName: (context) => ViewMap(),
        CropScout.routeName: (context) => CropScout(),
        ScoutListScreen.routeName: (context) => ScoutListScreen(),
        CropsOnFarmMapView.routeName: (context) => CropsOnFarmMapView(),
        DataSummaryChart.routeName: (context) => DataSummaryChart(),
        EditOrganizationProfile.routeName: (context) =>
            EditOrganizationProfile(),
        FarmDataSummary.routeName: (context) => FarmDataSummary(),
        SplashScreen.routeName: (context) => SplashScreen(),
      },
    );
  }
}

//? IntroScreen.routeName
//    : !widget.hasProfile
//? SelectNewOrgOrOldOrg.routeName
//    : BottomNavigatorEntry.routeName,

//return MaterialApp(
//debugShowCheckedModeBanner: false,
//initialRoute: !widget.isLoggedIn
//? IntroScreen.routeName
//    : !widget.hasProfile
//? SelectNewOrgOrOldOrg.routeName
//    : BottomNavigatorEntry.routeName,
//routes: {
//BottomNavigatorEntry.routeName: (context) => BottomNavigatorEntry(),
//IntroScreen.routeName: (context) => IntroScreen(),
//SignUp.routeName: (context) => SignUp(),
//JoinOrganizationWithCode.routeName: (context) =>
//JoinOrganizationWithCode(),
//Login.routeName: (context) => Login(),
//SelectNewOrgOrOldOrg.routeName: (context) => SelectNewOrgOrOldOrg(),
//NewOrganization.routeName: (context) => NewOrganization(),
//SelectOrganization.routeName: (context) => SelectOrganization(),
//SelectNewFarmOrExistingFarm.routeName: (context) =>
//SelectNewFarmOrExistingFarm(),
//AddNewFarm.routeName: (context) => AddNewFarm(),
//ListOfFarmsView.routeName: (context) => ListOfFarmsView(),
//PlotListing.routeName: (context) => PlotListing(),
//NewPlot.routeName: (context) => NewPlot(),
//ViewOrganizationProfile.routeName: (context) =>
//ViewOrganizationProfile(),
//ViewMap.routeName: (context) => ViewMap(),
//CropScout.routeName: (context) => CropScout(),
//ScoutListScreen.routeName: (context) => ScoutListScreen(),
//CropsOnFarmMapView.routeName: (context) => CropsOnFarmMapView(),
//DataSummaryChart.routeName: (context) => DataSummaryChart(),
//EditOrganizationProfile.routeName: (context) =>
//EditOrganizationProfile(),
//FarmDataSummary.routeName: (context) => FarmDataSummary(),
//},
//);
