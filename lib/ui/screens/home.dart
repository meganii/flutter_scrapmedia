import 'package:flutter/material.dart';
import 'package:flutter_scrapmedia/model/app_config.dart';
import 'package:flutter_scrapmedia/model/app_state.dart';
import 'package:flutter_scrapmedia/model/config_key.dart';
import 'package:flutter_scrapmedia/services/service.dart';
import 'package:flutter_scrapmedia/ui/screens/search.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

enum ScrapmediaServices { openBDAPI, awsAPI }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfigModel>(context);
    final appState = Provider.of<AppStateModel>(context);

    // if (appState?.message != null) {
    //   _scaffoldKey.currentState
    //     ..removeCurrentSnackBar()
    //     ..showSnackBar(SnackBar(content: Text(appState.message)));
    //   appState.updateMessage(null);
    // }
    return _buildContent(context, appConfig, appState, _scaffoldKey);
  }

  _buildContent(BuildContext context, AppConfigModel appConfig,
      AppStateModel appState, GlobalKey<ScaffoldState> scaffoldKey) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: const Text("Scrap Media"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings_applications),
          tooltip: 'Settings',
          onPressed: () {
            Navigator.pushNamed(context, '/setting');
          },
        )
      ]),
      body: _ScrollView(appConfig, appState),
      floatingActionButton: _SpeedDialSearchButton(appConfig, appState),
    );
  }
}

class _ScrollView extends StatelessWidget {
  final AppConfigModel appConfig;
  final AppStateModel appState;

  const _ScrollView(this.appConfig, this.appState);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (appState.item?.title != null)
            Text(
              appState.item?.title ?? '',
              style: const TextStyle(fontSize: 40.0),
            ),
          (appState.item?.cover != null)
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Image.network(appState.item?.cover ?? ''),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Image.asset('assets/images/scrapmedia_icon.png'),
                ),
          Row(
            children: <Widget>[
              if (appState.visibleShareButtons)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: TextButton(
                    child: const Text('Tweet'),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue)),
                    onPressed: () => {tweet(appState.item!)},
                  ),
                ),
              if (appState.visibleShareButtons)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: TextButton(
                    child: const Text('Scrapbox'),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green)),
                    onPressed: () => {
                      openScrapbox(
                          appState.item!,
                          appConfig.values[
                              ConfigKey.scrapboxProjectName.toString()]!)
                    },
                  ),
                ),
            ],
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 100.0))
        ],
      ),
    ));
  }
}

class _SpeedDialSearchButton extends StatelessWidget {
  final AppConfigModel appConfig;
  final AppStateModel appState;

  const _SpeedDialSearchButton(this.appConfig, this.appState);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.search_ellipsis,
      animatedIconTheme: const IconThemeData(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.search),
          backgroundColor: Colors.green[300],
          label: 'Search from ISBN',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () =>
              {_navigateAndDisplaySelection(context, appConfig, appState)},
        ),
        SpeedDialChild(
          child: const Icon(Icons.camera_alt),
          backgroundColor: Colors.grey,
          label: 'Scan ISBN Code',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () => scanCode(appConfig, appState),
        ),
      ],
    );
  }

  _navigateAndDisplaySelection(BuildContext context, AppConfigModel appConfig,
      AppStateModel appData) async {
    final isbn = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );

    final scrapMediaAppConfig = createScrapMediaAppConfigFrom(appConfig);
    var item = await fetchItem(isbn, scrapMediaAppConfig);
    if (item.title != null) {
      appData.updateItem(item);
      appData.updateVisibleShareButtons(true);
    } else {
      appData.updateMessage('見つかりませんでした');
    }
  }
}
