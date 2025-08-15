import 'dart:developer';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:towaleti/models/address.model.dart';
import 'package:towaleti/models/place.model.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/services.dart';

class PlaceService extends GetxService {
  AddressModel? address;

  List<PlaceModel> list() {
    List<dynamic>? array = Services.configs.get(key: 'places');

    if (array == null) {
      array = [];
    }

    List<PlaceModel> places = [];

    for (var item in array) {
      places.add(PlaceModel.fromJson(item));
    }

    return places;
  }

  void toggle({required PlaceModel place}) {
    List<dynamic>? array = Services.configs.get(key: 'places');

    if (array == null) {
      array = [];
    }

    if (array.indexWhere(
            (item) => item['lat'] == place.lat && item['lon'] == place.lon) !=
        -1) {
      log('[place.service.dart] remove a place');
      array.removeWhere(
          (item) => item['lat'] == place.lat && item['lon'] == place.lon);
    } else {
      log('[place.service.dart] add a place');
      array.add(place.toJson());
    }

    log('[place.service.dart] ${array.length} places');

    Services.configs.set(key: 'places', value: array);
  }

  bool contains({required PlaceModel place}) {
    List<dynamic>? array = Services.configs.get(key: 'places');

    if (array == null) {
      array = [];
    }

    return array.indexWhere(
            (item) => item['lat'] == place.lat && item['lon'] == place.lon) !=
        -1;
  }

  void clear() {
    Services.configs.set(key: 'places', value: []);
  }

  void share({required PlaceModel place}) {
    var url = CONSTANTS.urlPlaceShare;

    SharePlus.instance.share(
      ShareParams(
        subject: 'اشتراک گذاری مکان',
        uri: Uri.parse(
          url
              .replaceAll('LAT', place.lat.toString())
              .replaceAll('LON', place.lon.toString()),
        ),
      ),
    );
  }

  void navigation({required PlaceModel place}) {
    MapsLauncher.launchCoordinates(place.lat, place.lon, 'اپلیکیشن توالتی');
  }

  Future<List<PlaceModel>> find({
    required LatLng location,
    LatLng? currentPosition,
    double zoom = 15,
  }) async {
    try {
      var result = await Services.api.find(
        lat: location.latitude,
        lon: location.longitude,
        zoom: zoom.toInt(),
        gps_lat: currentPosition?.latitude,
        gps_lon: currentPosition?.longitude,
      );

      if (result['ok']) {
        log('[place.service.dart] found ${result['places'].length} places');

        List<PlaceModel> values = [];

        for (var place in result['places']) {
          values.add(
            PlaceModel(
              lat: place['geometry']['lon'],
              lon: place['geometry']['lat'],
              distance: double.parse(place['distance'].toString()),
              name: place['name'],
              address: place['address'],
            ),
          );
        }

        if (result['address'] != null) {
          address = AddressModel(
            address: result['address']['address'],
            city: result['address']['city'],
            state: result['address']['state'],
            lat: result['address']['coordinates']['lat'],
            lon: result['address']['coordinates']['lng'],
          );
        } else {
          address = null;
        }

        return values;
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
