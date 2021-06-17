import 'package:shared_preferences/shared_preferences.dart';

setAuthTokenToSF(token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('token', token);
//  print(prefs.setString('token', token));
}

getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String tokenValue = prefs.getString('token') ?? 'no_token';
  return tokenValue;
}

setLoggedInUserIDToSF(userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('userId', userId);
}

Future<String> getLoggedInUserFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('userId') ?? '';
  return userId;
}

setOrganizationIDToSF(orgId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('orgId', orgId);
}

Future<String> getOrganizationIDFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String orgId = prefs.getString('orgId') ?? '';
  return orgId;
}

Future<void> setFarmIDToSF(farmId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('farmId', farmId);
}

getFarmIDFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String farmId = prefs.getString('farmId') ?? '';
  return farmId;
}

Future<void> setPlotIdToSF(plotId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('plotId', plotId);
}

getPlotIdFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String plotId = prefs.getString('plotId') ?? '';
  return plotId;
}

// DataCount shared preference
Future<void> setEmployeesCountToSF(employeeCount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('employeeCount', employeeCount);
}

Future<void> setFarmsCountToSF(farmsCount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('farmsCount', farmsCount);
}

Future<void> setPlotCountToSF(plotCount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('plotCount', plotCount);
}

Future<void> setScoutCountToSF(scoutCount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('scoutCount', scoutCount);
}

getEmployeesCountFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int employeeCount = prefs.getInt('employeeCount') ?? 0;
  return employeeCount;
}

getFarmsCountFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int farmsCount = prefs.getInt('farmsCount') ?? 0;
  return farmsCount;
}

getPlotsCountFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int plotCount = prefs.getInt('plotCount') ?? 0;
  return plotCount;
}

getScoutsCountFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int scoutCount = prefs.getInt('scoutCount') ?? 0;
  return scoutCount;
}

// Set location to default location before hitting api for location
Future<void> setCurrentLocationLatitudeToSF(latitude) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('latitude', latitude);
}

Future<void> setCurrentLocationLongitudeToSF(longitude) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('longitude', longitude);
}

getCurrentLocationLatitudeFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double latitude = prefs.getDouble('latitude') ?? -33.4429172;
  return latitude;
}

getCurrentLocationLongitudeFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double longitude = prefs.getDouble('longitude') ?? -70.6589483;
  return longitude;
}

setCropScoutCountToSF(cropScoutCount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('cropScoutCount', cropScoutCount);
}

Future<String> getCropScoutCountFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String cropScoutCount = prefs.getString('cropScoutCount') ?? '0';
  return cropScoutCount;
}

clearAllSFData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('orgId');
  await prefs.remove('farmId');
  await prefs.remove('plotId');
  await prefs.remove('employeeCount');
  await prefs.remove('farmsCount');
  await prefs.remove('plotCount');
  await prefs.remove('scoutCount');
  await prefs.remove('userId');
  await Future.delayed(Duration(seconds: 2));
}
