import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:towaleti/models/event.model.dart';
import 'package:towaleti/pages.dart';
import 'package:towaleti/shared/services.dart';
import 'package:towaleti/shared/theme.dart';
import 'package:towaleti/views/offline/offline.view.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isOffline = false;

  @override
  void initState() {
    super.initState();

    Services.connectivity.listen();

    Services.event.listen((data) {
      if (data.event == EVENTS.OFFLINE && isOffline == false) {
        isOffline = true;
        Get.dialog(
          OfflineView(),
          useSafeArea: false,
        );
      }

      if (data.event == EVENTS.ONLINE && isOffline == true) {
        isOffline = false;
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      getPages: pages,
      locale: Locale('fa'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("fa"),
      ],
    );
  }
}
