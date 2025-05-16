import 'package:universal_html/html.dart' as html;
import 'package:location/location.dart' as location;
import 'package:latlong2/latlong.dart';

class Location {
  // check location permission
  Future<location.PermissionStatus> getPermission() async {
    html.PermissionStatus? status =
        await html.window.navigator.permissions?.query({'name': 'geolocation'});

    switch (status?.state) {
      case 'granted':
        return location.PermissionStatus.granted;
      case 'prompt':
        return location.PermissionStatus.denied;
      case 'denied':
      default:
        return location.PermissionStatus.deniedForever;
    }
  }

  // request location permission
  Future<location.PermissionStatus> requestPermission() async {
    try {
      html.PermissionStatus? status = await html.window.navigator.permissions
          ?.query({'name': 'geolocation'});

      if (status?.state == 'prompt') {
        await html.window.navigator.geolocation.getCurrentPosition();
      }

      return await getPermission();
    } catch (e) {
      print(e);
      return location.PermissionStatus.denied;
    }
  }

  // current location
  Future<LatLng> getLocation() async {
    try {
      final position =
          await html.window.navigator.geolocation.getCurrentPosition(
        enableHighAccuracy: true,
      );

      return LatLng(
        position.coords?.latitude?.toDouble() ?? 0.0,
        position.coords?.longitude?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print(e);
      return LatLng(0, 0);
    }
  }
}
