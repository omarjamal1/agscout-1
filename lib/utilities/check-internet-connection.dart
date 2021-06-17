import 'package:connectivity/connectivity.dart';

bool hasInternetConnection = true;
checkInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    hasInternetConnection = false;
  }
  return hasInternetConnection;
}
