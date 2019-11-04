import 'package:flutter/material.dart';
import 'package:flutter_scrapmedia/model/data.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_scrapmedia/model/appconfig.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchScreen> {
  String isbn;
  AppConfigModel appConfig;
  ScrapMediaItem item;
  AppDataModel appData;

  @override
  Widget build(BuildContext context) {
    appConfig = Provider.of<AppConfigModel>(context);
    appData = Provider.of<AppDataModel>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Search'),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showText(),
            ],
          ),
        ));
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 100.0, 5.0, 0.0),
      child: TextField(
        onChanged: (text) {
          isbn = text;
        },
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Input search word',
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
            child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => {Navigator.pop(context, isbn)}),
          ),
        ),
      ),
    );
  }
}
