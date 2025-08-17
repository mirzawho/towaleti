import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/models/firebase.model.dart';
import 'package:towaleti/shared/services.dart';
import 'package:towaleti/shared/vibration.dart';

class SplashController extends GetxController {
  RxInt viewIndex = 0.obs;
  RxString selectedCity = ''.obs;
  RxString currentPositionMessage = 'نیاز به دسترسی موقعیت مکانی شما'.obs;
  Rx<CityModel> currentPosition = CityModel(
    name: 'همین جا',
    lat: 0,
    lon: 0,
  ).obs;

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
      }
    } else {
      Timer(Duration(seconds: 1), () {
        onInit();
      });
    }
  }

  Future<void> initFirebase() async {
    await Services.firebase.init();
    Services.firebase.event(type: FIREBASE_EVENT_TYPE.OPEN_APP);
  }

  Future<void> initHandshake() async {
    return Services.app.handshake();
  }

  void initGPS() async {
    currentPositionMessage.value = 'در حال دریافت موقعیت مکانی';

    var location = await Services.gps.getLocation();

    if (location != null && location.latitude != 0 && location.longitude != 0) {
      currentPosition.value = CityModel(
        name: 'همین جا',
        lat: location.latitude,
        lon: location.longitude,
      );

      Services.city.select(currentPosition.value);

      selectedCity.value = currentPosition.value.name;

      log('[splash.controller.dart] init gps');

      currentPositionMessage.value = '';

      // reverse lat lng

      var result = await Services.api.reverse(
        lat: location.latitude,
        lon: location.longitude,
      );

      if (result['ok']) {
        var messages = [];

        if (result['data']['state'] != null) {
          messages.add('استان ' + result['data']['state']);
        }

        if (result['data']['city'] != null) {
          messages.add('شهر ' + result['data']['city']);
        }

        currentPositionMessage.value = messages.join('، ');
      }
    } else {
      currentPositionMessage.value = 'نیاز به دسترسی موقعیت مکانی شما';
    }
  }

  void selectCity({required CityModel city}) async {
    vibrate();

    if (city.name == currentPosition.value.name) {
      initGPS();
    } else {
      Services.city.select(city);

      selectedCity.value = city.name;

      log('[splash.controller.dart] selected ${selectedCity.value}');
    }
  }

  void next() {
    vibrate();

    if (viewIndex.value == 1) {
      viewIndex.value = 2;

      return;
    }

    if (viewIndex.value == 2) {
      Services.firebase.event(type: FIREBASE_EVENT_TYPE.SPLASHED);
      Services.configs.set(key: 'splashed', value: true);
      Get.offAndToNamed('/home');
      return;
    }
  }
}
