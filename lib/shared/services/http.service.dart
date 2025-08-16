import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart' as Dio;
import 'package:get/get.dart';
import 'package:towaleti/shared/constants.dart';

class HttpService extends GetxService {
  final Dio.Dio _dio = Dio.Dio(
    Dio.BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      responseType: Dio.ResponseType.json,
    ),
  );
  int index = 0;

  Future<dynamic> call({
    required String action,
    Map<String, dynamic>? data,
  }) {
    return request(
      path: '/v1/call/$action',
      method: 'POST',
      data: data,
    );
  }

  Future<dynamic> request({
    required String path,
    String? endpoint = "https://mapine.doting.ir",
    String method = "GET",
    Map<String, dynamic>? data,
    Dio.CancelToken? cancelToken,
  }) async {
    var url = "$endpoint$path";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-time': DateTime.now().toIso8601String(),
      'x-app': CONSTANTS.id,
      'x-flavor': CONSTANTS.flavor,
      'x-version': CONSTANTS.version,
    };

    var i = ++index;

    var start = DateTime.now();

    log('[http.service.dart#$i] $method $url');

    var response = await _dio.request(
      url,
      data: data,
      cancelToken: cancelToken,
      options: Dio.Options(
        method: method,
        headers: headers,
      ),
    );

    var end = DateTime.now();

    log('[http.service.dart#$i] $method $path (${end.difference(start).inMilliseconds}ms)');

    return response.data;
  }
}
