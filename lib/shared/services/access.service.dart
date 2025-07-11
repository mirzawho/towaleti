import 'package:package_info_plus/package_info_plus.dart';

class AccessService {
  Future<PackageInfo> generatePackageInfo() {
    return PackageInfo.fromPlatform();
  }
}
