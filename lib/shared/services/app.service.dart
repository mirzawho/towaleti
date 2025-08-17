import 'package:get/get.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/services.dart';

class AppService extends GetxService {
  bool handshaked = false;

  Future<void> handshake() async {
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

        if (result['data']['page'] != null) {
          Services.configs.set(key: 'page', value: result['data']['page']);
        }

        if (result['data']['cities'] != null) {
          Services.configs.set(key: 'cities', value: result['data']['cities']);
          Services.city.cities.value = result['data']['cities']
              .map((e) => CityModel.fromJson(e))
              .toList();
        }

        handshaked = true;
      }
    } catch (e) {
      //
    }
  }
}
