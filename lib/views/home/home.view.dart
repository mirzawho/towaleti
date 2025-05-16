import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:gap/gap.dart';
import 'package:location/location.dart';
import 'package:towaleti/shared/database/cities.database.dart';
import 'package:towaleti/shared/platform/io_map_cacher.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Location location = Location();
  MapController mapController = MapController();
  bool hasGPSPermission = true;
  bool usingGPSPermission = false;
  bool usingSearch = false;

  @override
  void initState() {
    super.initState();

    getGPSPermission();
  }

  Future<PermissionStatus> getGPSPermission() async {
    // check gps permission
    PermissionStatus permission = await location.hasPermission();

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
        // Position position = await Geolocator.getCurrentPosition(
        //   desiredAccuracy: LocationAccuracy.high,
        // );

        var position = await location.getLocation();

        mapController.move(
          LatLng(position.latitude!, position.longitude!),
          14,
        );
      }

      usingGPSPermission = false;
      setState(() {});
    } catch (e) {
      print(e);

      usingGPSPermission = false;
      setState(() {});
    }
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

  Widget header() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      opacity: usingSearch ? 0 : 1,
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
                  onTap: null,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      clipBehavior: Clip.hardEdge,
      height: usingSearch ? MediaQuery.of(context).size.height - 150 : height,
      // min height 56
      constraints: BoxConstraints(
        minHeight: height,
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  usingSearch = !usingSearch;
                });
              },
              // on drag up (open) on drag down (close)
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < 0) {
                  setState(() {
                    usingSearch = true;
                  });
                } else if (details.delta.dy > 0) {
                  setState(() {
                    usingSearch = false;
                  });
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
                  230,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(32),
                    cities(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cities() {
    Widget city({
      required String name,
      required double lat,
      required double lon,
      double zoom = 14,
    }) {
      return GestureDetector(
        onTap: () {
          mapController.move(
            LatLng(lat, lon),
            zoom,
          );
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
                name,
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
          'شهرهای نزدیک',
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
                for (var item in cities_database)
                  city(
                    name: item.name,
                    lat: item.lat,
                    lon: item.lon,
                    zoom: item.zoom,
                  ),
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
    // return CupertinoSearchTextField(
    //   enabled: false,
    //   padding: EdgeInsets.symmetric(
    //     horizontal: 12,
    //     vertical: 8,
    //   ),
    //   itemSize: 24,
    //   borderRadius: BorderRadius.circular(8),
    //   style: TextStyle(
    //     color: CupertinoColors.black,
    //   ),
    //   placeholder: 'جستجو',
    //   prefixIcon: Icon(
    //     CupertinoIcons.search,
    //     size: 20,
    //     color: CupertinoColors.inactiveGray,
    //   ),
    // );
  }
}
