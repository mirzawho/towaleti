import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:towaleti/shared/theme.dart';
import 'package:towaleti/views/home/home.view.dart';
import 'package:towaleti/views/offline/offline.view.dart';
import 'package:towaleti/views/page/page.view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // transparent status and navigation bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: CupertinoColors.transparent,
      systemNavigationBarColor: CupertinoColors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    return CupertinoApp(
      theme: themeData,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('fa'), // English
      ],
      locale: const Locale('fa'),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => HomeView(),
        '/offline': (_) => OfflineView(),
        '/about': (_) => const DynamicPageView(slug: 'about'),
        '/terms': (_) => const DynamicPageView(slug: 'terms'),
        '/privacy': (_) => const DynamicPageView(slug: 'privacy'),
        '/ad': (_) => const DynamicPageView(slug: 'ad'),
        '/home': (_) => const HomeView(),
      },
    );
  }
}
