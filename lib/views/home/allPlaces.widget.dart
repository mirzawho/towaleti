import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:towaleti/models/place.model.dart';

class AllPlacesWidget extends StatelessWidget {
  final String title;
  final List<PlaceModel> places;
  final Function({required PlaceModel place})? onPlaceSelect;
  final Widget? suffixWidget;

  const AllPlacesWidget({
    super.key,
    required this.title,
    required this.places,
    this.onPlaceSelect,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: CupertinoColors.inactiveGray,
                fontSize: 12,
                fontFamily: "YekanBakh",
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (suffixWidget != null) suffixWidget!,
          ],
        ),
        const Gap(8),
        Container(
          margin: EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (var item in places) place(item: item),
            ],
          ),
        ),
      ],
    );
  }

  Widget place({required PlaceModel item}) {
    return CupertinoListTile.notched(
      onTap: () {
        onPlaceSelect!(place: item);
      },
      padding: EdgeInsets.only(
        top: 8,
        left: 8,
        right: 12,
        bottom: 8,
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: Get.width - 150,
            ),
            child: Text(
              item.name,
              softWrap: true,
              style: TextStyle(
                color: CupertinoColors.black,
                fontSize: 14,
                fontFamily: "YekanBakh",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Gap(4),
          if (item.distance != 0)
            Text(
              item.distance < 1
                  ? '${(item.distance * 1000).toStringAsFixed(0)} متر'
                  : '${item.distance.toStringAsFixed(1)} کیلومتر',
              style: TextStyle(
                color: CupertinoColors.inactiveGray,
                fontFamily: "YekanBakh",
                fontSize: 10,
              ),
            ),
        ],
      ),
      subtitle: Text(
        item.address,
        style: TextStyle(
          color: CupertinoColors.inactiveGray,
          fontSize: 12,
        ),
      ),
      trailing: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: CupertinoColors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.quaternarySystemFill,
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfffde68a),
              Color(0xfffbbf24),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            CupertinoIcons.map_pin,
            size: 20,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
