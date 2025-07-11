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

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  DatabaseService databaseService = DatabaseService();
  AccessService accessService = AccessService();
  HttpService http = HttpService();
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
      statusBarColor: CupertinoColors.white,
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

  void nextStep() {
    if (step == 3) {
      databaseService.set(key: 'splashed', value: 'true');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      step += 1;
      setState(() {});
    }
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
                  selectedCityName = item.name;
                  setState(() {});
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
                  size: 500,
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
                  Text(
                    'در هر موقعیتی در نقشه یا شهری که انتخاب کرده باشید. تعدادی توالت و دستشویی های اطراف شما رو بهتون نشون میدیم. با کلیک و ضربه زدن روی اون ها اطلاعاتش رو می تونید داشته باشید و با مسیریابی از جایی که هستید تا توالتی که انتخاب کردید مسیر رو بهتون میدیم.',
                    style: TextStyle(
                      color: CupertinoColors.black.withOpacity(0.7),
                      fontFamily: "YekanBakh",
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
