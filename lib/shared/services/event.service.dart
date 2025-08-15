import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:towaleti/models/event.model.dart';
import 'package:towaleti/shared/event.dart' as instance;

class EventService extends GetxService {
  void fire({required String event, dynamic value}) {
    log('[event.service.dart] fire event $event');

    instance.event.fire(
      EventModel(
        event: event,
        value: value,
      ),
    );
  }

  StreamSubscription<dynamic> listen(
    void Function(dynamic)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return instance.event.on().listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }
}
