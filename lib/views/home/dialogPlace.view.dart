import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:towaleti/models/firebase.model.dart';
import 'package:towaleti/models/place.model.dart';
import 'package:towaleti/shared/services.dart';
import 'package:towaleti/shared/vibration.dart';

class DialogPlaceView extends StatefulWidget {
  final PlaceModel place;

  const DialogPlaceView({
    super.key,
    required this.place,
  });

  @override
  State<DialogPlaceView> createState() => _DialogPlaceViewState();
}

class _DialogPlaceViewState extends State<DialogPlaceView> {
  bool saved = false;

  @override
  void initState() {
    super.initState();

    saved = Services.place.contains(place: widget.place);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
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
          ),
          const Gap(8),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 68,
                child: Text(
                  widget.place.name,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "YekanBakh",
                    color: CupertinoColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Gap(8),
              GestureDetector(
                onTap: () {
                  vibrate();
                  Get.back();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: CupertinoColors.inactiveGray.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    CupertinoIcons.multiply,
                    size: 16,
                    color: CupertinoColors.inactiveGray,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoColors.inactiveGray.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.place.distance != 0)
                  Text(
                    'فاصله',
                    style: TextStyle(
                      fontFamily: "YekanBakh",
                      color: CupertinoColors.inactiveGray,
                      fontSize: 10,
                    ),
                  ),
                if (widget.place.distance != 0)
                  Text(
                    widget.place.distance < 1
                        ? '${(widget.place.distance * 1000).toStringAsFixed(0)} متر'
                        : '${widget.place.distance.toStringAsFixed(1)} کیلومتر',
                    style: TextStyle(
                      fontFamily: "YekanBakh",
                      color: CupertinoColors.black,
                      fontSize: 14,
                    ),
                  ),
                if (widget.place.distance != 0) const Gap(12),
                Text(
                  'آدرس',
                  style: TextStyle(
                    fontFamily: "YekanBakh",
                    color: CupertinoColors.inactiveGray,
                    fontSize: 10,
                  ),
                ),
                Text(
                  widget.place.address,
                  style: TextStyle(
                    fontFamily: "YekanBakh",
                    color: CupertinoColors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
              clipBehavior: Clip.none,
              physics: NeverScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 44,
                  child: CupertinoButton.filled(
                    sizeStyle: CupertinoButtonSize.medium,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () {
                      // open maps
                      vibrate();
                      Services.place.navigation(place: widget.place);
                      Services.firebase.event(
                        type: FIREBASE_EVENT_TYPE.NAVIGATION,
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.location,
                        ),
                        const Gap(8),
                        Text(
                          'مسیریابی',
                          style: TextStyle(
                            fontFamily: "YekanBakh",
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CupertinoButton.filled(
                  sizeStyle: CupertinoButtonSize.medium,
                  borderRadius: BorderRadius.circular(8),
                  color: CupertinoColors.activeOrange,
                  onPressed: () {
                    vibrate();
                    Services.place.share(place: widget.place);
                    Services.firebase.event(
                      type: FIREBASE_EVENT_TYPE.SHARE_PLACE,
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.share,
                      ),
                      const Gap(8),
                      Text(
                        'اشتراک',
                        style: TextStyle(
                          fontFamily: "YekanBakh",
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton.filled(
                  sizeStyle: CupertinoButtonSize.medium,
                  borderRadius: BorderRadius.circular(8),
                  color: CupertinoColors.activeGreen,
                  onPressed: () {
                    vibrate();
                    Services.place.toggle(place: widget.place);
                    Services.firebase.event(
                      type: saved
                          ? FIREBASE_EVENT_TYPE.UNSAVE
                          : FIREBASE_EVENT_TYPE.SAVE,
                    );
                    saved = !saved;
                    setState(() {});
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        saved
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                      ),
                      const Gap(8),
                      Text(
                        'ذخیره',
                        style: TextStyle(
                          fontFamily: "YekanBakh",
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gap(
            Get.mediaQuery.padding.bottom + 16,
          ),
        ],
      ),
    );
  }
}
