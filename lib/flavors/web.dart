import 'package:towaleti/run.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CONSTANTS.flavor = 'web';

  run();
}
