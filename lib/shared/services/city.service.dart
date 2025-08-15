import 'package:get/get.dart';
import 'package:towaleti/models/city.model.dart';
import 'package:towaleti/shared/database/cities.database.dart';
import 'package:towaleti/shared/services.dart';

class CityService extends GetxService {
  Future<void> select(CityModel city) async {
    var values = await Services.configs.get(key: 'city_latest');

    if (values == null) {
      values = [];
    }

    // check city exists to values, remove and insert to top
    if (values.contains(city.name)) {
      values.remove(city.name);
    }

    values.insert(0, city.name);

    if (values.length > 5) {
      values = values.getRange(0, 4).toList();
    }

    Services.configs.set(key: 'city_latest', value: values);
    Services.configs.set(
      key: 'location',
      value: city.toJson(),
    );
  }

  Future<List<CityModel>> latest() async {
    try {
      var values = await Services.configs.get(key: 'city_latest');

      if (values == null) {
        values = [];
      }

      List<CityModel> cities = [];

      for (var name in values) {
        var city = cities_database.firstWhere((item) => item.name == name);

        cities.add(
          CityModel(
            name: name,
            lat: city.lat,
            lon: city.lon,
            zoom: city.zoom,
          ),
        );
      }

      return cities;
    } catch (e) {
      return [];
    }
  }
}
