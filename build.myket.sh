versionName=2.3.0
versionCode=230

# flutter build apk  --target-platform="android-arm" --target lib/flavors/myket.dart  --split-per-abi --build-name=$versionName --build-number=1$versionCode --release
# flutter build apk  --target-platform="android-arm64" --target lib/flavors/myket.dart  --split-per-abi --build-name=$versionName --build-number=2$versionCode --release
flutter build apk  --target-platform="android-x64" --target lib/flavors/myket.dart  --split-per-abi --build-name=$versionName --build-number=4$versionCode --release
