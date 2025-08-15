import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/vibration.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksWidget extends StatelessWidget {
  const LinksWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
          if (CONSTANTS.urlFeedback != null &&
              (CONSTANTS.flavor == "cafebazaar" || CONSTANTS.flavor == "myket"))
            link(
              title: 'ارسال نظر و پیشنهاد',
              onTap: () {
                try {
                  launchUrl(Uri.parse(CONSTANTS.urlFeedback!));
                } catch (e) {
                  //
                }
              },
            ),
          if (CONSTANTS.urlUpdate != null && CONSTANTS.versionIsOld)
            link(
              title: 'دریافت نسخه جدید',
              onTap: () {
                try {
                  launchUrl(Uri.parse(CONSTANTS.urlUpdate!));
                } catch (e) {
                  //
                }
              },
            ),
          if (CONSTANTS.urlShare != null)
            link(
              title: 'اشتراک گذاری اپلیکییشن',
              onTap: () {
                try {
                  SharePlus.instance.share(
                    ShareParams(
                      uri: Uri.tryParse(CONSTANTS.urlShare!),
                    ),
                  );
                } catch (e) {
                  //
                }
              },
            ),
          if (CONSTANTS.urlFormAd != null)
            link(
              title: 'درخواست تبلیغات در اپلیکیشن',
              onTap: () {
                try {
                  launchUrl(Uri.parse(CONSTANTS.urlFormAd!));
                } catch (e) {
                  //
                }
              },
            ),
          if (CONSTANTS.urlFormPlace != null)
            link(
              title: 'معرفی مکان در اپلیکیشن',
              onTap: () {
                try {
                  launchUrl(Uri.parse(CONSTANTS.urlFormPlace!));
                } catch (e) {
                  //
                }
              },
            ),
        ],
      ),
    );
  }

  Widget link({
    required String title,
    String? path,
    Function? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (path != null) {
          vibrate();
          Get.toNamed(path);
        }

        if (onTap != null) {
          vibrate();
          onTap();
        }
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
                fontFamily: "YekanBakh",
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
}
