import 'dart:async';

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
    var c = Completer<LatLng>();

    var timer = Timer(Duration(seconds: 5), () {
      if (!c.isCompleted) {
        print('timeout');
        c.complete(LatLng(0, 0));
      }
    });

    try {
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
