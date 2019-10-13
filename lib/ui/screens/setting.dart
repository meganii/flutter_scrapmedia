import 'package:flutter/material.dart';
import 'package:flutter_scrapmedia/model/state.dart';
import 'package:flutter_scrapmedia/state_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_property.dart';

enum ScrapmediaServices { openDBAPI, awsAPI }

ScrapmediaServices _service = ScrapmediaServices.openDBAPI;

class SettingScreen extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingScreen> {
  StateModel appState;

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
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

  final _formKey = new GlobalKey<FormState>();

  void _saveAll() async {
    final storage = new FlutterSecureStorage();

    await storage.write(
        key: ScrapmediaProperty.projectName.toString(),
        value: appState.scrapboxProjectNameController.text);
    await storage.write(
        key: ScrapmediaProperty.accessKey.toString(),
        value: appState.awsAccessKeyIdController.text);
    await storage.write(
        key: ScrapmediaProperty.secretKey.toString(),
        value: appState.awsSecretAccessKeyController.text);
    await storage.write(
        key: ScrapmediaProperty.associateTag.toString(),
        value: appState.awsAssociateTagController.text);
    await storage.write(
        key: ScrapmediaProperty.useService.toString(),
        value: _service.toString());
    await storage.write(
        key: ScrapmediaProperty.bitlyApiKey.toString(),
        value: appState.bitlyApiKeyController.text);
  }

//  @override
//  void dispose() {
//    // Clean up the controller when the widget is disposed.
//    appState.awsAccessKeyIdController.dispose();
//    appState.awsAccessKeyIdController.dispose();
//    appState.awsSecretAccessKeyController.dispose();
//    appState.awsAssociateTagController.dispose();
//    appState.scrapboxProjectNameController.dispose();
//    appState.bitlyApiKeyController.dispose();
//    super.dispose();
//  }

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
        controller: appState.scrapboxProjectNameController,
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
        controller: appState.awsAccessKeyIdController,
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
        controller: appState.awsSecretAccessKeyController,
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
        controller: appState.awsAssociateTagController,
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
          controller: appState.bitlyApiKeyController,
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
