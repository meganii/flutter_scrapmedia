import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:apaa/apaa.dart';
import 'package:flutter_opendb/flutter_opendb.dart';
import './model/ScrapMediaItem.dart';
import './model/BitlyItem.dart';

enum ScrapmediaServices { openDBAPI, awsAPI }
ScrapmediaServices _service = ScrapmediaServices.openDBAPI;

enum ScrapmediaProperty {
  accessKey,
  secretKey,
  associateTag,
  projectName,
  useService,
  bitlyApiKey
}

final awsAccessKeyIdController = TextEditingController();
final awsSecretAccessKeyController = TextEditingController();
final awsAssociateTagController = TextEditingController();
final scrapboxProjectNameController = TextEditingController();
final bitlyApiKeyController = TextEditingController();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrap Media',
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Scrap Media'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = '書籍のバーコードを読み取ってね';
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
    switch (_service) {
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
        var api = APAA(awsAccessKeyIdController.text,
            awsSecretAccessKeyController.text, awsAssociateTagController.text);
        var result = await api.search(isbn);
        var shotenUrl = await _shortUrl(bitlyApiKeyController.text, result.productUrl);
        if (result != null) {
          item = ScrapMediaItem(
              title: result.title,
              cover: result.image.url,
              author: result.author,
              publisher: result.publisher,
              asin: result.asin,
              affiliateUrl: shotenUrl);
          isVisible = true;
        }
        break;
    }
    return item;
  }

  _tweet(ScrapMediaItem item) async {
    Share.share('${item.title} ${item.affiliateUrl}');
  }

  _shortUrl(String apiKey, String longUrl) async {
    String baseUrl =
        'https://api-ssl.bitly.com/v3/shorten?access_token=$apiKey&longUrl=';
    var encodeUrl = Uri.encodeComponent(longUrl);
    final response = await http.get(baseUrl + encodeUrl);
    String shotenUrl;
    if (response.statusCode == 200) {
      var bitly = BitlyItem.fromJson(json.decode(response.body));
      shotenUrl = bitly.url;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
    return shotenUrl;
  }

  Future<void> _openScrapbox(ScrapMediaItem item) async {
    String sbUrl = 'https://scrapbox.io/${scrapboxProjectNameController.text}/';
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

  void _readAll() async {
    final storage = new FlutterSecureStorage();
    var value = await storage.readAll();
    setState(() {
      awsAccessKeyIdController.text = value[ScrapmediaProperty.accessKey.toString()];
      awsSecretAccessKeyController.text =
      value[ScrapmediaProperty.secretKey.toString()];
      awsAssociateTagController.text =
      value[ScrapmediaProperty.associateTag.toString()];
      scrapboxProjectNameController.text =
      value[ScrapmediaProperty.projectName.toString()];
      if (value[ScrapmediaProperty.useService.toString()] ==
          ScrapmediaServices.awsAPI.toString()) {
        _service = ScrapmediaServices.awsAPI;
      }
      bitlyApiKeyController.text = value[ScrapmediaProperty.bitlyApiKey.toString()];
    });
  }

  @override
  void initState() {
    super.initState();
    _readAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scrap Media"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More vertical',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
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
                  if (isVisible) Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    child: FlatButton(
                      child: Text('Tweet'),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () => {_tweet(_item)},
                    ),
                  ),
                  if (isVisible) Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    child: FlatButton(
                      child: Text('Scrapbox'),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: () => {_openScrapbox(_item)},
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

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = new GlobalKey<FormState>();

  void _read(ScrapmediaProperty key) async {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: key.toString());
    setState(() {
      switch (key) {
        case ScrapmediaProperty.accessKey:
          awsAccessKeyIdController.text = value;
          break;
        case ScrapmediaProperty.secretKey:
          awsSecretAccessKeyController.text = value;
          break;
        case ScrapmediaProperty.associateTag:
          awsAssociateTagController.text = value;
          break;
        case ScrapmediaProperty.projectName:
          scrapboxProjectNameController.text = value;
          break;
        case ScrapmediaProperty.useService:
          break;
        case ScrapmediaProperty.bitlyApiKey:
          bitlyApiKeyController.text = value;
          break;
      }
    });
  }

  void _save(ScrapmediaProperty key, String value) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: key.toString(), value: value);
    print(key.toString() + value);
  }

  void _saveAll() async {
    final storage = new FlutterSecureStorage();

    await storage.write(
        key: ScrapmediaProperty.projectName.toString(),
        value: scrapboxProjectNameController.text);
    await storage.write(
        key: ScrapmediaProperty.accessKey.toString(),
        value: awsAccessKeyIdController.text);
    await storage.write(
        key: ScrapmediaProperty.secretKey.toString(),
        value: awsSecretAccessKeyController.text);
    await storage.write(
        key: ScrapmediaProperty.associateTag.toString(),
        value: awsAssociateTagController.text);
    await storage.write(
        key: ScrapmediaProperty.useService.toString(), value: _service.toString());
    await storage.write(
        key: ScrapmediaProperty.bitlyApiKey.toString(),
        value: bitlyApiKeyController.text);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    awsAccessKeyIdController.dispose();
    awsSecretAccessKeyController.dispose();
    awsAssociateTagController.dispose();
    scrapboxProjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
          ],
        ));
  }

  Widget _showBody() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showScrapboxInput(),
              _showRadioButton(),
              _showEmailInput(),
              _showPasswordInput(),
              _showTagInput(),
              _showBitlyInput(),
              _showSaveButton(),
            ],
          ),
        ));
  }

  Widget _showScrapboxInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        controller: scrapboxProjectNameController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Scrapbox Project name',
            icon: Icon(
              Icons.vpn_key,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget _showRadioButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: Column(
          children: <Widget>[
            Text(
              'Which API do you use',
              textAlign: TextAlign.left,
            ),
            RadioListTile<ScrapmediaServices>(
              title: const Text('openDB API'),
              value: ScrapmediaServices.openDBAPI,
              groupValue: _service,
              onChanged: (ScrapmediaServices value) {
                setState(() {
                  _service = value;
                });
              },
            ),
            RadioListTile<ScrapmediaServices>(
              title: const Text('Amazon Product Advertising API'),
              value: ScrapmediaServices.awsAPI,
              groupValue: _service,
              onChanged: (ScrapmediaServices value) {
                setState(() {
                  _service = value;
                });
              },
            ),
          ],
        ));
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        controller: awsAccessKeyIdController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'AWS ID',
            icon: Icon(
              Icons.vpn_key,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: awsSecretAccessKeyController,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'AWS Secret KEY',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
      ),
    );
  }

  Widget _showTagInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: awsAssociateTagController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Tag ID',
            icon: new Icon(
              Icons.perm_identity,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget _showBitlyInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: new TextFormField(
          controller: bitlyApiKeyController,
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: new InputDecoration(
              hintText: 'Bitly API KEY',
              icon: new Icon(
                Icons.lock,
                color: Colors.grey,
              )),
          validator: (value) =>
          value.isEmpty ? 'Password can\'t be empty' : null,
        ));
  }

  Widget _showSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: RaisedButton(
        child: Text('Submit'),
        onPressed: () {
          _saveAll();
        },
      ),
    );
  }
}
