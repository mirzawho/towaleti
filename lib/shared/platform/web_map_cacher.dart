import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

Future<CacheStore> getCacheStore() async {
  return MemCacheStore();
}
