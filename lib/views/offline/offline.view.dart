import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:towaleti/shared/services.dart';
import 'package:towaleti/shared/vibration.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({super.key});

  @override
  Widget build(BuildContext context) {
    Services.chrome.transparent();

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        vibrate();
      },
      child: CupertinoPageScaffold(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.wifi_slash,
                size: 64,
              ),
              const Gap(20),
              const Text(
                'اتصال به اینترنت برقرار نمی باشد!',
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "YekanBakh",
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
