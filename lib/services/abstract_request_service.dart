import 'dart:async';

import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';

abstract class AbstractRequestService {

  Future<ScrapMediaItem> fetchItem(String isbn);
  
}
