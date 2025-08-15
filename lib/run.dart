import 'package:towaleti/app.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/services.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

void run() async {
  // shared services
  await Services.put();

  // init get storage
  await GetStorage.init();

  Services.chrome.transparent();

  var package = await Services.access.generatePackageInfo();

  CONSTANTS.version = package.version;

  runApp(const App());
}
