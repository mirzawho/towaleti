import 'package:location/location.dart' as location;
import 'package:latlong2/latlong.dart';

class Location {
  final _instance = location.Location();

  // check location permission
  Future<location.PermissionStatus> getPermission() {
    return _instance.hasPermission();
  }

  // request location permission
  Future<location.PermissionStatus> requestPermission() {
    return _instance.requestPermission();
  }

  // current location
  Future<LatLng> getLocation() async {
    try {
      var position = await _instance.getLocation();

      return LatLng(
        position.latitude!,
        position.longitude!,
      );
    } catch (e) {
      print(e);
      return LatLng(0, 0);
    }
  }
}
