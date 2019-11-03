import 'package:flutter/material.dart';
import 'package:flutter_scrapmedia/model/config_key.dart';
import 'package:provider/provider.dart';
import 'package:flutter_scrapmedia/model/appconfig.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum ScrapmediaServices { openDBAPI, awsAPI }

class SettingScreen extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    var appconfig = Provider.of<AppConfigModel>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(appconfig),
          ],
        ));
  }

  final _formKey = new GlobalKey<FormState>();

  void _saveAll(AppConfigModel appconfig) async {
    final storage = new FlutterSecureStorage();
    if (appconfig.values[ConfigKey.scrapboxProjectName.toString()] != null) {
      await storage.write(
        key: ConfigKey.scrapboxProjectName.toString(),
        value: appconfig.values[ConfigKey.scrapboxProjectName.toString()]);
    }
    if (appconfig.values[ConfigKey.amazonKey.toString()] != null) {
      await storage.write(
          key: ConfigKey.amazonKey.toString(),
          value: appconfig.values[ConfigKey.amazonKey.toString()]);
    }
    if (appconfig.values[ConfigKey.amazonSecret.toString()] != null) {
      await storage.write(
          key: ConfigKey.amazonSecret.toString(),
          value: appconfig.values[ConfigKey.amazonSecret.toString()]);
    }
    if (appconfig.values[ConfigKey.amazonTagName.toString()] != null) {
      await storage.write(
          key: ConfigKey.amazonTagName.toString(),
          value: appconfig.values[ConfigKey.amazonTagName.toString()]);
    }
    if (appconfig.values[ConfigKey.appSearchMethod.toString()] != null) {
      await storage.write(
          key: ConfigKey.appSearchMethod.toString(),
          value: appconfig.values[ConfigKey.appSearchMethod.toString()]);
    }
    if (appconfig.values[ConfigKey.bitlyKey.toString()] != null) {
      await storage.write(
          key: ConfigKey.bitlyKey.toString(),
          value: appconfig.values[ConfigKey.bitlyKey.toString()]);
    }
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

  Widget _showBody(AppConfigModel appconfig) {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: this._formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showScrapboxInput(appconfig),
              _showRadioButton(appconfig),
              _showEmailInput(appconfig),
              _showPasswordInput(appconfig),
              _showTagInput(appconfig),
              _showBitlyInput(appconfig),
              _showSaveButton(appconfig),
            ],
          ),
        ));
  }

  Widget _showScrapboxInput(AppConfigModel appconfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        initialValue: appconfig.values[ConfigKey.scrapboxProjectName.toString()],
        onSaved: (text) {
          appconfig.update(ConfigKey.scrapboxProjectName.toString(), text);
        },
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

  Widget _showRadioButton(AppConfigModel appconfig) {
    var searchMethod = appconfig.values[ConfigKey.appSearchMethod.toString()];

    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: Column(
          children: <Widget>[
            Text(
              'Which API do you use',
              textAlign: TextAlign.left,
            ),
            RadioListTile<String>(
              title: const Text('openDB API'),
              value: ScrapmediaServices.openDBAPI.toString(),
              groupValue: searchMethod,
              onChanged: (String value) {
                appconfig.update(
                    ConfigKey.appSearchMethod.toString(), value.toString());
              },
            ),
            RadioListTile<String>(
              title: const Text('Amazon Product Advertising API'),
              value: ScrapmediaServices.awsAPI.toString(),
              groupValue: searchMethod,
              onChanged: (String value) {
                appconfig.update(
                    ConfigKey.appSearchMethod.toString(), value.toString());
              },
            ),
          ],
        ));
  }

  Widget _showEmailInput(AppConfigModel appconfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        initialValue: appconfig.values[ConfigKey.amazonKey.toString()],
        onSaved: (text) {
          appconfig.update(ConfigKey.amazonKey.toString(), text);
        },
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

  Widget _showPasswordInput(AppConfigModel appconfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        initialValue: appconfig.values[ConfigKey.amazonSecret.toString()],
        onSaved: (text) {
          appconfig.update(ConfigKey.amazonSecret.toString(), text);
        },
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

  Widget _showTagInput(AppConfigModel appconfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        initialValue: appconfig.values[ConfigKey.amazonTagName.toString()],
        onSaved: (text) {
          appconfig.update(ConfigKey.amazonTagName.toString(), text);
        },
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

  Widget _showBitlyInput(AppConfigModel appconfig) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: new TextFormField(
          initialValue: appconfig.values[ConfigKey.bitlyKey.toString()],
          onSaved: (text) {
            appconfig.update(ConfigKey.bitlyKey.toString(), text);
          },
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

  Widget _showSaveButton(AppConfigModel appconfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: RaisedButton(
        child: Text('Submit'),
        onPressed: () {
          this._formKey.currentState.save();
          _saveAll(appconfig);
        },
      ),
    );
  }
}
