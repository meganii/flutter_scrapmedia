import 'package:flutter/material.dart';

import 'package:flutter_scrapmedia/app.dart';
import 'package:flutter_scrapmedia/state_widget.dart';

// - StateWidget incl. state data
//    - ScrapmediaApp
//        - All other widgets which are able to access the data
void main() {
  StateWidget stateWidget = new StateWidget(child:new ScrapmediaApp());
  runApp(stateWidget);
}
