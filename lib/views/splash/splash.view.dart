import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/shared/services.dart';
import 'package:towaleti/views/splash/splash.controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    Services.chrome.transparent();

    return Obx(
      () => CupertinoPageScaffold(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              SoftEdgeBlur(
                edges: [
                  EdgeBlur(
                    type: EdgeType.bottomEdge,
                    size: Get.mediaQuery.padding.bottom + 120,
                    sigma: 100,
                    tileMode: TileMode.mirror,
                    tintColor: CupertinoColors.white.withOpacity(0.7),
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
                child: IndexedStack(
                  index: controller.viewIndex.value,
                  children: [
                    logo(),
                    welcomeToApp(),
                    selectYourCity(),
                  ],
                ),
              ),
              if (controller.viewIndex != 0)
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: Get.mediaQuery.padding.bottom + 42,
                  child: pagination(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pagination() {
    Widget dot({
      bool active = false,
    }) {
      return Container(
        width: 10,
        height: 10,
        margin: EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color:
              active ? CupertinoColors.systemGrey : CupertinoColors.systemGrey4,
        ),
      );
    }

    return Row(
      children: [
        dot(
          active: controller.viewIndex == 1,
        ),
        dot(
          active: controller.viewIndex == 2,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            controller.next();
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              CupertinoIcons.arrow_left,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget logo() {
    return Center(
      child: SizedBox(
        height: 96,
        width: 96,
        child: Image.asset('lib/assets/logo.png'),
      ),
    );
  }

  Widget selectYourCity() {
    Widget city({
      required CityModel item,
      String? message,
      String? selected,
    }) {
      return GestureDetector(
        onTap: () {
          controller.selectCity(city: item);
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (message != null && message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: CupertinoColors.black.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              CupertinoRadio(
                useCheckmarkStyle: true,
                value: selected,
                groupValue: item.name,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectCity(city: item);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return Obx(
      () => Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Gap(
                Get.mediaQuery.padding.top + 24,
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
              city(
                item: controller.currentPosition.value,
                selected: controller.selectedCity.value,
                message: controller.currentPositionMessage.value,
              ),
              for (var item in Services.city.sortedCities.value)
                city(
                  item: item,
                  selected: controller.selectedCity.value,
                ),
              Gap(
                Get.mediaQuery.padding.bottom + 100,
              ),
            ],
          ),
        ),
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
}
