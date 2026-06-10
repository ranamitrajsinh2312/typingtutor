import "dart:io";

// import "package:typingtutor/import_export.dart";

// Implementation for native platforms (Android, iOS)
String getDashboardBannerAdId() {
  return Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/6300978111';
}

String getLevel1BannerAdId() {
  return Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/6300978111';
}

String getAppOpenAdUnitId() {
  return Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-3940256099942544/5575463023';
}
