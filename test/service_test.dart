import 'dart:io';
import 'package:flutter_amazon_pa_api/flutter_amazon_pa_api.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_appconfig.dart';
import 'package:flutter_scrapmedia/services/service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  HttpOverrides.global = _MyHttpOverrides();

  test('test', () async {
    final awsAccessKey = Platform.environment['AWS_ACCESS_KEY_ID'] ?? '';
    final awsSecretKey = Platform.environment['AWS_SECRET_ACCESS_KEY'] ?? '';
    final awsAssociateTag = Platform.environment['AWS_ASSOCIATE_TAG'] ?? '';
    final paapi = PaAPI(accessKey: awsAccessKey, secretKey: awsSecretKey)
      ..partnerTag = awsAssociateTag;

    final response = await paapi.getItems(['4479302735']);
    // print(response.itemsResult);
    final item = response.itemsResult?.items?[0];
    expect(item?.asin, '4479302735');
    expect(item?.detailPageURL,
        'https://www.amazon.co.jp/dp/4479302735?tag=meganii-22&linkCode=ogi&th=1&psc=1');
    expect(item?.images?.primary?.medium?.height, 160);
  });

  test('fetchItem', () async {
    var appConfig = new ScrapMediaAppConfig();
    appConfig.amazonAPIKey = Platform.environment['AWS_ACCESS_KEY_ID'];
    appConfig.amazonSecret = Platform.environment['AWS_SECRET_ACCESS_KEY'];
    appConfig.amazonTagName = Platform.environment['AWS_ASSOCIATE_TAG'];
    appConfig.bitlyKey = Platform.environment['BITLY_KEY'];
    appConfig.appSearchMethod = "ScrapmediaServices.awsAPI";
    var item = await fetchItem('9784479302735', appConfig);
    expect(item.asin, '4479302735');
    expect(item.affiliateUrl, 'https://amzn.to/3mHMUqH');
    expect(item.title, '「1日30分」を続けなさい! (だいわ文庫)');
  });

  test('shortenURL', () async {
    final apiKey = Platform.environment['BITLY_KEY'];
    final shortenURL = await shortUrl(apiKey ?? '', 'https://www.meganii.com');
    expect(shortenURL, 'https://bit.ly/3aiuvJB');
  });

  test('convert to ASIN', () {
    final asin = convertToASIN('9784065151563');
    expect(asin, '4065151562');
  });

  test('convert to ASIN 4478111030', () {
    final asin = convertToASIN('9784478111031');
    expect(asin, '4478111030');
  });

  test('convert to ASIN 9784910063041', () {
    final asin = convertToASIN('9784910063041');
    expect(asin, '4910063048');
  });

  test('convert to ASIN 9784910063041', () {
    final asin = convertToASIN('9784798158167');
    expect(asin, '479815816X');
  });

  test('conver to ASIN 9784479302735', () {
    final asin = convertToASIN('9784479302735');
    expect(asin, '4479302735');
  });

  test('conver to ASIN 9784040824130', () {
    final asin = convertToASIN('9784040824130');
    expect(asin, '404082413X');
  });
}

class _MyHttpOverrides extends HttpOverrides {}
