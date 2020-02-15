import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_scrapmedia/app.dart';
import 'package:flutter_scrapmedia/model/app_config.dart';
import 'package:flutter_scrapmedia/model/app_state.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppConfigModel()),
        ChangeNotifierProvider(create: (context) => AppStateModel()),
      ],
      child: ScrapmediaApp(),
    ),
  );
}
