import 'package:get/get.dart';
import 'package:towaleti/views/home/home.view.dart';
import 'package:towaleti/views/offline/offline.view.dart';
import 'package:towaleti/views/page/page.view.dart';
import 'package:towaleti/views/splash/splash.view.dart';

List<GetPage> pages = [
  GetPage(
    name: '/',
    page: () => SplashView(),
  ),
  GetPage(
    name: '/offline',
    page: () => OfflineView(),
  ),
  GetPage(
    name: '/about',
    page: () => DynamicPageView(slug: 'about'),
  ),
  GetPage(
    name: '/terms',
    page: () => DynamicPageView(slug: 'terms'),
  ),
  GetPage(
    name: '/privacy',
    page: () => DynamicPageView(slug: 'privacy'),
  ),
  GetPage(
    name: '/ad',
    page: () => DynamicPageView(slug: 'ad'),
  ),
  GetPage(
    name: '/home',
    page: () => HomeView(),
  ),
];
