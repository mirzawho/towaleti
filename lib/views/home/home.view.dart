import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/models/place.model.dart';
import 'package:towaleti/shared/services.dart';
import 'package:towaleti/shared/vibration.dart';
import 'package:towaleti/views/home/appBar.widget.dart';
import 'package:towaleti/views/home/bottomSheet.widget.dart';
import 'package:towaleti/views/home/home.controller.dart';
import 'package:towaleti/views/home/map.widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    Services.chrome.transparent();

    return ShowCaseWidget(
      onFinish: () {
        controller.destroyShowcase();
      },
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'بعدی',
          backgroundColor: CupertinoColors.activeBlue,
          textStyle: TextStyle(
            fontSize: 12,
            fontFamily: "YekanBakh",
            color: CupertinoColors.white,
          ),
        ),
      ],
      builder: (context) {
        controller.initShowcase(context);

        return Obx(
          () => CupertinoPageScaffold(
            backgroundColor: CupertinoColors.white,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SoftEdgeBlur(
                    edges: [
                      EdgeBlur(
                        type: EdgeType.topEdge,
                        size: MediaQuery.of(context).padding.top + 64,
                        sigma: 50,
                        tileMode: TileMode.mirror,
                        controlPoints: [
                          ControlPoint(
                            position: 0.5,
                            type: ControlPointType.visible,
                          ),
                          ControlPoint(
                            position: 1,
                            type: ControlPointType.transparent,
                          )
                        ],
                      ),
                    ],
                    child: MapWidget(
                      controller: controller.mapController.mapController,
                      currentPosition: controller.currentPosition.value,
                      places: controller.places.value,
                      onPlaceSelect: ({required PlaceModel place}) {
                        controller.openPlaceBottomSheet(place);
                      },
                      onPositionChange: ({
                        required LatLng location,
                        required double zoom,
                      }) {
                        controller.findPlaces(location: location, zoom: zoom);
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: GetPlatform.isIOS ? 42 : Get.mediaQuery.padding.top + 20,
                  left: 0,
                  right: 0,
                  child: AppBarWidget(
                    tutorial: controller.tutorial,
                    gettingGPSPermission: controller.gettingGPSPermission.value,
                    hasGPSPermission: controller.hasGPSPermission.value,
                    onGPSTap: () {
                      controller.initCurrentPosition();
                    },
                    onRquestGPSPermission: () {
                      controller.requestGPSPermission();
                    },
                    onInfoTap: () {
                      controller.openInfoBottomSheet();
                    },
                  ),
                ),
                BottomSheetWidget(
                  tutorial: controller.tutorial,
                  scrollController: controller.scrollController,
                  sheetController: controller.sheetController,
                  textEditingController: controller.textEditingController,
                  findingNearestPlace: controller.findingNearestPlace.value,
                  searching: controller.searching.value,
                  addresses: controller.addresses.value,
                  latestCities: controller.latestCities.value,
                  savedPlaces: controller.savedPlaces.value,
                  showSavedPlaces: controller.showSavedPlaces.value,
                  places: controller.places.value,
                  ad: Services.ad.ads.value.isEmpty
                      ? null
                      : Services.ad.ads.value.first,
                  zoomIn: () {
                    controller.zoomIn();
                  },
                  zoomOut: () {
                    controller.zoomOut();
                  },
                  onToggleShowSavedPlacesTap: () {
                    vibrate();
                    controller.showSavedPlaces.value =
                        !controller.showSavedPlaces.value;
                  },
                  onClearSavedPlacesTap: () {
                    Services.place.clear();
                    controller.initSavedPlaces();
                  },
                  onFindNearsetTap: () {
                    controller.findNearestPlace();
                  },
                  onSearchSubmit: ({required String query}) {
                    controller.searchQuery(query: query);
                  },
                  onAddressSelect: ({
                    required LatLng location,
                    required double zoom,
                  }) {
                    controller.mapController
                        .animateTo(dest: location, zoom: zoom);
                    controller.sheetController.animateTo(
                      Get.mediaQuery.padding.bottom + 120,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.bounceOut,
                    );
                    controller.findPlaces(location: location);
                  },
                  onCitySelect: ({required CityModel city}) {
                    controller.mapController.animateTo(
                      dest: LatLng(city.lat, city.lon),
                      zoom: city.zoom,
                    );
                    controller.sheetController.animateTo(
                      Get.mediaQuery.padding.bottom + 120,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.bounceOut,
                    );
                    controller.selectCity(city: city);
                  },
                  onPlaceSelect: ({required PlaceModel place}) {
                    controller.openPlaceBottomSheet(place);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
