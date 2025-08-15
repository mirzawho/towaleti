import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:towaleti/models/event.model.dart';
import 'package:towaleti/shared/services.dart';

class ConnectivityService extends GetxService {
  RxBool connected = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<bool> check() async {
    return _connectedFromResult(await Connectivity().checkConnectivity());
  }

  Future<void> listen() async {
    // first time handling
    await check();

    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _connectedFromResult(result);
    });
  }

  bool _connectedFromResult(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.mobile)) {
      connected.value = true;
    } else if (result.contains(ConnectivityResult.wifi)) {
      connected.value = true;
    } else if (result.contains(ConnectivityResult.ethernet)) {
      connected.value = true;
    } else {
      connected.value = false;
    }

    Services.event.fire(
      event: connected.value ? EVENTS.ONLINE : EVENTS.OFFLINE,
    );

    return connected.value;
  }
}
