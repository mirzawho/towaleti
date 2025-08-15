import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:towaleti/shared/services/access.service.dart';
import 'package:towaleti/shared/services/ad.service.dart';
import 'package:towaleti/shared/services/api.service.dart';
import 'package:towaleti/shared/services/chrome.service.dart';
import 'package:towaleti/shared/services/city.service.dart';
import 'package:towaleti/shared/services/configs.service.dart';
import 'package:towaleti/shared/services/connectivity.service.dart';
import 'package:towaleti/shared/services/event.service.dart';
import 'package:towaleti/shared/services/firebase.service.dart';
import 'package:towaleti/shared/services/gps.service.dart';
import 'package:towaleti/shared/services/http.service.dart';
import 'package:towaleti/shared/services/place.service.dart';

class Services {
  static AdService get ad => Get.find(tag: 'ad');
  static EventService get event => Get.find(tag: 'event');
  static ConnectivityService get connectivity => Get.find(tag: 'connectivity');
  static AccessService get access => Get.find(tag: 'access');
  static ChromeService get chrome => Get.find(tag: 'chrome');
  static ConfigsService get configs => Get.find(tag: 'configs');
  static HttpService get http => Get.find(tag: 'http');
  static GPSService get gps => Get.find(tag: 'gps');
  static CityService get city => Get.find(tag: 'city');
  static PlaceService get place => Get.find(tag: 'place');
  static APIService get api => Get.find(tag: 'api');
  static FirebaseService get firebase => Get.find(tag: 'firebase');

  static put() async {
    developer.log('[services.dart] start put Get services');
    Get.lazyPut(() => AdService(), tag: 'ad');
    Get.lazyPut(() => EventService(), tag: 'event');
    Get.lazyPut(() => ConnectivityService(), tag: 'connectivity');
    Get.lazyPut(() => AccessService(), tag: 'access');
    Get.lazyPut(() => ChromeService(), tag: 'chrome');
    Get.lazyPut(() => ConfigsService(), tag: 'configs');
    Get.lazyPut(() => HttpService(), tag: 'http');
    Get.lazyPut(() => GPSService(), tag: 'gps');
    Get.lazyPut(() => CityService(), tag: 'city');
    Get.lazyPut(() => PlaceService(), tag: 'place');
    Get.lazyPut(() => APIService(), tag: 'api');
    Get.lazyPut(() => FirebaseService(), tag: 'firebase');
    developer.log('[services.dart] end put Get services');
  }
}
