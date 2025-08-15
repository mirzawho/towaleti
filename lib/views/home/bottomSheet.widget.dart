import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:sheet/sheet.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:towaleti/models/ad.model.dart';
import 'package:towaleti/models/address.model.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/models/place.model.dart';
import 'package:towaleti/shared/vibration.dart';
import 'package:towaleti/shared/widget/ad.widget.dart';
import 'package:towaleti/views/home/allCities.widget.dart';
import 'package:towaleti/views/home/allPlaces.widget.dart';
import 'package:towaleti/views/home/latestCities.widget.dart';
import 'package:towaleti/views/home/links.widget.dart';

class BottomSheetWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final SheetController? sheetController;
  final TextEditingController? textEditingController;
  final bool hideTopping;
  final Function? zoomIn;
  final Function? zoomOut;
  final Function? onFindNearsetTap;
  final bool findingNearestPlace;
  final bool searching;
  final Function({required String query})? onSearchSubmit;
  final List<AddressModel> addresses;
  final void Function({required LatLng location, required double zoom})?
      onAddressSelect;
  final void Function({required CityModel city})? onCitySelect;
  final List<CityModel> latestCities;
  final List<PlaceModel> places;
  final List<PlaceModel> savedPlaces;
  final Function({required PlaceModel place})? onPlaceSelect;
  final Function()? onClearSavedPlacesTap;
  final Function()? onToggleShowSavedPlacesTap;
  final bool showSavedPlaces;
  final List<GlobalKey> tutorial;
  final AdModel? ad;

  const BottomSheetWidget({
    super.key,
    this.scrollController,
    this.sheetController,
    this.textEditingController,
    this.hideTopping = false,
    this.zoomIn,
    this.zoomOut,
    this.onFindNearsetTap,
    this.findingNearestPlace = false,
    this.searching = false,
    this.onSearchSubmit,
    this.addresses = const [],
    this.onAddressSelect,
    this.onCitySelect,
    this.latestCities = const [],
    this.savedPlaces = const [],
    this.places = const [],
    this.onPlaceSelect,
    this.onClearSavedPlacesTap,
    this.onToggleShowSavedPlacesTap,
    this.showSavedPlaces = false,
    this.tutorial = const [],
    this.ad,
  });

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels != 0) {
      sheetController!.animateTo(
        Get.height - 200,
        duration: Duration(milliseconds: 300),
        curve: Curves.bounceOut,
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      controller: sheetController,
      maxExtent: Get.height - 200,
      minExtent: Get.mediaQuery.padding.bottom + 120,
      initialExtent: Get.mediaQuery.padding.bottom + 120,
      minInteractionExtent: Get.mediaQuery.padding.bottom + 120,
      backgroundColor: CupertinoColors.transparent,
      physics: const BouncingSheetPhysics(),
      child: Column(
        children: [
          topOfBottomSheet(),
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -8),
                    color: CupertinoColors.black.withOpacity(0.12),
                    blurRadius: 48,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(
                      bottom: 8,
                      top: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.secondarySystemFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: CupertinoColors.systemGrey5,
                        ),
                      ),
                    ),
                    child: searchBar(),
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: handleScrollNotification,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            if (ad != null && ad!.place == "bellow-search-bar")
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: AdWidget(ad: ad!),
                              ),
                            if (addresses.isNotEmpty) listOfAddresses(),
                            if (ad != null &&
                                ad!.place == "bellow-list-of-addresses")
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: AdWidget(ad: ad!),
                              ),
                            if (savedPlaces.isNotEmpty && showSavedPlaces)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: AllPlacesWidget(
                                  title: 'موقعیت مکانی ذخیره شده',
                                  places: savedPlaces,
                                  onPlaceSelect: onPlaceSelect,
                                  suffixWidget: GestureDetector(
                                    onTap: () {
                                      vibrate();
                                      if (onClearSavedPlacesTap != null) {
                                        onClearSavedPlacesTap!();
                                      }
                                    },
                                    child: Text(
                                      'حذف همه',
                                      style: TextStyle(
                                        color: CupertinoColors.inactiveGray,
                                        fontSize: 12,
                                        fontFamily: "YekanBakh",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (ad != null &&
                                ad!.place == "bellow-saved-places")
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: AdWidget(ad: ad!),
                              ),
                            if (places.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: AllPlacesWidget(
                                  title: 'موقعیت مکانی یافت شده',
                                  places: places,
                                  onPlaceSelect: onPlaceSelect,
                                  suffixWidget: Text(
                                    '${places.length} مورد',
                                    style: TextStyle(
                                      color: CupertinoColors.inactiveGray,
                                      fontSize: 12,
                                      fontFamily: "YekanBakh",
                                    ),
                                  ),
                                ),
                              ),
                            if (ad != null && ad!.place == "bellow-places")
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: AdWidget(ad: ad!),
                              ),
                            if (latestCities.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: LatestCitiesWidget(
                                  cities: latestCities,
                                  onCitySelect: onCitySelect,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: AllCitiesWidget(
                                onCitySelect: onCitySelect,
                              ),
                            ),
                            if (ad != null && ad!.place == "bellow-cities")
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: AdWidget(ad: ad!),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: LinksWidget(),
                            ),
                            if (ad != null && ad!.place == "bellow-links")
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: AdWidget(ad: ad!),
                              ),
                            Gap(Get.mediaQuery.padding.bottom + 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listOfAddresses() {
    return Container(
      margin: EdgeInsets.only(top: 12),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          for (var item in addresses)
            GestureDetector(
              onTap: () {
                onAddressSelect!(
                  location: LatLng(item.lat!, item.lon!),
                  zoom: 15,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: CupertinoColors.activeBlue.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.location_solid,
                          size: 14,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                    const Gap(12),
                    SizedBox(
                      width: Get.width - 120,
                      child: Text(
                        item.address!,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: "YekanBakh",
                          color: CupertinoColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget topOfBottomSheet() {
    return AnimatedOpacity(
      opacity: hideTopping ? 0 : 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 12,
              bottom: 12,
            ),
            child: Showcase(
              key: tutorial[1],
              title: "بزرگ نمایی",
              description:
                  'با کلیک روی این دکمه، روی نقشه بزرگ نمایی می کنید و مکان های دقیق تری را پیدا می کنید.',
              titleAlignment: Alignment.centerRight,
              titleTextStyle: TextStyle(
                fontFamily: "YekanBakh",
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              descTextStyle: TextStyle(
                fontFamily: "YekanBakh",
                fontSize: 12,
              ),
              child: GestureDetector(
                onTap: () {
                  zoomIn!();
                },
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.quaternarySystemFill,
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.zoom_in,
                    size: 18,
                    color: CupertinoColors.inactiveGray,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 2,
              bottom: 12,
            ),
            child: Showcase(
              key: tutorial[2],
              title: "کوچک نمایی",
              description:
                  'با کلیک روی این دکمه، روی نقشه کوچک نمایی می کنید و می توانید مکان های بیشتری را پیدا کنید.',
              titleAlignment: Alignment.centerRight,
              titleTextStyle: TextStyle(
                fontFamily: "YekanBakh",
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              descTextStyle: TextStyle(
                fontFamily: "YekanBakh",
                fontSize: 12,
              ),
              child: GestureDetector(
                onTap: () {
                  zoomOut!();
                },
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.quaternarySystemFill,
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.zoom_out,
                    size: 18,
                    color: CupertinoColors.inactiveGray,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(
              right: 2,
              bottom: 12,
            ),
            child: Showcase(
              key: tutorial[3],
              title: "موقعیت مکانی های ذخیره شده",
              description:
                  'با کلیک روی این دکمه، می توانید لیستی از موقعیت مکانی هایی که ذخیره کرده اید را ببینید.',
              titleAlignment: Alignment.centerRight,
              titleTextStyle: TextStyle(
                fontFamily: "YekanBakh",
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              descTextStyle: TextStyle(
                fontFamily: "YekanBakh",
                fontSize: 12,
              ),
              child: AnimatedScale(
                scale: savedPlaces.isNotEmpty ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () {
                    if (savedPlaces.isNotEmpty &&
                        onToggleShowSavedPlacesTap != null) {
                      onToggleShowSavedPlacesTap!();
                    }
                  },
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.quaternarySystemFill,
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      showSavedPlaces
                          ? CupertinoIcons.bookmark_fill
                          : CupertinoIcons.bookmark,
                      size: 18,
                      color: CupertinoColors.inactiveGray,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(4),
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              bottom: 12,
            ),
            child: Showcase(
              key: tutorial[4],
              title: "نزدیک ترین توالت",
              description:
                  'با کلیک روی این دکمه، اولین و نزدیک ترین توالت اطراف خودتون رو پیدا می کنید.',
              titleAlignment: Alignment.centerRight,
              titleTextStyle: TextStyle(
                fontFamily: "YekanBakh",
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              descTextStyle: TextStyle(
                fontFamily: "YekanBakh",
                fontSize: 12,
              ),
              child: GestureDetector(
                onTap: findingNearestPlace
                    ? null
                    : () {
                        onFindNearsetTap!();
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 38,
                  width: findingNearestPlace ? 110 : 140,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.quaternarySystemFill,
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      findingNearestPlace ? 'در حال یافتن' : 'نزدیک ترین توالت',
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: CupertinoColors.inactiveGray,
                        fontFamily: "YekanBakh",
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Showcase(
      key: tutorial[5],
      title: "جستجو موقعیت مکانی",
      description:
          'با نوشتن موقعیت مکانی خودتان (مثلا: قزوین میدان عدل) لیست مکان ها را دریافت می کنید.',
      titleAlignment: Alignment.centerRight,
      titleTextStyle: TextStyle(
        fontFamily: "YekanBakh",
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: TextStyle(
        fontFamily: "YekanBakh",
        fontSize: 12,
      ),
      child: CupertinoSearchTextField(
        controller: textEditingController,
        onChanged: (value) {},
        onSubmitted: (value) {
          onSearchSubmit!(query: value);
        },
        onTap: () {
          sheetController!.animateTo(
            Get.mediaQuery.padding.bottom + 120,
            duration: Duration(milliseconds: 300),
            curve: Curves.bounceOut,
          );
        },
        onSuffixTap: () {
          textEditingController?.text = '';
          onSearchSubmit!(query: '');
        },
        placeholder: 'جستجو کنید',
        prefixIcon: searching
            ? SizedBox(
                width: 16,
                height: 16,
                child: CupertinoActivityIndicator(),
              )
            : Icon(
                CupertinoIcons.search,
                size: 20,
                color: CupertinoColors.inactiveGray,
              ),
        style: TextStyle(
          color: CupertinoColors.black,
        ),
      ),
    );
  }
}
