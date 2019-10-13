import 'package:flutter/material.dart';
import 'package:flutter_scrapmedia/model/scrapmedia_property.dart';
import 'package:flutter_scrapmedia/model/state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({
    @required this.child,
    this.state,
  });

  // Returns data of the nearest widget _StateDataWidget
  // in the widget tree.
  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => new _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;

  void _readAllProperty() async {
    final storage = new FlutterSecureStorage();
    var value = await storage.readAll();

    var _service;
    if (value[ScrapmediaProperty.useService.toString()] ==
        ScrapmediaServices.awsAPI.toString()) {
      _service = ScrapmediaServices.awsAPI;
    }

    state = new StateModel(
      awsAccessKeyIdController: TextEditingController(
          text: value[ScrapmediaProperty.accessKey.toString()]),
      awsAssociateTagController: TextEditingController(
          text: value[ScrapmediaProperty.associateTag.toString()]),
      awsSecretAccessKeyController: TextEditingController(
          text: value[ScrapmediaProperty.secretKey.toString()]),
      scrapboxProjectNameController: TextEditingController(
          text: value[ScrapmediaProperty.projectName.toString()]),
      bitlyApiKeyController: TextEditingController(
          text: value[ScrapmediaProperty.bitlyApiKey.toString()]),
      service: _service,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      _readAllProperty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _StateDataWidget:
  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
