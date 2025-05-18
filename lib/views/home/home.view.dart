import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:gap/gap.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/models/place.model.dart';
import 'package:towaleti/shared/database/cities.database.dart';
import 'package:towaleti/shared/platform/map_cacher.dart';
import 'package:towaleti/shared/platform/location.dart';
import 'package:location/location.dart' show PermissionStatus;
import 'package:towaleti/shared/services/database.dart';
import 'package:towaleti/shared/services/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Location location = Location();
  DatabaseService database = DatabaseService();
  HttpService http = HttpService();
  MapController mapController = MapController();
  bool hasGPSPermission = true;
  bool usingGPSPermission = false;
  bool usingSearch = false;
  Timer? timerSearch;
  List<PlaceModel> places = [];
  List<CityModel> citiesLatest = [];
  List<CityModel> citiesSorted = [];
  int bottomSheetState =
      0; // 0 = closed (just search appear), 1 = half, 2 = full

  @override
  void initState() {
    super.initState();

    getGPSPermission();
    initCitiesLatest();
    initCitiesSorted();
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
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              '0.1.0',
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

        mapController.move(
          LatLng(position.latitude, position.longitude),
          14,
        );

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

    mapController.move(
      LatLng(city.lat, city.lon),
      city.zoom,
    );

    searchOnLocation();
    initCitiesLatest();
  }

  void searchOnLocation() {
    if (timerSearch != null) {
      timerSearch!.cancel();
    }
    timerSearch = Timer(const Duration(milliseconds: 500), () async {
      var location = await database.getMap(key: 'location');

      if (location != null) {
        mapController.move(
          LatLng(location['lat'], location['lon']),
          location['zoom'] == null
              ? 13
              : double.parse(location['zoom'].toString()),
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
                name: item['data']['name'],
                address: item['data']['address'],
              ),
            );
          }

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
          height: 240,
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
                  Text(
                    place.name,
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);

                      // open maps
                      launchUrl(
                        Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lon}',
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
                        CupertinoIcons.location,
                        size: 16,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                  const Gap(8),
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
              Text(
                place.address,
                style: TextStyle(
                  color: CupertinoColors.inactiveGray,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Gap(
                MediaQuery.of(context).padding.bottom + 16,
              ),
            ],
          ),
        );
      },
    );
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
          print('moving to $path');
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
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(32.4207423, 53.6830157),
              initialZoom: 5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              onMapReady: () {
                searchOnLocation();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://map.doting.ir/osm_bright/{z}/{x}/{y}.png',
                maxZoom: 15,
                // disable rotation
                tileProvider: CachedTileProvider(
                  // use the store for your CachedTileProvider instance
                  store: cacheStore,
                ),
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
                          mapController.move(
                            LatLng(item.lat, item.lon),
                            15,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      clipBehavior: Clip.hardEdge,
      height: currentHeight,
      // min height 56
      constraints: BoxConstraints(
        minHeight: height,
      ),
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
      child: NotificationListener(
        onNotification: (ScrollNotification notification) {
          // handle 3 times bottom height state
          if (notification is ScrollUpdateNotification) {
            // Detect scroll direction
            bool isScrollingDown = notification.scrollDelta != null &&
                notification.scrollDelta! > 0;
            bool isScrollingUp = notification.scrollDelta != null &&
                notification.scrollDelta! < 0;
            bool isAtTop = notification.metrics.pixels == 0;

            // Handle scrolling down
            if (isScrollingDown && bottomSheetState < 2) {
              setState(() {
                bottomSheetState = 2;
                usingSearch = true;
              });
            }

            // Handle scrolling up when at top
            if (isScrollingUp && isAtTop) {
              if (bottomSheetState == 2) {
                setState(() {
                  bottomSheetState = 1;
                });
              } else if (bottomSheetState == 1) {
                setState(() {
                  bottomSheetState = 0;
                  usingSearch = false;
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
                },
                // on drag up (open) on drag down (close)
                // Replace the empty onVerticalDragUpdate with:
                onVerticalDragUpdate: (details) {
                  // Dragging up
                  if (details.delta.dy < -10) {
                    if (bottomSheetState == 0) {
                      setState(() {
                        bottomSheetState = 1;
                        usingSearch = true;
                      });
                    }
                  }

                  // Dragging down
                  if (details.delta.dy > 10) {
                    if (bottomSheetState == 2) {
                      setState(() {
                        bottomSheetState = 1;
                      });
                    } else if (bottomSheetState == 1) {
                      setState(() {
                        bottomSheetState = 0;
                        usingSearch = false;
                      });
                    }
                  }
                },
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
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.bottom -
                    210,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 4,
                    right: 4,
                    bottom: MediaQuery.of(context).padding.bottom + 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(32),
                      if (places.isNotEmpty) locations(),
                      if (citiesLatest.isNotEmpty) latestCities(),
                      cities(),
                      const Gap(12),
                      links(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                    mapController.move(
                      LatLng(item.lat, item.lon),
                      15,
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
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
