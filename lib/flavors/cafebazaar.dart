import 'package:flutter/cupertino.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/services/access.service.dart';

import '../main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AccessService accessService = AccessService();

  var package = await accessService.generatePackageInfo();

  CONSTANTS.version = package.version;
  CONSTANTS.flavor = 'cafebazaar';

  runApp(const MainApp());
}
