import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_scrapmedia/app.dart';
import 'package:flutter_scrapmedia/model/appconfig.dart';
import 'package:flutter_scrapmedia/model/data.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => AppConfigModel()),
        ChangeNotifierProvider(builder: (context) => AppDataModel()), 
      ],
      child: ScrapmediaApp(),
    ),
  );
}
