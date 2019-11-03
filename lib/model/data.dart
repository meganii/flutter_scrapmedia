import 'package:flutter/widgets.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';

class AppDataModel extends ChangeNotifier {
  
  String _message;
  ScrapMediaItem _smItem;
  String _imageURL;
  bool _visibleShareButtons = false;

  ScrapMediaItem get item => _smItem;
  String get message => _message;
  String get imageURL => _imageURL;
  bool get visibleShareButtons => _visibleShareButtons;

  AppDataModel() {
    _smItem = ScrapMediaItem();
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
