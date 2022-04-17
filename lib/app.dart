import 'package:flutter/material.dart';
import 'package:flutter_scrapmedia/ui/screens/home.dart';
import 'package:flutter_scrapmedia/ui/screens/setting.dart';

class ScrapmediaApp extends StatelessWidget {
  const ScrapmediaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrap Media',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomeScreen(),
        '/setting': (context) => const SettingScreen(),
      },
    );
  }
}
