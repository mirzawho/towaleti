import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:gap/gap.dart';
import 'package:towaleti/models/ad.model.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/models/place.model.dart';
import 'package:towaleti/shared/database/cities.database.dart';
import 'package:towaleti/shared/platform/map_cacher.dart';
import 'package:towaleti/shared/platform/location.dart';
import 'package:location/location.dart' show PermissionStatus;
import 'package:towaleti/shared/services/database.dart';
import 'package:towaleti/shared/services/http.dart';
import 'package:towaleti/shared/widget/ad.widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  Location location = Location();
  DatabaseService database = DatabaseService();
  HttpService http = HttpService();
  late AnimatedMapController mapController = AnimatedMapController(vsync: this);
  ScrollController scrollController = ScrollController();
  bool hasGPSPermission = true;
  bool usingGPSPermission = false;
  bool usingSearch = false;
  Timer? timerSearch;
  List<PlaceModel> places = [];
  List<CityModel> citiesLatest = [];
  List<CityModel> citiesSorted = [];
  int bottomSheetState =
      0; // 0 = closed (just search appear), 1 = half, 2 = full
  LatLng? currentPosition;
  bool isChangingState = false;
  AdModel? ad;

  @override
  void initState() {
    super.initState();

    getGPSPermission();
    initCitiesLatest();
    initCitiesSorted();
    initAd();
    initHandshake();
  }

  void zoomIn() {
    var zoom = mapController.mapController.camera.zoom + 1;

    if (zoom <= 17) {
      mapController.animateTo(
        dest: mapController.mapController.camera.center,
        zoom: zoom,
      );
    }
  }

  void zoomOut() {
    var zoom = mapController.mapController.camera.zoom - 1;

    if (zoom >= 3) {
      mapController.animateTo(
        dest: mapController.mapController.camera.center,
        zoom: zoom,
      );
    }
  }

  void openInfoBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 310,
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 12,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.quaternarySystemFill,
              blurRadius: 12,
              spreadRadius: 1,
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
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemFill,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Gap(20),
            Text(
              'توالتی',
              style: TextStyle(
                color: CupertinoColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              '2.0.0',
              style: TextStyle(
                color: CupertinoColors.inactiveGray,
              ),
            ),
            const Gap(20),
            links(),
          ],
        ),
      ),
    );
  }

  Future<PermissionStatus> getGPSPermission() async {
    try {
      // check gps permission
      PermissionStatus permission = await location.getPermission();

      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
      }

      if ((permission == PermissionStatus.denied ||
              permission == PermissionStatus.deniedForever) &&
          mounted) {
        // show dialog
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('دسترسی به موقعیت مکانی'),
              content: const Text(
                  'برای دسترسی به موقعیت مکانی، لطفا دسترسی را فعال کنید.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('باشه'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      }

      // if permission access is true, set has gps permission to true
      if (permission == PermissionStatus.granted ||
          permission == PermissionStatus.grantedLimited) {
        hasGPSPermission = true;
      } else {
        hasGPSPermission = false;
      }
      setState(() {});

      return permission;
    } catch (e) {
      print(e);
      hasGPSPermission = false;
      setState(() {});
      return PermissionStatus.denied;
    }
  }

  void flyToMyLocation() async {
    if (!hasGPSPermission) {
      return;
    }

    try {
      usingGPSPermission = true;
      setState(() {});

      var permission = await getGPSPermission();

      if (permission == PermissionStatus.granted ||
          permission == PermissionStatus.grantedLimited) {
        var position = await location.getLocation();

        mapController.animateTo(
          dest: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );

        currentPosition = LatLng(position.latitude, position.longitude);

        // save location to database
        database.setDynamic(
          key: 'location',
          value: {
            'lat': position.latitude,
            'lon': position.longitude,
            'zoom': 14,
          },
        );

        searchOnLocation();
      }

      usingGPSPermission = false;
      setState(() {});
    } catch (e) {
      print(e);

      usingGPSPermission = false;
      setState(() {});
    }
  }

  void initCitiesLatest() async {
    var values = await database.getArray(key: 'city_latest');
    citiesLatest = [];

    if (values.isNotEmpty) {
      for (var item in values) {
        var city = cities_database.firstWhere(
          (element) => element.name == item,
          orElse: () => CityModel(
            name: 'نامشخص',
            lat: 0,
            lon: 0,
            zoom: 5,
          ),
        );
        citiesLatest.add(city);
      }
    }

    setState(() {});
  }

  void initCitiesSorted() async {
    citiesSorted = [...cities_database];
    citiesSorted.sort((a, b) => a.name.compareTo(b.name));
    setState(() {});
  }

  void initAd() async {
    try {
      var result = await http.ad();

      if (result['ok'] == true) {
        ad = AdModel.fromJson(
          result['ad'],
        );

        bottomSheetState = 1;
      }

      setState(() {});
    } catch (e) {
      //
    }
  }

  void initHandshake() async {
    try {
      await http.handshake();
    } catch (e) {
      //
    }
  }

  void onSelectCity({required CityModel city}) async {
    var values = await database.getArray(key: 'city_latest');

    // check city exists to values, remove and insert to top
    if (values.contains(city.name)) {
      values.remove(city.name);
    }

    values.insert(0, city.name);

    if (values.length > 5) {
      values = values.getRange(0, 4).toList();
    }

    database.setDynamic(key: 'city_latest', value: values);
    database.setDynamic(
      key: 'location',
      value: {
        'lat': city.lat,
        'lon': city.lon,
        'zoom': city.zoom,
      },
    );

    mapController.animateTo(
      dest: LatLng(city.lat, city.lon),
      zoom: city.zoom,
    );

    searchOnLocation();
    initCitiesLatest();

    setState(() {
      bottomSheetState = 1;
      usingSearch = false;
    });
  }

  void searchOnLocation() {
    if (timerSearch != null) {
      timerSearch!.cancel();
    }
    timerSearch = Timer(const Duration(milliseconds: 500), () async {
      var location = await database.getMap(key: 'location');

      if (location != null &&
          location['lat'] != null &&
          location['lon'] != null) {
        double zoom = location['zoom'] == null
            ? 13.0
            : double.parse(location['zoom'].toString());

        if (zoom < 13) {
          places = [];
          setState(() {});
          return;
        }

        mapController.animateTo(
          dest: LatLng(location['lat'], location['lon']),
          zoom: zoom,
        );

        var result = await http.search(
          lat: location['lat'],
          lon: location['lon'],
          zoom: int.tryParse(location['zoom'].toString()) ?? 14,
        );

        if (result['ok'] == true && result['places'] != null) {
          places = [];

          for (var item in result['places']) {
            places.add(
              PlaceModel(
                lat: item['data']['geometry']['lon'],
                lon: item['data']['geometry']['lat'],
                distance: double.parse(item['data']['distance'].toString()),
                name: item['data']['name'],
                address: item['data']['address'],
              ),
            );
          }

          // sort places with distance
          places.sort((a, b) => a.distance.compareTo(b.distance));

          bottomSheetState = 1;

          setState(() {});
        } else {
          places = [];
          setState(() {});
        }
      }
    });
  }

  void onSelectPlace({required PlaceModel place}) {
    // open bottom sheet
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Container(
          height: 320,
          width: double.infinity,
          padding: EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.quaternarySystemFill,
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Gap(8),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 96,
                    child: Text(
                      place.name,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);

                      // open share dialog
                      SharePlus.instance.share(
                        ShareParams(
                          subject: 'اشتراک گذاری مکان',
                          uri: Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lon}',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: CupertinoColors.inactiveGray.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        CupertinoIcons.share,
                        size: 16,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                  const Gap(8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: CupertinoColors.inactiveGray.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        CupertinoIcons.multiply,
                        size: 16,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CupertinoColors.inactiveGray.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentPosition != null)
                      Text(
                        'فاصله',
                        style: TextStyle(
                          color: CupertinoColors.inactiveGray,
                          fontSize: 10,
                        ),
                      ),
                    if (currentPosition != null)
                      Text(
                        place.distance < 1
                            ? '${(place.distance * 1000).toStringAsFixed(0)} متر'
                            : '${place.distance.toStringAsFixed(1)} کیلومتر',
                        style: TextStyle(
                          color: CupertinoColors.black,
                          fontSize: 14,
                        ),
                      ),
                    if (currentPosition != null) const Gap(12),
                    Text(
                      'آدرس',
                      style: TextStyle(
                        color: CupertinoColors.inactiveGray,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      place.address,
                      style: TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: CupertinoButton.filled(
                  sizeStyle: CupertinoButtonSize.medium,
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () {
                    Navigator.pop(context);

                    // open maps
                    launchUrl(
                      Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lon}',
                      ),
                    );
                  },
                  child: Text(
                    'مسیریابی',
                    style: TextStyle(
                      fontFamily: "YekanBakh",
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Gap(
                MediaQuery.of(context).padding.bottom + 16,
              ),
            ],
          ),
        );
      },
    );
  }

  void onMapMove() {
    // set latest location
    database.setDynamic(
      key: 'location',
      value: {
        'lat': mapController.mapController.camera.center.latitude,
        'lon': mapController.mapController.camera.center.longitude,
        'zoom': mapController.mapController.camera.zoom,
      },
    );

    searchOnLocation();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
                  size: MediaQuery.of(context).padding.top + 42,
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
              child: map(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 42,
            left: 0,
            right: 0,
            child: header(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: bottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget links() {
    Widget link({
      required String title,
      required String path,
    }) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, path);
        },
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chevron_back,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          link(
            title: 'شرایط استفاده',
            path: '/terms',
          ),
          link(
            title: 'حریم خصوصی',
            path: '/privacy',
          ),
          link(
            title: 'درباره ما',
            path: '/about',
          ),
        ],
      ),
    );
  }

  Widget header() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      opacity: bottomSheetState == 2 ? 0 : 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: hasGPSPermission ? 0 : 1,
            child: Center(
              child: GestureDetector(
                onTap: hasGPSPermission ? null : () => getGPSPermission(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'دسترسی به موقعیت مکانی نداریم',
                      style: TextStyle(
                        color: CupertinoColors.black,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      CupertinoIcons.forward,
                      size: 20,
                      color: CupertinoColors.black,
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: 12,
            ),
            width: 38,
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.quaternarySystemFill,
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => openInfoBottomSheet(),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      CupertinoIcons.info,
                      size: 18,
                      color: CupertinoColors.inactiveGray,
                    ),
                  ),
                ),
                // divider with a container line
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  width: double.infinity,
                  height: 1,
                  color: CupertinoColors.secondarySystemFill,
                ),
                GestureDetector(
                  onTap: () => flyToMyLocation(),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: usingGPSPermission
                        ? CupertinoActivityIndicator(
                            radius: 8,
                          )
                        : Icon(
                            CupertinoIcons.location,
                            size: 18,
                            color: CupertinoColors.inactiveGray,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget map() {
    return FutureBuilder(
      future: getCacheStore(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final cacheStore = snapshot.data!;
          return FlutterMap(
            mapController: mapController.mapController,
            options: MapOptions(
              initialCenter: LatLng(32.4207423, 53.6830157),
              initialZoom: 5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              onMapReady: () {
                searchOnLocation();
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  onMapMove();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://map.doting.ir/osm_bright/{z}/{x}/{y}.png',
                // disable rotation
                tileProvider: kIsWeb
                    ? null
                    : CachedTileProvider(
                        // use the store for your CachedTileProvider instance
                        store: cacheStore,
                      ),
              ),
              MarkerLayer(
                markers: [
                  if (currentPosition != null)
                    Marker(
                      point: currentPosition!,
                      width: 20,
                      height: 20,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.quaternarySystemFill,
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: CupertinoColors.white,
                            width: 2,
                          ),
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (var item in places)
                    Marker(
                      point: LatLng(item.lat, item.lon),
                      width: 24,
                      height: 24,
                      child: GestureDetector(
                        onTap: () {
                          mapController.animateTo(
                            dest: LatLng(item.lat, item.lon),
                            zoom: 15,
                          );

                          onSelectPlace(place: item);

                          setState(() {
                            bottomSheetState =
                                bottomSheetState == 2 ? 1 : bottomSheetState;
                            usingSearch = false;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CupertinoColors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.quaternarySystemFill,
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(100),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xfffde68a),
                                Color(0xfffbbf24),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.map_pin,
                              size: 12,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }

  Widget bottomSheet() {
    var height = MediaQuery.of(context).padding.bottom + 16 + 56 + 4 + 16;
    var halfHeigth = height + 200;
    var fullHeight = MediaQuery.of(context).size.height - 150;

    var currentHeight = height;

    if (bottomSheetState == 1) {
      currentHeight = halfHeigth;
    }

    if (bottomSheetState == 2) {
      currentHeight = fullHeight;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          opacity: bottomSheetState == 2 ? 0 : 1,
          duration: Duration(milliseconds: 500),
          curve: Curves.bounceIn,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => zoomIn(),
                child: Container(
                  margin: EdgeInsets.only(
                    right: 12,
                    bottom: 12,
                  ),
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
              GestureDetector(
                onTap: () => zoomOut(),
                child: Container(
                  margin: EdgeInsets.only(
                    right: 2,
                    bottom: 12,
                  ),
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
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          clipBehavior: Clip.hardEdge,
          height: currentHeight,
          // min height 56
          constraints: BoxConstraints(
            minHeight: height,
          ),

          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.quaternarySystemFill,
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: NotificationListener(
            onNotification: (ScrollNotification notification) {
              // handle 3 times bottom height state
              if (notification is ScrollUpdateNotification) {
                // Detect scroll direction
                bool isScrollingDown = notification.scrollDelta != null &&
                    notification.scrollDelta! > 0;
                bool isAtTop = notification.metrics.pixels <= 10;

                // Handle scrolling down
                if (isScrollingDown &&
                    bottomSheetState < 2 &&
                    !isChangingState) {
                  isChangingState = true;
                  bottomSheetState = 2;
                  usingSearch = true;
                  setState(() {});
                  // Reset flag after short delay
                  Future.delayed(Duration(milliseconds: 1000), () {
                    isChangingState = false;
                    setState(() {});
                  });
                }

                // Handle scrolling up when at top
                if (isAtTop) {
                  if (bottomSheetState == 2 && !isChangingState) {
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                    );
                    isChangingState = true;
                    bottomSheetState = 1;
                    setState(() {});
                    // Reset flag after short delay
                    Future.delayed(Duration(milliseconds: 1000), () {
                      isChangingState = false;
                      setState(() {});
                    });
                  }
                }
              }

              return true;
            },
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        usingSearch = !usingSearch;
                        bottomSheetState = usingSearch ? 1 : 0;
                      });

                      scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                      );
                    },
                    // on drag up (open) on drag down (close)
                    // Replace the empty onVerticalDragUpdate with:
                    onVerticalDragUpdate: (details) {
                      // Dragging up
                      if (details.delta.dy < 0) {
                        if (bottomSheetState == 0) {
                          setState(() {
                            bottomSheetState = 1;
                            usingSearch = true;
                          });
                        }
                      }

                      // Dragging down
                      if (details.delta.dy > 0) {
                        if (bottomSheetState == 1) {
                          setState(() {
                            bottomSheetState = 0;
                            usingSearch = false;
                          });
                        } else if (bottomSheetState == 2) {
                          scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                          );
                          setState(() {
                            bottomSheetState = 1;
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 12,
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: bottomSheetState != 0
                                ? CupertinoColors.systemGrey6
                                : CupertinoColors.white,
                            width: bottomSheetState != 0 ? 1 : 0,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: EdgeInsets.only(
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.secondarySystemFill,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          search(),
                        ],
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: bottomSheetState != 0 ? 1 : 0,
                    duration: Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      height: bottomSheetState == 1
                          ? 300
                          : MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.bottom -
                              210,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: MediaQuery.of(context).padding.bottom + 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(12),
                            if (places.isNotEmpty) locations(),
                            if (ad != null) AdWidget(ad: ad!),
                            if (citiesLatest.isNotEmpty) latestCities(),
                            cities(),
                            const Gap(12),
                            links(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget locations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'موقعیت مکانی',
          style: TextStyle(
            color: CupertinoColors.inactiveGray,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        Container(
          margin: EdgeInsets.only(bottom: 12),
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
              for (var item in places)
                CupertinoListTile.notched(
                  onTap: () {
                    mapController.animateTo(
                      dest: LatLng(item.lat, item.lon),
                      zoom: 15,
                    );

                    onSelectPlace(place: item);

                    setState(() {
                      bottomSheetState =
                          bottomSheetState == 2 ? 1 : bottomSheetState;
                      usingSearch = false;
                    });
                  },
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 8,
                    right: 12,
                    bottom: 8,
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 150,
                        ),
                        child: Text(
                          item.name,
                          softWrap: true,
                          style: TextStyle(
                            color: CupertinoColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Gap(4),
                      if (currentPosition != null)
                        Text(
                          item.distance < 1
                              ? '${(item.distance * 1000).toStringAsFixed(0)} متر'
                              : '${item.distance.toStringAsFixed(1)} کیلومتر',
                          style: TextStyle(
                            color: CupertinoColors.inactiveGray,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    item.address,
                    style: TextStyle(
                      color: CupertinoColors.inactiveGray,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: CupertinoColors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.quaternarySystemFill,
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xfffde68a),
                          Color(0xfffbbf24),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.map_pin,
                        size: 20,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget latestCities() {
    Widget city({
      required CityModel value,
    }) {
      return GestureDetector(
        onTap: () {
          onSelectCity(city: value);

          setState(() {
            usingSearch = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
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
              Text(
                value.name,
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'شهر های اخیر',
            style: TextStyle(
              color: CupertinoColors.inactiveGray,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var item in citiesLatest) city(value: item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cities() {
    Widget city({
      required CityModel value,
    }) {
      return GestureDetector(
        onTap: () {
          onSelectCity(city: value);

          setState(() {
            usingSearch = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.location_solid,
                    size: 20,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
              const Gap(8),
              Text(
                value.name,
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'همه شهر ها',
          style: TextStyle(
            color: CupertinoColors.inactiveGray,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        Container(
          height: 110,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var item in citiesSorted) city(value: item),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget search() {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemFill,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.quaternarySystemFill,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            size: 20,
            color: CupertinoColors.systemGrey,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              'جستجو',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
