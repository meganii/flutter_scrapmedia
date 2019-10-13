import 'dart:async';
import 'dart:convert';

import 'package:flutter_scrapmedia/model/bitly_item.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

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
