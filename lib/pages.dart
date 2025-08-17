import 'package:get/get.dart';
import 'package:towaleti/views/home/home.view.dart';
import 'package:towaleti/views/info/info.view.dart';
import 'package:towaleti/views/page/page.view.dart';
import 'package:towaleti/views/splash/splash.view.dart';

List<GetPage> pages = [
  GetPage(
    name: '/',
    page: () => SplashView(),
  ),
  GetPage(
    name: '/info',
    page: () => InfoView(),
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
    name: '/home',
    page: () => HomeView(),
  ),
];
