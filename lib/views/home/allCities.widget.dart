import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/shared/database/cities.database.dart';

class AllCitiesWidget extends StatefulWidget {
  final Function({required CityModel city})? onCitySelect;

  const AllCitiesWidget({
    super.key,
    this.onCitySelect,
  });

  @override
  State<AllCitiesWidget> createState() => _AllCitiesWidgetState();
}

class _AllCitiesWidgetState extends State<AllCitiesWidget> {
  List<CityModel> citiesSorted = [];

  @override
  void initState() {
    super.initState();

    citiesSorted = [...cities_database];
    citiesSorted.sort((a, b) => a.name.compareTo(b.name));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'همه شهر ها',
          style: TextStyle(
            color: CupertinoColors.inactiveGray,
            fontSize: 12,
            fontFamily: "YekanBakh",
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        Container(
          height: 110,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var item in citiesSorted) city(value: item),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget city({
    required CityModel value,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onCitySelect!(city: value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: CupertinoColors.activeBlue.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.location_solid,
                  size: 20,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
            const Gap(8),
            Text(
              value.name,
              style: TextStyle(
                color: CupertinoColors.black,
                fontSize: 12,
                fontFamily: "YekanBakh",
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
