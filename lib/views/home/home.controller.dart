import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:sheet/sheet.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:towaleti/models/address.model.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/models/firebase.model.dart';
import 'package:towaleti/models/place.model.dart';
import 'package:towaleti/shared/services.dart';
import 'package:towaleti/shared/vibration.dart';
import 'package:towaleti/views/home/dialogPlace.view.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  List<GlobalKey> tutorial = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  late AnimatedMapController mapController = AnimatedMapController(vsync: this);
  ScrollController scrollController = ScrollController();
  SheetController sheetController = SheetController();
  TextEditingController textEditingController = TextEditingController();

  Rx<LatLng> currentPosition = LatLng(0, 0).obs;
  RxBool gettingGPSPermission = false.obs;
  RxBool hasGPSPermission = false.obs;
  RxBool get hasCurrentPosition {
    return (currentPosition.value.latitude != 0 &&
            currentPosition.value.longitude != 0)
        .obs;
  }

  RxBool showSavedPlaces = false.obs;
  RxList<PlaceModel> savedPlaces = List<PlaceModel>.empty(growable: true).obs;

  RxList<PlaceModel> places = List<PlaceModel>.empty(growable: true).obs;

  RxBool findingNearestPlace = false.obs;

  RxBool searching = false.obs;
  RxList<AddressModel> addresses = List<AddressModel>.empty(growable: true).obs;

  RxList<CityModel> latestCities = List<CityModel>.empty(growable: true).obs;

  RxList<PlaceModel> mapPlaces = List<PlaceModel>.empty(growable: true).obs;

  Timer? timerFinding;

  @override
  void onInit() {
    super.onInit();

    initGPS();
    initSplash();
    initSavedPlaces();
    initLatestCities();
    Services.ad.load();
  }

  void initSplash() {
    if (!Services.app.handshaked) {
      Services.app.handshake().then((_) => update());
    }

    if (!Services.firebase.firebased) {
      Services.firebase.init();
    }
  }

  void initShowcase(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Services.configs.get(key: 'tutorialed') != null) return;

      if (savedPlaces.length == 0) {
        savedPlaces.value = [
          PlaceModel(
            lat: 0,
            lon: 0,
            distance: 0,
            name: 'مکان ذخیره شده',
            address: 'ایران',
          ),
        ];
      }

      ShowCaseWidget.of(context).startShowCase(tutorial);
      Services.configs.set(key: 'tutorialed', value: true);
    });
  }

  void destroyShowcase() {
    Services.configs.set(key: 'tutorialed', value: true);

    initSavedPlaces();
  }

  void initSavedPlaces() {
    var value = Services.place.list();

    savedPlaces.value = value;

    updateMapPlaces();
  }

  void initGPS() async {
    var value = await initCurrentPosition(checkGPSPermission: false);

    if (value) {
      initGPSInterval();
      findPlaces(location: currentPosition.value);
    }
  }

  void initGPSInterval() {
    log('[home.controller.dart] init gps interval');

    Services.gps.streamLocation(
      onData: (result) {
        if (result != null) {
          if (result.latitude == 0 && result.longitude == 0) {
            return;
          }

          currentPosition.value = result;
          hasGPSPermission.value = true;
        } else {
          hasGPSPermission.value = false;
        }
      },
    );
  }

  Future<bool> initCurrentPosition({bool checkGPSPermission = true}) async {
    try {
      log('[home.controller.dart] getting current position');

      gettingGPSPermission.value = true;
      var result = await Services.gps.getLocation();
      gettingGPSPermission.value = false;

      Get.forceAppUpdate();

      if (result != null) {
        if (result.latitude == 0 && result.longitude == 0) {
          if (checkGPSPermission) {
            requestGPSPermission();
          } else {
            hasGPSPermission.value = false;
          }

          return false;
        }

        currentPosition.value = result;
        hasGPSPermission.value = true;
        log('[home.controller.dart] current position is set');

        mapController.animateTo(dest: result, zoom: 15);
        findPlaces(location: result);

        return true;
      } else {
        if (checkGPSPermission) {
          requestGPSPermission();
        } else {
          hasGPSPermission.value = false;
        }
      }

      return false;
    } catch (e) {
      log('[home.controller.dart] error on setting current position');
      print(e);
      if (checkGPSPermission) {
        requestGPSPermission();
      } else {
        hasGPSPermission.value = false;
      }
      update();
      return false;
    }
  }

  void initLatestCities() async {
    var cities = await Services.city.latest();

    latestCities.value = cities;

    update();
  }

  void requestGPSPermission({bool init = false, bool snackbar = true}) async {
    var result = await Services.gps.requestPermission();

    if (result == PermissionStatus.granted) {
      hasGPSPermission.value = true;

      if (init && await initCurrentPosition()) {
        return;
      }
    } else if (snackbar) {
      hasGPSPermission.value = false;
      showGPSPermissionSnackbar(status: result);
    }
  }

  void showGPSPermissionSnackbar({
    PermissionStatus? status = null,
    int timeout = 5,
  }) {
    log('[home.controller.dart] showing gps permission snackbar');

    Get.snackbar(
      '',
      '',
      duration: Duration(seconds: timeout),
      margin: EdgeInsets.only(
        top: 6,
        left: 12,
        right: 12,
      ),
      boxShadows: [
        BoxShadow(
          color: CupertinoColors.quaternarySystemFill,
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
      titleText: Padding(
        padding: EdgeInsets.only(
          top: kIsWeb ? 0 : 6,
        ),
        child: Text(
          'دسترسی نداریم',
          style: TextStyle(
            color: CupertinoColors.darkBackgroundGray,
            fontFamily: "YekanBakh",
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      messageText: !kIsWeb
          ? Container()
          : Text(
              'وارد تنظیمات دستگاه خود شوید و دسترسی به موقعیت مکانی را فعال کنید',
              style: TextStyle(
                color: CupertinoColors.darkBackgroundGray,
                fontFamily: "YekanBakh",
                fontSize: 11,
              ),
            ),
      mainButton: kIsWeb
          ? null
          : TextButton(
              onPressed: () {
                if (status != PermissionStatus.granted) {
                  Services.gps.openPermission();
                } else {
                  Services.gps.openSettings();
                }
              },
              child: Text(
                'تنظیمات',
                style: TextStyle(
                  fontFamily: "YekanBakh",
                ),
              ),
            ),
      backgroundColor: CupertinoColors.white,
    );
  }

  void zoomIn() {
    vibrate();

    var zoom = mapController.mapController.camera.zoom + 1;

    if (zoom <= 17) {
      mapController.animateTo(
        dest: mapController.mapController.camera.center,
        zoom: zoom,
      );
    }
  }

  void zoomOut() {
    vibrate();

    var zoom = mapController.mapController.camera.zoom - 1;

    if (zoom >= 3) {
      mapController.animateTo(
        dest: mapController.mapController.camera.center,
        zoom: zoom,
      );
    }
  }

  void selectCity({required CityModel city}) async {
    vibrate();
    Services.firebase.event(type: FIREBASE_EVENT_TYPE.SELECT_CITY);
    await Services.city.select(city);
    initLatestCities();
    sheetController.animateTo(
      (Get.height - 200) / 2,
      duration: Duration(milliseconds: 300),
      curve: Curves.bounceOut,
    );
    scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.bounceOut,
    );
  }

  void findPlaces({required LatLng location, double zoom = 15}) {
    if (timerFinding != null) {
      timerFinding!.cancel();
    }

    timerFinding = Timer(Duration(milliseconds: 500), () async {
      try {
        var values = await Services.place.find(
          location: location,
          currentPosition: currentPosition.value,
          zoom: zoom,
        );

        places.value = values;

        updateMapPlaces();

        sheetController.animateTo(
          (Get.height - 200) / 2,
          duration: Duration(milliseconds: 300),
          curve: Curves.bounceOut,
        );
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.bounceOut,
        );

        update();

        if (values.isNotEmpty && zoom >= 15) {
          Services.ad.request(type: "city");
        } else {
          Services.ad.request(type: "any");
        }

        return;
      } catch (e) {
        log('[home.controller.dart] failed to fetch places');
        print(e);
        return;
      }
    });
  }

  void searchQuery({required String query}) async {
    addresses.value = [];

    if (query.length < 3) return;

    try {
      Services.firebase.event(type: FIREBASE_EVENT_TYPE.REVERSE_SEARCH);

      searching.value = true;
      var result = await Services.api.search(address: query);
      searching.value = false;

      if (result['ok'] && result['locations'] != null) {
        log('[home.controller.dart] found ${result['locations'].length} addresses');

        for (var item in result['locations']) {
          addresses.add(
            AddressModel(
              address: item['address'],
              city: item['city'] ?? '',
              state: item['state'] ?? '',
              lat: item['coordinates']['lat'],
              lon: item['coordinates']['lng'],
            ),
          );
        }

        sheetController.animateTo(
          (Get.height - 200) / 2,
          duration: Duration(milliseconds: 300),
          curve: Curves.bounceOut,
        );
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.bounceOut,
        );

        Get.forceAppUpdate();
      } else {
        log('[home.controller.dart] seems like we don\'t have any addresses');
      }
    } catch (e) {
      log('[home.controller.dart] failed to reverse address from query');
      print(e);
      searching.value = false;
    }
  }

  void findNearestPlace() async {
    try {
      vibrate();
      if (!hasCurrentPosition.value) {
        var result = await initCurrentPosition();
        if (!result) {
          return;
        }
      }

      if (!hasCurrentPosition.value) {
        return;
      }

      findingNearestPlace.value = true;

      Services.firebase.event(type: FIREBASE_EVENT_TYPE.NEAREST_PLACE);

      var result = await Services.api.find(
        lat: currentPosition.value.latitude,
        lon: currentPosition.value.longitude,
        zoom: 15,
        gps_lat: currentPosition.value.latitude,
        gps_lon: currentPosition.value.longitude,
      );

      if (result['ok']) {
        log('[home.controller.dart] found ${result['places'].length} places nearby');

        var place = result['places'][0];

        if (place != null) {
          log('[home.controller.dart] setting nearest place');
          var item = PlaceModel(
            lat: place['geometry']['lon'],
            lon: place['geometry']['lat'],
            distance: double.parse(place['distance'].toString()),
            name: place['name'],
            address: place['address'],
          );

          places.value = [item];

          updateMapPlaces();

          await mapController.animateTo(
            dest: LatLng(item.lat, item.lon),
            zoom: 16,
          );

          openPlaceBottomSheet(item);

          update();
        }
      } else {
        log('[home.controller.dart] found noting place nearby');
      }

      findingNearestPlace.value = false;
    } catch (e) {
      log('[home.controller.dart] failed to find nearest place');
      print(e);

      findingNearestPlace.value = false;
    }
  }

  void updateMapPlaces() {
    var _savedPlaces = savedPlaces.value;
    var _places = places.value;

    var output = [..._savedPlaces];

    for (var item in _places) {
      if (_savedPlaces.indexWhere(
              (value) => value.lat == item.lat && value.lon == item.lon) ==
          -1) {
        output.add(item);
      }
    }

    mapPlaces.value = output;
  }

  void openPlaceBottomSheet(PlaceModel place) {
    vibrate();

    sheetController.animateTo(
      (Get.height - 200) / 2,
      duration: Duration(milliseconds: 300),
      curve: Curves.bounceOut,
    );

    mapController.animateTo(
      dest: LatLng(place.lat, place.lon),
      zoom: 16,
      duration: Duration(milliseconds: 300),
      curve: Curves.bounceOut,
    );

    Services.firebase.event(type: FIREBASE_EVENT_TYPE.OPEN_PLACE);

    Get.bottomSheet(
      DialogPlaceView(
        place: place,
      ),
    ).then((_) {
      initSavedPlaces();
    });
  }

  void openInfo() {
    vibrate();
    Get.toNamed('/info');
  }
}
