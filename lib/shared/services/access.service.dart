import 'package:towaleti/shared/constants.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AccessService extends GetxService {
  Future<PackageInfo> generatePackageInfo() {
    return PackageInfo.fromPlatform();
  }

  Future<dynamic> generate() async {
    var package = await generatePackageInfo();

    if (GetPlatform.isAndroid) {
      var data = {
        'flavor': CONSTANTS.flavor.toLowerCase(),
        'platform': 'android',
        'package_name': package.packageName,
        'package_version': package.version,
        'package_code': package.buildNumber,
        'device_os': 'android',
      };

      return data;
    } else if (GetPlatform.isWeb) {
      var data = {
        'flavor': CONSTANTS.flavor.toLowerCase(),
        'platform': 'web',
        'package_name': package.packageName,
        'package_version': package.version,
        'package_code': package.buildNumber,
      };

      return data;
    }

    return {};
  }
}
