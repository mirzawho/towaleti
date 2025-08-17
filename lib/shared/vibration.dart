import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

Future<void> vibrate({int duration = 80}) {
  if (kIsWeb) return Future.value();

  return Vibration.vibrate(duration: duration);
}
