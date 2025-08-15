import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class DialogNoGPSPermissionView extends StatelessWidget {
  const DialogNoGPSPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 300,
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.location_slash_fill,
            size: 64,
          ),
          const Gap(20),
          Text(
            'دسترسی به موقعیت مکانی نداریم',
            style: TextStyle(
              color: CupertinoColors.black,
              fontSize: 14,
              fontFamily: "YekanBakh",
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
