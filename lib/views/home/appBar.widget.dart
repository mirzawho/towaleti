import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:towaleti/shared/vibration.dart';

class AppBarWidget extends StatelessWidget {
  final int state;
  final bool hasGPSPermission;
  final bool gettingGPSPermission;
  final bool showVersionBadge;
  final Function? onRquestGPSPermission;
  final Function? onGPSTap;
  final Function? onInfoTap;
  final List<GlobalKey> tutorial;

  const AppBarWidget({
    super.key,
    this.state = 0,
    this.hasGPSPermission = false,
    this.gettingGPSPermission = false,
    this.showVersionBadge = false,
    this.onRquestGPSPermission,
    this.onGPSTap,
    this.onInfoTap,
    this.tutorial = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      opacity: state == 2 ? 0 : 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: hasGPSPermission ? 0 : 1,
            child: Center(
              child: GestureDetector(
                onTap: hasGPSPermission
                    ? null
                    : () {
                        vibrate();
                        onRquestGPSPermission!();
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'دسترسی به موقعیت مکانی نداریم',
                      style: TextStyle(
                        fontFamily: "YekanBakh",
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
            width: 34,
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
                  onTap: () {
                    onInfoTap!();
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: Icon(
                          CupertinoIcons.info,
                          size: 18,
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          opacity: showVersionBadge ? 1 : 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // divider with a container line
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  width: double.infinity,
                  height: 1,
                  color: CupertinoColors.secondarySystemFill,
                ),
                Showcase(
                  key: tutorial[0],
                  title: "موقعیت مکانی",
                  description:
                      'با کلیک روی این دکمه، توالت های اطراف موقعیت مکانی الان خودتون رو پیدا می کنید.',
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
                      vibrate();
                      onGPSTap!();
                    },
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: gettingGPSPermission
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
