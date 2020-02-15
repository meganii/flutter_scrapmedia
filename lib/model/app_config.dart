import 'package:flutter/widgets.dart';
import 'package:flutter_scrapmedia/model/config_key.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfigModel extends ChangeNotifier {
  final Map<String, String> _appConfig = Map<String, String>();

  Map<String, String> get values => _appConfig;

  AppConfigModel() {
    load();
  }

  void load() async {
    final storage = new FlutterSecureStorage();
    var value = await storage.readAll();
    _appConfig.addAll(value);

    // Default search method
    if (_appConfig[ConfigKey.appSearchMethod] == null) {
      _appConfig[ConfigKey.appSearchMethod.toString()] =
          ScrapmediaServices.openBDAPI.toString();
    }
  }

  void update(String key, String value) {
    _appConfig[key] = value;
    notifyListeners();
  }
}
