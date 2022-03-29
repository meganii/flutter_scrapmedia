import 'package:flutter/widgets.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';

class AppStateModel extends ChangeNotifier {
  String? _message;
  ScrapMediaItem? _smItem;
  String? _imageURL;
  bool _visibleShareButtons = false;

  String? get message => _message;

  ScrapMediaItem? get item => _smItem;

  String? get imageURL => _imageURL;

  bool get visibleShareButtons => _visibleShareButtons;

  AppStateModel() {
    _smItem = ScrapMediaItem(publisher: '');
  }

  void updateVisibleShareButtons(bool flag) {
    _visibleShareButtons = flag;
    notifyListeners();
  }

  void updateMessage(String message) {
    _message = message;
    notifyListeners();
  }

  void updateItem(ScrapMediaItem item) {
    _smItem = item;
    notifyListeners();
  }

  void updateImageURL(String imageURL) {
    _imageURL = imageURL;
    notifyListeners();
  }
}
