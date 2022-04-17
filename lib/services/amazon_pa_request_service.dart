import 'package:flutter_amazon_pa_api/flutter_amazon_pa_api.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';
import 'package:flutter_scrapmedia/services/abstract_request_service.dart';
import 'package:flutter_scrapmedia/services/service.dart';

class AmazonPARequestService extends AbstractRequestService {
  String amazonAPIKey;
  String amazonSecret;
  String amazonTagName;
  String bitlyKey;

  AmazonPARequestService(
      {required this.amazonAPIKey,
      required this.amazonSecret,
      required this.amazonTagName,
      required this.bitlyKey});

  @override
  Future<ScrapMediaItem> fetchItem(String isbn) async {
    final asin = convertToASIN(isbn);

    final api = PaAPI(accessKey: amazonAPIKey, secretKey: amazonSecret)
      ..partnerTag = amazonTagName;
    final response = await api.getItems([asin]);

    final items = response.itemsResult!.items;
    if (items != null && items.isEmpty) {
      return ScrapMediaItem();
    }

    final item = items?[0];
    if (item == null) {
      return ScrapMediaItem();
    }

    final affiliateUrl = await shortUrl(bitlyKey, item.detailPageURL ?? '');

    return ScrapMediaItem(
        title: item.itemInfo?.title?.displayValue,
        cover: item.images?.primary?.large?.url,
        author: item.itemInfo?.byLineInfo?.contributors?[0].name,
        publisher: item.itemInfo?.byLineInfo?.manufacturer?.displayValue,
        asin: item.asin,
        affiliateUrl: affiliateUrl);
  }
}
