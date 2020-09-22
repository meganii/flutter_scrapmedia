import 'dart:io' show Platform;

import 'package:flutter_amazon_pa_api/flutter_amazon_pa_api.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_appconfig.dart';
import 'package:flutter_scrapmedia/services/service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test', () async {
    final env = Platform.environment;
    final awsAccessKey = env['AWS_ACCESS_KEY_ID'];
    final awsSecretKey = env['AWS_SECRET_ACCESS_KEY'];
    final awsAssociateTag = env['AWS_ASSOCIATE_TAG'];
    final paapi = PaAPI(awsAccessKey, awsSecretKey)
      ..partnerTag = awsAssociateTag;

    final response = await paapi.getItems(['4479302735']);
    print(response.itemsResult);
    final item = response.itemsResult.items[0];
    expect(item.asin, '4479302735');
    expect(item.detailPageURL,
        'https://www.amazon.co.jp/dp/4479302735?tag=meganii-22&linkCode=ogi&th=1&psc=1');
    expect(item.images.primary.medium.height, 160);
  });

  test('fetchItem', () async {
    final env = Platform.environment;
    var appConfig = new ScrapMediaAppConfig();
    appConfig.amazonAPIKey = env['AWS_ACCESS_KEY_ID'];
    appConfig.amazonSecret = env['AWS_SECRET_ACCESS_KEY'];
    appConfig.amazonTagName = env['AWS_ASSOCIATE_TAG'];
    appConfig.appSearchMethod = "ScrapmediaServices.awsAPI";
    var item = fetchItem('4479302735', appConfig);
    print(item);
  });

  test('shortenURL', () async {
    final env = Platform.environment;
    final apiKey = env['BITLY_KEY'];
    final shortenURL = await shortUrl(apiKey, 'https://www.meganii.com');
    print(shortenURL);
  });

  test('convert to ASIN', () {
    final asin = convertToASIN('9784065151563');
    expect(asin, '4065151562');
  });

  test('convert to ASIN 4478111030', () {
    final asin = convertToASIN('9784478111031');
    expect(asin, '4478111030');
  });
}
