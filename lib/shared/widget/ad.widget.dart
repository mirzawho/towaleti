import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:glass/glass.dart';
import 'package:towaleti/models/ad.model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdWidget extends StatelessWidget {
  final AdModel ad;

  const AdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    if (ad.version == 1) {
      return v1();
    }

    if (ad.version == 2) {
      return v2();
    }

    return Container();
  }

  Widget v1() {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.extraLightBackgroundGray,
        borderRadius: BorderRadius.circular(8),
        image: ad.background == null
            ? null
            : DecorationImage(
                image: NetworkImage(ad.background!),
                fit: BoxFit.cover,
              ),
      ),
      child: Column(
        children: [
          const Spacer(),
          if (ad.logo != null)
            Container(
              clipBehavior: Clip.hardEdge,
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: NetworkImage(ad.logo!)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(32, 0, 0, 0),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          const Spacer(),
          Container(
            padding: EdgeInsets.only(
              top: 40,
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(220, 0, 0, 0),
                  Color(0x00000000),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        style: TextStyle(
                          fontFamily: "YekanBakh",
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 18,
                            decoration: BoxDecoration(
                              color: CupertinoColors.activeBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                'AD',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          const Gap(12),
                          SizedBox(
                            width: Get.width - 200,
                            child: Text(
                              ad.subtitle,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "YekanBakh",
                                color: CupertinoColors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                GestureDetector(
                  onTap: () {
                    launchUrl(
                      Uri.parse(
                        ad.url,
                      ),
                    );
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(128, 255, 255, 255),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        ad.button,
                        style: TextStyle(
                          fontFamily: "YekanBakh",
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ).asGlass(
                    clipBorderRadius: BorderRadius.circular(50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget v2() {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (ad.logo != null)
            Container(
              clipBehavior: Clip.hardEdge,
              height: 48,
              width: 48,
              margin: EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: NetworkImage(ad.logo!)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(32, 0, 0, 0),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: TextStyle(
                    fontFamily: "YekanBakh",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: Get.width - 220,
                  child: Text(
                    ad.subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CupertinoColors.inactiveGray,
                      fontFamily: "YekanBakh",
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ),
          const Gap(12),
          CupertinoButton.tinted(
            color: CupertinoColors.activeOrange,
            sizeStyle: CupertinoButtonSize.small,
            onPressed: () {
              launchUrl(
                Uri.parse(
                  ad.url,
                ),
              );
            },
            child: Text(
              ad.button,
              style: TextStyle(
                color: CupertinoColors.activeOrange,
                fontFamily: "YekanBakh",
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
