import 'package:flutter/material.dart';
import 'package:flutter_scrapmedia/model/app_config.dart';
import 'package:flutter_scrapmedia/model/config_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

enum ScrapmediaServices { openBDAPI, awsAPI }

class SettingScreen extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    var appConfig = Provider.of<AppConfigModel>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(appConfig),
          ],
        ));
  }

  final _formKey = new GlobalKey<FormState>();

  void _saveAll(AppConfigModel appConfig) async {
    final storage = new FlutterSecureStorage();
    if (appConfig.values[ConfigKey.scrapboxProjectName.toString()] != null) {
      await storage.write(
          key: ConfigKey.scrapboxProjectName.toString(),
          value: appConfig.values[ConfigKey.scrapboxProjectName.toString()]);
    }
    if (appConfig.values[ConfigKey.amazonKey.toString()] != null) {
      await storage.write(
          key: ConfigKey.amazonKey.toString(),
          value: appConfig.values[ConfigKey.amazonKey.toString()]);
    }
    if (appConfig.values[ConfigKey.amazonSecret.toString()] != null) {
      await storage.write(
          key: ConfigKey.amazonSecret.toString(),
          value: appConfig.values[ConfigKey.amazonSecret.toString()]);
    }
    if (appConfig.values[ConfigKey.amazonTagName.toString()] != null) {
      await storage.write(
          key: ConfigKey.amazonTagName.toString(),
          value: appConfig.values[ConfigKey.amazonTagName.toString()]);
    }
    if (appConfig.values[ConfigKey.appSearchMethod.toString()] != null) {
      await storage.write(
          key: ConfigKey.appSearchMethod.toString(),
          value: appConfig.values[ConfigKey.appSearchMethod.toString()]);
    }
    if (appConfig.values[ConfigKey.bitlyKey.toString()] != null) {
      await storage.write(
          key: ConfigKey.bitlyKey.toString(),
          value: appConfig.values[ConfigKey.bitlyKey.toString()]);
    }
  }

  Widget _showBody(AppConfigModel appConfig) {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: this._formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showScrapboxInput(appConfig),
              _showRadioButton(appConfig),
              _showEmailInput(appConfig),
              _showPasswordInput(appConfig),
              _showTagInput(appConfig),
              _showBitlyInput(appConfig),
              _showSaveButton(appConfig),
            ],
          ),
        ));
  }

  Widget _showScrapboxInput(AppConfigModel appConfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        initialValue:
            appConfig.values[ConfigKey.scrapboxProjectName.toString()],
        onSaved: (text) {
          appConfig.update(ConfigKey.scrapboxProjectName.toString(), text);
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

  Widget _showRadioButton(AppConfigModel appConfig) {
    var searchMethod = appConfig.values[ConfigKey.appSearchMethod.toString()];

    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: Column(
          children: <Widget>[
            Text(
              'Which API do you use',
              textAlign: TextAlign.left,
            ),
            RadioListTile<String>(
              title: const Text('openBD API'),
              value: ScrapmediaServices.openBDAPI.toString(),
              groupValue: searchMethod,
              onChanged: (String value) {
                appConfig.update(
                    ConfigKey.appSearchMethod.toString(), value.toString());
              },
            ),
            RadioListTile<String>(
              title: const Text('Amazon Product Advertising API'),
              value: ScrapmediaServices.awsAPI.toString(),
              groupValue: searchMethod,
              onChanged: (String value) {
                appConfig.update(
                    ConfigKey.appSearchMethod.toString(), value.toString());
              },
            ),
          ],
        ));
  }

  Widget _showEmailInput(AppConfigModel appConfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        initialValue: appConfig.values[ConfigKey.amazonKey.toString()],
        onSaved: (text) {
          appConfig.update(ConfigKey.amazonKey.toString(), text);
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

  Widget _showPasswordInput(AppConfigModel appConfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        initialValue: appConfig.values[ConfigKey.amazonSecret.toString()],
        onSaved: (text) {
          appConfig.update(ConfigKey.amazonSecret.toString(), text);
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

  Widget _showTagInput(AppConfigModel appConfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        initialValue: appConfig.values[ConfigKey.amazonTagName.toString()],
        onSaved: (text) {
          appConfig.update(ConfigKey.amazonTagName.toString(), text);
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

  Widget _showBitlyInput(AppConfigModel appConfig) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: new TextFormField(
          initialValue: appConfig.values[ConfigKey.bitlyKey.toString()],
          onSaved: (text) {
            appConfig.update(ConfigKey.bitlyKey.toString(), text);
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

  Widget _showSaveButton(AppConfigModel appConfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: RaisedButton(
        child: Text('Submit'),
        onPressed: () {
          this._formKey.currentState.save();
          _saveAll(appConfig);
        },
      ),
    );
  }
}
