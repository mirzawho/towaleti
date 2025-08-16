import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/views/home/links.widget.dart';

class DialogInfoView extends StatelessWidget {
  const DialogInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    String flavor = '';

    switch (CONSTANTS.flavor) {
      case 'cafebazaar':
        flavor = "کافه بازار";
        break;
      case 'myket':
        flavor = "مایکت";
        break;
      case 'direct':
        flavor = "دانلود مستقیم";
        break;
      case 'web':
        flavor = "وب";
        break;
      case 'sibapp':
        flavor = "سیب اپ";
        break;
      default:
    }

    return Container(
      height: Get.mediaQuery.padding.bottom + 560,
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
              fontFamily: "YekanBakh",
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                CONSTANTS.version,
                style: TextStyle(
                  color: CupertinoColors.inactiveGray,
                  fontFamily: "YekanBakh",
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                    color: CupertinoColors.inactiveGray,
                    borderRadius: BorderRadius.circular(50)),
              ),
              Text(
                flavor,
                style: TextStyle(
                  color: CupertinoColors.inactiveGray,
                  fontFamily: "YekanBakh",
                ),
              ),
            ],
          ),
          const Gap(20),
          LinksWidget(),
        ],
      ),
    );
  }
}
