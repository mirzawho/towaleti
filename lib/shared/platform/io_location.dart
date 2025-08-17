import 'dart:async';
import 'dart:developer';

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

  void streamLocation({
    bool enableHighAccuracy = true,
    required Function(LatLng? latLng) onData,
  }) {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy:
            enableHighAccuracy ? LocationAccuracy.high : LocationAccuracy.low,
        distanceFilter: 10,
      ),
    ).listen(
      (data) {
        log('[io_location.dart] stream location ${data.latitude},${data.longitude}');

        onData(
          LatLng(data.latitude, data.longitude),
        );
      },
      onError: (_) {
        onData(null);
      },
    );
  }

  // current location
  Future<LatLng> getLocation({
    bool enableHighAccuracy = true,
    int timeout = 5,
  }) async {
    var c = Completer<LatLng>();
    var future = c.future;

    // var timer = Timer(Duration(seconds: timeout), () {
    //   if (!c.isCompleted) {
    //     c.complete(LatLng(0, 0));
    //   }
    // });

    future.timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        log('[io_location.dart] get location timeout');
        if (!c.isCompleted) {
          c.completeError(TimeoutException('Operation timed out'));
        }
        return LatLng(0, 0);
      },
    );

    try {
      var position = await Geolocator.getCurrentPosition();

      if (!c.isCompleted) {
        c.complete(
          LatLng(
            position.latitude,
            position.longitude,
          ),
        );
      }
    } catch (e) {
      print(e);

      if (!c.isCompleted) {
        c.complete(LatLng(0, 0));
      }
    }

    return future;
  }
}
