import 'package:flutter/material.dart';
import 'package:flutter_scrapmedia/ui/screens/home.dart';
import 'package:flutter_scrapmedia/ui/screens/setting.dart';

class ScrapmediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrap Media',
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomeScreen(),
        '/setting': (context) => SettingScreen(),
      },
    );
  }
}
