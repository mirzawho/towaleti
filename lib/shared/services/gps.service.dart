import 'dart:developer';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' show PermissionStatus;
import 'package:towaleti/shared/platform/location.dart';

class GPSService extends GetxService {
  Location _instance = Location();

  // check location permission
  Future<PermissionStatus> getPermission() async {
    log('[gps.service.dart] getting permission');
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

  void streamLocation({
    bool enableHighAccuracy = true,
    required Function(LatLng? latLng) onData,
  }) {
    _instance.streamLocation(
      enableHighAccuracy: enableHighAccuracy,
      onData: onData,
    );
  }

  Future<LatLng?> getLocation() async {
    try {
      // first check user has permission to get location
      if (await getPermission() != PermissionStatus.granted) {
        if (await requestPermission() != PermissionStatus.granted) {
          return null;
        }
      }

      var result = await _instance.getLocation().timeout(
        Duration(seconds: 5),
        onTimeout: () {
          return LatLng(0, 0);
        },
      );
      log('[gps.service.dart] get location = $result');
      return result;
    } catch (e) {
      log('[gps.serivce.dart] get location got error');
      print(e);
      return null;
    }
  }

  Future<void> openPermission() {
    return _instance.openPermission();
  }

  Future<void> openSettings() {
    return _instance.openSettings();
  }
}
