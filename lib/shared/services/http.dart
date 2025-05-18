import 'package:dio/dio.dart';

class HttpService {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  );

  Future<dynamic> search({
    required double lat,
    required double lon,
    required int zoom,
  }) async {
    final response = await dio.get(
      'https://towaleti.sayheymirza.workers.dev/search',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'zoom': zoom,
      },
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
