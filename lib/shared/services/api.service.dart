import 'package:get/get.dart';
import 'package:towaleti/shared/services.dart';

class APIService extends GetxService {
  Future<dynamic> handshake() {
    try {
      return Services.http.call(action: 'app.handshake');
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> find({
    required double lat,
    required double lon,
    required int zoom,
    double? gps_lat = 0,
    double? gps_lon = 0,
  }) {
    try {
      return Services.http.call(
        action: 'place.find',
        data: {
          'lat': lat,
          'lon': lon,
          'gps_lat': gps_lat,
          'gps_lon': gps_lon,
          'zoom': zoom,
          'category': 'public-bathroom'
        },
      );
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> reverse({
    required String address,
    String? city,
  }) async {
    try {
      return Services.http.call(
        action: 'place.search',
        data: {
          'address': address,
          'city': city,
        },
      );
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> ad({
    String type = "any",
    String? city,
  }) async {
    try {
      return Services.http.call(
        action: 'ad.one',
        data: {
          'type': type,
          'city': city,
        },
      );
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }
}
