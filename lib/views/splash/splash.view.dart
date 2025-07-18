import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/database/cities.database.dart';
import 'package:towaleti/shared/services/access.service.dart';
import 'package:towaleti/shared/services/database.dart';
import 'package:towaleti/shared/services/http.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:towaleti/shared/vibration.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  DatabaseService databaseService = DatabaseService();
  AccessService accessService = AccessService();
  HttpService http = HttpService();
  DatabaseService database = DatabaseService();
  late AnimatedMapController mapController = AnimatedMapController(vsync: this);
  int step = 0;
  int substep = 0;
  bool ready = false;
  List<CityModel> citiesSorted = [];
  String selectedCityName = '';

  void initHandshake() async {
    try {
      var result = await http.handshake();

      if (result['ok']) {
        CONSTANTS.versionIsOld = result['data']['isUpdateAvailable'];
        CONSTANTS.verionIsDeprecated = result['data']['isDeprecated'];
        CONSTANTS.urlFeedback = result['data']['url_feedback'];
        CONSTANTS.urlUpdate = result['data']['url_update'];
        if (result['data']['url_map'] != null) {
          CONSTANTS.urlMap = result['data']['url_map'];
        }
        ready = true;
        setState(() {});
      }
    } catch (e) {
      //
    }
  }

  void initCitiesSorted() async {
    citiesSorted = [...cities_database];
    citiesSorted.sort((a, b) => a.name.compareTo(b.name));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    initHandshake();
    initCitiesSorted();

    // transparent status and navigation bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: CupertinoColors.transparent,
      systemNavigationBarColor: CupertinoColors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    accessService.generatePackageInfo().then((package) {
      CONSTANTS.version = package.version;
    });

    databaseService.get(key: 'splashed').then((value) {
      if (value != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        step = 1;
        setState(() {});
      }
    });
  }

  void onSelectCity({required CityModel city}) async {
    vibrate();

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

    setState(() {
      selectedCityName = city.name;
    });
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

  void flyTo(LatLng latLng, {double zoom = 16}) {
    mapController.animateTo(
      dest: latLng,
      zoom: zoom,
    );
  }

  void nextStep() {
    if (step == 3) {
      databaseService.set(key: 'splashed', value: 'true');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      step += 1;
      if (step == 2) {
        startSubstep();
      }
      setState(() {});
    }
  }

  void startSubstep() {
    List<CityModel> list = [
      CityModel(
        name: 'ایران',
        lat: 32.4207423,
        lon: 53.6830157,
        zoom: 5,
      ),
      CityModel(
        name: 'تهران',
        lat: 35.6892,
        lon: 51.3890,
        zoom: 10,
      ),
      CityModel(
        name: 'قزوین',
        lat: 36.2797,
        lon: 50.0049,
        zoom: 12,
      ),
      CityModel(
        name: 'مشهد',
        lat: 36.2605,
        lon: 59.6168,
        zoom: 12,
      ),
      CityModel(
        name: 'اصفهان',
        lat: 32.6539,
        lon: 51.6660,
        zoom: 12,
      ),
      CityModel(
        name: 'شیراز',
        lat: 29.5917,
        lon: 52.5836,
        zoom: 12,
      ),
      CityModel(
        name: 'تبریز',
        lat: 38.0962,
        lon: 46.2738,
        zoom: 13,
      ),
    ];

    Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          substep = substep + 1 == 7 ? 0 : substep + 1;
          flyTo(
            LatLng(
              list[substep].lat,
              list[substep].lon,
            ),
            zoom: list[substep].zoom,
          );
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            IndexedStack(
              index: step,
              children: [
                Container(),
                welcomeToApp(),
                howToUse(),
                selectYourCity(),
              ],
            ),
            if (ready)
              Positioned(
                left: 40,
                right: 40,
                bottom: MediaQuery.of(context).padding.bottom + 20,
                child: CupertinoButton.filled(
                  child: Text(
                    'بعدی',
                    style: TextStyle(
                      fontFamily: "YekanBakh",
                    ),
                  ),
                  onPressed: () => nextStep(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget selectYourCity() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Gap(
              MediaQuery.of(context).padding.top + 24,
            ),
            Text(
              'کدام شهر',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: CupertinoColors.black,
                fontFamily: "YekanBakh",
              ),
            ),
            const Gap(4),
            Text(
              'شهری که دنبال توالت هاش هستید رو انتخاب کنید',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.black.withOpacity(0.7),
                fontFamily: "YekanBakh",
              ),
            ),
            const Gap(10),
            for (var item in citiesSorted)
              GestureDetector(
                onTap: () {
                  onSelectCity(city: item);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.inactiveGray.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Gap(10),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: CupertinoColors.activeBlue.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.location_solid,
                            size: 16,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                      const Gap(8),
                      Text(
                        item.name,
                        style: TextStyle(
                          color: CupertinoColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      CupertinoRadio(
                        useCheckmarkStyle: true,
                        value: selectedCityName,
                        groupValue: item.name,
                        onChanged: (value) {
                          if (value != null) {
                            selectedCityName = value;
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Gap(
              MediaQuery.of(context).padding.bottom + 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget howToUse() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: SoftEdgeBlur(
              edges: [
                EdgeBlur(
                  type: EdgeType.topEdge,
                  size: 100,
                  sigma: 280,
                  tileMode: TileMode.mirror,
                  tintColor: CupertinoColors.white.withOpacity(0.24),
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
                EdgeBlur(
                  type: EdgeType.bottomEdge,
                  size: 400,
                  sigma: 280,
                  tileMode: TileMode.mirror,
                  tintColor: CupertinoColors.white,
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
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                // color: CupertinoColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'توالتی چطور کار می کنه ؟',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "YekanBakh",
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: Text(
                      // 'در هر موقعیتی در نقشه یا شهری که انتخاب کرده باشید. تعدادی توالت و دستشویی های اطراف شما رو بهتون نشون میدیم. با کلیک و ضربه زدن روی اون ها اطلاعاتش رو می تونید داشته باشید و با مسیریابی از جایی که هستید تا توالتی که انتخاب کردید مسیر رو بهتون میدیم.',
                      [
                        '۱. موقعیت مکانی که هستید رو انتخاب می کنید.',
                        '۲. می تونید موقعیت مکانیتون رو به ما ارسال کنید یا دکمه نزدیک ترین توالت رو بزنید.',
                        '۳. حتی می تونید روی نقشه بگردید و توالت های اطراف رو پیدا کنید.',
                        '۴. آدرس جایی که می خواهید رو بنویسید و توالت های اون جا رو پیدا کنید.',
                        '۵. شهری که می خواهید رو انتخاب کنید و توالت های شهر رو ببینید.',
                        '۶. حالا ما بر اساس موقعیتی که بهمون دادید بهتون توالت های اونجا رو بهتون میدیم.',
                        '۷. شما هم هر توالتی رو خواستید رو انتخاب کنید و دکمه مسیریابی رو بزنید یا با یکی به اشتراک بذارید.'
                      ][substep],
                      style: TextStyle(
                        color: CupertinoColors.black.withOpacity(0.7),
                        fontFamily: "YekanBakh",
                      ),
                    ),
                  ),
                  const Gap(100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget welcomeToApp() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                'lib/assets/hello.png',
              ),
            ),
            const Gap(24),
            Text(
              'به توالتی خوش اومدی',
              style: TextStyle(
                fontFamily: "YekanBakh",
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: CupertinoColors.black,
              ),
            ),
            Text(
              'فقط توالت های اطراف خودت رو پیدا کن',
              style: TextStyle(
                fontFamily: "YekanBakh",
                color: CupertinoColors.darkBackgroundGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget map() {
    return FlutterMap(
      mapController: mapController.mapController,
      options: MapOptions(
        initialCenter: LatLng(32.4207423, 53.6830157),
        initialZoom: 5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: CONSTANTS.urlMap,
        ),
      ],
    );
  }
}
