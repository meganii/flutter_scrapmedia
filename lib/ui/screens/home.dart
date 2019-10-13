import 'package:apaa/apaa.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_opendb/flutter_opendb.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';
import 'package:flutter_scrapmedia/model/state.dart';
import 'package:flutter_scrapmedia/services/service.dart';
import 'package:flutter_scrapmedia/state_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  String result = '';
  String imageUrl = '';
  ScrapMediaItem _item;
  bool isVisible = false;

  Future _scanCode() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      var item = await _fetchItem(qrResult);
      setState(() {
        if (item != null) {
          _item = item;
          result = item.title;
          imageUrl = item.cover;
        } else {
          result = '見つかりませんでした';
        }
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  Future<ScrapMediaItem> _fetchItem(String isbn) async {
    ScrapMediaItem item;
    switch (appState.service) {
      case ScrapmediaServices.openDBAPI:
        var opendb = FlutterOpendb();
        var result = await opendb.getISBN(isbn);
        if (result != null) {
          item = ScrapMediaItem(
            title: result.title,
            cover: result.cover,
            author: result.author,
            publisher: result.publisher,
          );
          isVisible = true;
        }
        break;
      case ScrapmediaServices.awsAPI:
        var api = APAA(
            appState.awsAccessKeyIdController.text,
            appState.awsSecretAccessKeyController.text,
            appState.awsAssociateTagController.text);
        var result = await api.search(isbn);
        var url = await shortUrl(
            appState.bitlyApiKeyController.text, result.productUrl);
        if (result != null) {
          item = ScrapMediaItem(
              title: result.title,
              cover: result.image.url,
              author: result.author,
              publisher: result.publisher,
              asin: result.asin,
              affiliateUrl: url);
          isVisible = true;
        }
        break;
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    // Build the content depending on the state:
    appState = StateWidget.of(context).state;
    return _buildContent();
  }

  _buildContent() {
    return Scaffold(
      appBar: AppBar(title: Text("Scrap Media"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More vertical',
          onPressed: () {
            Navigator.pushNamed(context, '/setting');
          },
        )
      ]),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                result,
                style: TextStyle(fontSize: 40.0),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Image.network(imageUrl),
              ),
              Row(
                children: <Widget>[
                  if (true)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      child: FlatButton(
                        child: Text('Tweet'),
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: () => {tweet(_item)},
                      ),
                    ),
                  if (true)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      child: FlatButton(
                        child: Text('Scrapbox'),
                        textColor: Colors.white,
                        color: Colors.green,
                        onPressed: () => {openScrapbox(_item, appState.scrapboxProjectNameController.text)},
                      ),
                    ),
                ],
              ),
              Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 100.0))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text('Scan'),
        backgroundColor: Colors.green,
        onPressed: _scanCode,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
