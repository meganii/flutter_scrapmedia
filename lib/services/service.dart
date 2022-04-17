import 'dart:async';
import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scrapmedia/model/app_config.dart';
import 'package:flutter_scrapmedia/model/app_state.dart';
import 'package:flutter_scrapmedia/model/bitly_item.dart';
import 'package:flutter_scrapmedia/model/config_key.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_appconfig.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';
import 'package:flutter_scrapmedia/services/abstract_request_service.dart';
import 'package:flutter_scrapmedia/services/amazon_pa_request_service.dart';
import 'package:flutter_scrapmedia/services/openbd_request_service.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

Future scanCode(AppConfigModel appConfig, AppStateModel appState) async {
  try {
    var qrResult = await BarcodeScanner.scan();
    final scrapMediaAppConfig = createScrapMediaAppConfigFrom(appConfig);
    var item = await fetchItem(qrResult.rawContent, scrapMediaAppConfig);
    if (item.title != null) {
      appState.updateItem(item);
      appState.updateVisibleShareButtons(true);
    } else {
      appState.updateMessage('見つかりませんでした');
    }
  } on PlatformException catch (ex) {
    if (ex.code == BarcodeScanner.cameraAccessDenied) {
      appState.updateMessage('Camera permission was denied');
    } else {
      appState.updateMessage("Unknown Error $ex");
    }
  } on FormatException {
    appState
        .updateMessage('You pressed the back button before scanning anything');
  } catch (ex) {
    appState.updateMessage("Unknown Error $ex");
  }
}

ScrapMediaAppConfig createScrapMediaAppConfigFrom(
    AppConfigModel appConfigModel) {
  var appConfig = ScrapMediaAppConfig();
  appConfig.amazonAPIKey =
      appConfigModel.values[ConfigKey.amazonKey.toString()];
  appConfig.amazonSecret =
      appConfigModel.values[ConfigKey.amazonSecret.toString()];
  appConfig.amazonTagName =
      appConfigModel.values[ConfigKey.amazonTagName.toString()];
  appConfig.appSearchMethod =
      appConfigModel.values[ConfigKey.appSearchMethod.toString()];
  appConfig.bitlyKey = appConfigModel.values[ConfigKey.bitlyKey.toString()];
  return appConfig;
}

Future<void> tweet(ScrapMediaItem item) async {
  String content;
  if (item.affiliateUrl != null) {
    content = '${item.title} ${item.affiliateUrl}';
  } else {
    content = '${item.title} ${item.cover}';
  }
  Share.share(content);
}

Future<String?> shortUrl(String apiKey, String longUrl) async {
  const endpoint = 'https://api-ssl.bitly.com/v4';
  final url = Uri.parse('$endpoint/shorten');
  final headers = {
    'content-type': 'application/json',
    'Authorization': 'Bearer $apiKey'
  };
  final body = {'long_url': longUrl};
  final response =
      await http.post(url, headers: headers, body: json.encode(body));
  String? shortenUrl;
  if (response.statusCode == 200 || response.statusCode == 201) {
    var bitly = BitlyItem.fromJson(json.decode(response.body));
    shortenUrl = bitly.url;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
  return shortenUrl;
}

Future<void> openScrapbox(ScrapMediaItem item, String projectName) async {
  String sbUrl = 'https://scrapbox.io/$projectName/';
  await launch(sbUrl +
      Uri.encodeComponent(item.title ?? 'title') +
      '?body=' +
      Uri.encodeComponent(_createBody(item)));
}

String _createBody(ScrapMediaItem item) {
  String body = '[${item.cover}]\n\n'
      '=====\n'
      '著者: ${item.author} \n'
      '出版社: ${item.publisher}\n';
  if (item.asin != null) {
    body += 'ASIN: ${item.asin}\n';
  }
  body += '#本';
  return body;
}

String convertToASIN(String isbn) {
  var digit = 11 -
      (int.parse(isbn[3]) * 10 +
              int.parse(isbn[4]) * 9 +
              int.parse(isbn[5]) * 8 +
              int.parse(isbn[6]) * 7 +
              int.parse(isbn[7]) * 6 +
              int.parse(isbn[8]) * 5 +
              int.parse(isbn[9]) * 4 +
              int.parse(isbn[10]) * 3 +
              int.parse(isbn[11]) * 2) %
          11;
  var digitStr = '';
  if (digit == 11) {
    digitStr = '0';
  } else if (digit == 10) {
    digitStr = 'X';
  } else {
    digitStr = digit.toString();
  }
  var asin = isbn.substring(3, 12) + digitStr;
  return asin;
}

Future<ScrapMediaItem> fetchItem(
    String isbn, ScrapMediaAppConfig appConfig) async {
  final service = _createService(appConfig);
  return service.fetchItem(isbn);
}

AbstractRequestService _createService(ScrapMediaAppConfig appConfig) {
  final serviceName = appConfig.appSearchMethod;
  if (serviceName == 'ScrapmediaServices.awsAPI') {
    return AmazonPARequestService(
        amazonAPIKey: appConfig.amazonAPIKey ?? '',
        amazonSecret: appConfig.amazonSecret ?? '',
        amazonTagName: appConfig.amazonTagName ?? '',
        bitlyKey: appConfig.bitlyKey ?? '');
  } else {
    return OpenBDRequestService();
  }
}
