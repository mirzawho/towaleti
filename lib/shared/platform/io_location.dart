import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location;

class Location {
  final _instance = location.Location();

  Future<void> openPermission() async {
    Geolocator.openAppSettings();
  }

  Future<void> openSettings() async {
    Geolocator.openLocationSettings();
  }

  // check location permission
  Future<location.PermissionStatus> getPermission() {
    return _instance.hasPermission();
  }

  // request location permission
  Future<location.PermissionStatus> requestPermission() {
    return _instance.requestPermission();
  }

  // current location
  Future<LatLng> getLocation({bool enableHighAccuracy = true}) async {
    var c = Completer<LatLng>();

    var timer = Timer(Duration(seconds: 5), () {
      if (!c.isCompleted) {
        c.complete(LatLng(0, 0));
      }
    });

    try {
      if (enableHighAccuracy) {
        _instance.changeSettings(
          accuracy: location.LocationAccuracy.high,
        );
      } else {
        _instance.changeSettings(
          accuracy: location.LocationAccuracy.low,
        );
      }
      var position = await _instance.getLocation();

      if (timer.isActive) {
        timer.cancel();
      }

      if (!c.isCompleted) {
        c.complete(
          LatLng(
            position.latitude!,
            position.longitude!,
          ),
        );
      }
    } catch (e) {
      print(e);
      if (timer.isActive) {
        timer.cancel();
      }
      if (!c.isCompleted) {
        c.complete(LatLng(0, 0));
      }
    }

    return c.future;
  }
}
