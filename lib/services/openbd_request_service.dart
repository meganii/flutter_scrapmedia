import 'package:flutter_openbd/flutter_openbd.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';
import 'package:flutter_scrapmedia/services/abstract_request_service.dart';

class OpenBDRequestService extends AbstractRequestService {
  @override
  Future<ScrapMediaItem> fetchItem(String isbn) async {
    final api = FlutterOpenBD();
    final result = await api.getISBN(isbn);
    
    if (result == null) {
      return new ScrapMediaItem();
    }

    return ScrapMediaItem(
      title: result.title,
      cover: result.cover,
      author: result.author,
      publisher: result.publisher,
    );
  }
}
