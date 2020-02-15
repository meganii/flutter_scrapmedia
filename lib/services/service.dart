import 'dart:async';
import 'dart:convert';

import 'package:apaa/apaa.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openbd/flutter_openbd.dart';
import 'package:flutter_scrapmedia/model/app_config.dart';
import 'package:flutter_scrapmedia/model/app_state.dart';
import 'package:flutter_scrapmedia/model/bitly_item.dart';
import 'package:flutter_scrapmedia/model/config_key.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

Future scanCode(AppConfigModel appConfig, AppStateModel appState) async {
  try {
    String qrResult = await BarcodeScanner.scan();
    var item = await fetchItem(qrResult, appConfig);
    if (item != null) {
      appState.updateItem(item);
      appState.updateVisibleShareButtons(true);
    } else {
      appState.updateMessage('見つかりませんでした');
    }
  } on PlatformException catch (ex) {
    if (ex.code == BarcodeScanner.CameraAccessDenied) {
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

Future<void> tweet(ScrapMediaItem item) async {
  var content;
  if (item.affiliateUrl != null) {
    content = '${item.title} ${item.affiliateUrl}';
  } else {
    content = '${item.title} ${item.cover}';
  }
  Share.share(content);
}

Future<String> shortUrl(String apiKey, String longUrl) async {
  String baseUrl =
      'https://api-ssl.bitly.com/v3/shorten?access_token=$apiKey&longUrl=';
  var encodeUrl = Uri.encodeComponent(longUrl);
  final response = await http.get(baseUrl + encodeUrl);
  String shortenUrl;
  if (response.statusCode == 200) {
    var bitly = BitlyItem.fromJson(json.decode(response.body));
    shortenUrl = bitly.url;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
  return shortenUrl;
}

Future<void> openScrapbox(ScrapMediaItem item, String projectName) async {
  print(projectName);
  String sbUrl = 'https://scrapbox.io/$projectName/';
  await launch(sbUrl +
      Uri.encodeComponent(item.title) +
      '?body=' +
      Uri.encodeComponent(_createBody(item)));
}

String _createBody(ScrapMediaItem item) {
  String body = '[${item.cover}]\n\n' +
      '=====\n' +
      '著者: ${item.author} \n' +
      '出版社: ${item.publisher}\n';
  if (item.asin != null) {
    body += 'ASIN: ${item.asin}\n';
  }
  body += '#本';
  return body;
}

Future<ScrapMediaItem> fetchItem(String isbn, AppConfigModel appConfig) async {
  ScrapMediaItem item;
  var method = appConfig.values[ConfigKey.appSearchMethod.toString()];
  switch (method) {
    case "ScrapmediaServices.openBDAPI":
      var openbd = FlutterOpenBD();
      var result = await openbd.getISBN(isbn);
      if (result != null) {
        item = ScrapMediaItem(
          title: result.title,
          cover: result.cover,
          author: result.author,
          publisher: result.publisher,
        );
      }
      break;
    case "ScrapmediaServices.awsAPI":
      var api = APAA(
          appConfig.values[ConfigKey.amazonKey.toString()],
          appConfig.values[ConfigKey.amazonSecret.toString()],
          appConfig.values[ConfigKey.amazonTagName.toString()]);
      var result = await api.search(isbn).catchError((e) => print(e));
      var url = await shortUrl(
          appConfig.values[ConfigKey.bitlyKey.toString()], result.productUrl);
      if (result != null) {
        item = ScrapMediaItem(
            title: result.title,
            cover: result.image.url,
            author: result.author,
            publisher: result.publisher,
            asin: result.asin,
            affiliateUrl: url);
      }
      break;
    default:
      print("default");
      break;
  }
  return item;
}
