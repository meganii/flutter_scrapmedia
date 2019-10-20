import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_scrapmedia/app.dart';
import 'package:flutter_scrapmedia/model/appconfig.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      builder: (context) => AppConfigModel(),
      child: ScrapmediaApp(),
    ),
  );
}
