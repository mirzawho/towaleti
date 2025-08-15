import 'dart:developer';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' show PermissionStatus;
import 'package:towaleti/shared/platform/location.dart';

class GPSService extends GetxService {
  Location _instance = Location();

  // check location permission
  Future<PermissionStatus> getPermission() async {
    var result = await _instance.getPermission();
    log('[gps.service.dart] get permission = $result');
    return result;
  }

  // request location permission
  Future<PermissionStatus> requestPermission() async {
    var result = await _instance.requestPermission();
    log('[gps.service.dart] request permission = $result');
    return result;
  }

  Future<LatLng?> getLocation() async {
    var result = await _instance.getLocation();
    log('[gps.service.dart] get location = $result');
    return result;
  }

  Future<void> openPermission() {
    return _instance.openPermission();
  }

  Future<void> openSettings() {
    return _instance.openSettings();
  }
}
