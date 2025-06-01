import 'package:dio/dio.dart';
import 'package:towaleti/shared/constants.dart';

class HttpService {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  );

  // handshake
  Future<dynamic> handshake() async {
    final response = await dio.get(
      'https://mapine.doting.ir/v1/call/app.handshake',
      options: Options(
        headers: {
          'x-app': CONSTANTS.id,
          'x-flavor': CONSTANTS.flavor,
          'x-version': CONSTANTS.version,
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> search({
    required double lat,
    required double lon,
    required int zoom,
  }) async {
    final response = await dio.get(
      'https://mapine.doting.ir/v1/call/place.find',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'zoom': zoom,
        'category': 'public-bathroom'
      },
      options: Options(
        headers: {
          'x-app': CONSTANTS.id,
          'x-flavor': CONSTANTS.flavor,
          'x-version': CONSTANTS.version,
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> reverse({required String address, String? city}) async {
    final response = await dio.post(
      'https://mapine.doting.ir/v1/call/place.search',
      data: {
        'address': address,
        'city': city,
      },
      options: Options(
        headers: {
          'x-app': CONSTANTS.id,
          'x-flavor': CONSTANTS.flavor,
          'x-version': CONSTANTS.version,
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> ad({
    String type = "any",
    String? city,
  }) async {
    final response = await dio.get(
      'https://mapine.doting.ir/v1/call/ad.one',
      queryParameters: {
        'type': type,
        'city': city,
      },
      options: Options(
        headers: {
          'x-app': CONSTANTS.id,
          'x-flavor': CONSTANTS.flavor,
          'x-version': CONSTANTS.version,
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
