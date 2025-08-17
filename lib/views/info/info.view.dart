import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/widget/links.widget.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key});

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

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        child: Column(
          children: [
            const Gap(20),
            Row(
              children: [
                Image.asset(
                  'lib/assets/logo.png',
                  width: 64,
                  height: 64,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'توالتی',
                      style: TextStyle(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
                  ],
                ),
              ],
            ),
            const Gap(20),
            LinksWidget(),
          ],
        ),
      ),
    );
  }
}
