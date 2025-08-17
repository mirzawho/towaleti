import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location;
import 'package:universal_html/html.dart' as html;

class Location {
  Future<void> openPermission() async {}
  Future<void> openSettings() async {}

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

  void streamLocation({
    bool enableHighAccuracy = true,
    required Function(LatLng? latLng) onData,
  }) {
    html.window.navigator.geolocation
        .watchPosition(
      enableHighAccuracy: enableHighAccuracy,
    )
        .listen(
      (data) {
        onData(
          LatLng(
            double.parse((data.coords?.latitude ?? 0).toString()),
            double.parse((data.coords?.longitude ?? 0).toString()),
          ),
        );
      },
      onError: (_) {
        onData(null);
      },
    );
  }

  // current location
  Future<LatLng> getLocation({
    bool enableHighAccuracy = false,
    int timeout = 5,
  }) async {
    try {
      final position =
          await html.window.navigator.geolocation.getCurrentPosition(
        enableHighAccuracy: enableHighAccuracy,
        timeout: Duration(seconds: timeout),
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
