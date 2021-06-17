import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:geolocator/geolocator.dart';

getCurrentLocation() async {
  try {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setCurrentLocationLatitudeToSF(position.latitude);
    setCurrentLocationLongitudeToSF(position.longitude);
    return position;
  } catch (e) {
    print(e);
  }
}
