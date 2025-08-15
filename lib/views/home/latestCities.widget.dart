import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:towaleti/models/city.model.dart';

class LatestCitiesWidget extends StatelessWidget {
  final List<CityModel> cities;
  final Function({required CityModel city})? onCitySelect;

  const LatestCitiesWidget({
    super.key,
    required this.cities,
    this.onCitySelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'شهر های اخیر',
            style: TextStyle(
              color: CupertinoColors.inactiveGray,
              fontSize: 12,
              fontFamily: "YekanBakh",
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var item in cities) city(value: item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget city({
    required CityModel value,
  }) {
    return GestureDetector(
      onTap: () {
        onCitySelect!(city: value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: CupertinoColors.activeBlue.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.location_solid,
                  size: 14,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
            const Gap(12),
            Text(
              value.name,
              style: TextStyle(
                color: CupertinoColors.black,
                fontSize: 14,
                fontFamily: "YekanBakh",
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
