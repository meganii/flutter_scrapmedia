
import 'package:flutter/material.dart';

import 'package:flutter_scrapmedia/ui/screens/search.dart';
import 'package:provider/provider.dart';
import 'package:flutter_scrapmedia/model/appconfig.dart';
import 'package:flutter_scrapmedia/model/config_key.dart';
import 'package:flutter_scrapmedia/model/data.dart';
import 'package:flutter_scrapmedia/services/service.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfigModel>(context);
    final appData = Provider.of<AppDataModel>(context);
    
    if (appData?.message != null) {
      _scaffoldKey.currentState
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(appData.message)));
      appData.updateMessage(null);
    }
    return _buildContent(context, appConfig, appData, _scaffoldKey);
  }

  _buildContent(BuildContext context, AppConfigModel appConfig,
      AppDataModel appData, GlobalKey<ScaffoldState> scaffoldKey) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text("Scrap Media"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings_applications),
          tooltip: 'Settings',
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
              if (appData?.item?.title != null)
                Text(
                  appData?.item?.title,
                  style: TextStyle(fontSize: 40.0),
                ),
              if (appData?.item?.cover != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Image.network(appData.item.cover),
                ),
              Row(
                children: <Widget>[
                  if (appData.visibleShareButtons)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      child: FlatButton(
                        child: Text('Tweet'),
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: () => {tweet(appData.item)},
                      ),
                    ),
                  if (appData.visibleShareButtons)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      child: FlatButton(
                        child: Text('Scrapbox'),
                        textColor: Colors.white,
                        color: Colors.green,
                        onPressed: () => {
                          openScrapbox(
                              appData.item,
                              appConfig.values[
                                  ConfigKey.scrapboxProjectName.toString()])
                        },
                      ),
                    ),
                ],
              ),
              Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 100.0))
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.search_ellipsis,
        animatedIconTheme: IconThemeData(),
        backgroundColor: Colors.green,
        children: [
          SpeedDialChild(
            child: Icon(Icons.search),
            backgroundColor: Colors.green[300],
            label: 'ISBN検索',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => {_navigateAndDisplaySelection(context, appConfig, appData)},
          ),
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
            backgroundColor: Colors.grey,
            label: 'ISBNコード読取',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => scanCode(appConfig, appData),
          ),
        ],
      ),
    );
  }

  _navigateAndDisplaySelection(
      BuildContext context, AppConfigModel appConfig, AppDataModel appData) async {
    final isbn = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );
    var item = await fetchItem(isbn, appConfig);
    if (item != null) {
      appData.updateItem(item);
      appData.updateVisibleShareButtons(true);
    } else {
      appData.updateMessage('見つかりませんでした');
    }
  }
}

enum ScrapmediaServices { openDBAPI, awsAPI }
