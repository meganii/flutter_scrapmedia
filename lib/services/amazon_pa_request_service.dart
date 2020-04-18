import 'package:flutter_amazon_pa_api/flutter_amazon_pa_api.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';
import 'package:flutter_scrapmedia/services/abstract_request_service.dart';

class AmazonPARequestService extends AbstractRequestService {
  String amazonAPIKey;
  String amazonSecret;
  String amazonTagName;

  AmazonPARequestService(
      this.amazonAPIKey, this.amazonSecret, this.amazonTagName);

  @override
  Future<ScrapMediaItem> fetchItem(String isbn) async {
    final api = PaAPI(amazonAPIKey, amazonSecret)..partnerTag = amazonTagName;
    final response = await api.getItems([isbn]).catchError((e) => print(e));

    if (response.itemsResult?.items?.length == 0) {
      return ScrapMediaItem();
    }

    final item = response.itemsResult.items[0];
    if (item == null) {
      return ScrapMediaItem();
    }

    return ScrapMediaItem(
        title: item.itemInfo.title.displayValue,
        cover: item.images.primary.medium.url,
        author: "",
        publisher: "",
        asin: item.asin,
        affiliateUrl: "");
  }
}
