import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/database/cities.database.dart';
import 'package:towaleti/shared/services.dart';
import 'package:towaleti/shared/vibration.dart';

class SplashController extends GetxController {
  RxInt viewIndex = 0.obs;
  RxString selectedCity = 'همین جا'.obs;
  RxList<CityModel> cities = List<CityModel>.empty(growable: true).obs;

  @override
  void onInit() async {
    super.onInit();

    Services.chrome.transparent();

    var result = await Services.connectivity.check();

    if (result) {
      initFirebase();
      await initHandshake();
      var splashed = Services.configs.get(key: 'splashed');
      if (splashed != null) {
        Get.offAndToNamed('/home');
      } else {
        viewIndex.value = 1;
        initCities();
        initGPS();
      }
    } else {
      Timer(Duration(seconds: 1), () {
        onInit();
      });
    }
  }

  Future<void> initFirebase() {
    return Services.firebase.init();
  }

  Future<void> initHandshake() async {
    try {
      var result = await Services.api.handshake();

      if (result['ok']) {
        CONSTANTS.versionIsOld = result['data']['isUpdateAvailable'] ??
            result['data']['is_update_available'];
        CONSTANTS.verionIsDeprecated =
            result['data']['isDeprecated'] ?? result['data']['is_deprecated'];
        CONSTANTS.urlFeedback = result['data']['url_feedback'];
        CONSTANTS.urlUpdate = result['data']['url_update'];
        if (result['data']['url_map'] != null) {
          CONSTANTS.urlMap = result['data']['url_map'];
        }
        if (result['data']['url_share_place'] != null) {
          CONSTANTS.urlPlaceShare = result['data']['url_share_place'];
        }
        if (result['data']['url_share'] != null) {
          CONSTANTS.urlShare = result['data']['url_share'];
        } else {
          CONSTANTS.urlShare = null;
        }
        if (result['data']['url_form_place'] != null) {
          CONSTANTS.urlFormPlace = result['data']['url_form_place'];
        } else {
          CONSTANTS.urlFormPlace = null;
        }
        if (result['data']['url_form_ad'] != null) {
          CONSTANTS.urlFormAd = result['data']['url_form_ad'];
        } else {
          CONSTANTS.urlFormAd = null;
        }
      }
    } catch (e) {
      //
    }
  }

  void initCities() {
    var citiesSorted = [...cities_database];
    citiesSorted.sort((a, b) => a.name.compareTo(b.name));
    cities.value = citiesSorted;
  }

  void initGPS() async {
    var location = await Services.gps.getLocation();

    if (location != null && location.latitude != 0 && location.longitude != 0) {
      log('[splash.controller.dart] right here added to cities list');
      cities.insert(
        0,
        CityModel(
          name: 'همین جا',
          lat: location.latitude,
          lon: location.longitude,
        ),
      );
    }
  }

  void selectCity({required CityModel city}) async {
    vibrate();

    Services.city.select(city);

    selectedCity.value = city.name;

    log('[splash.controller.dart] selected ${selectedCity.value}');
  }

  void next() {
    if (viewIndex.value == 1) {
      viewIndex.value = 2;

      return;
    }

    if (viewIndex.value == 2) {
      Services.configs.set(key: 'splashed', value: true);
      Get.offAndToNamed('/home');
      return;
    }
  }
}
