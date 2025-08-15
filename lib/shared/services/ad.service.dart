import 'dart:developer';

import 'package:get/get.dart';
import 'package:towaleti/models/ad.model.dart';
import 'package:towaleti/shared/services.dart';

class AdService extends GetxService {
  RxList<AdModel> ads = List<AdModel>.empty(growable: true).obs;

  AdModel? load() {
    var data = Services.configs.get(key: 'ad');

    if (data != null) {
      log('[ad.service.dart] loaded one ad');

      AdModel ad = AdModel.fromJson(data);

      ads.value = [ad];

      return ad;
    }

    return null;
  }

  Future<AdModel?> request({String type = "any"}) async {
    try {
      var city = null;

      if (type == "city") {
        var value = Services.place.address;

        if (value != null && value.city != null) {
          city = value.city;
        } else {
          type = "any";
        }
      }

      var result = await Services.api.ad(type: type, city: city);

      if (result['ok'] && result['ad'] != null) {
        log('[ad.service.dart] request one ad');

        Services.configs.set(key: 'ad', value: result['ad']);
        AdModel ad = AdModel.fromJson(result['ad']);

        ads.value = [ad];

        return ad;
      }

      return null;
    } catch (e) {
      print(e);

      return null;
    }
  }
}
