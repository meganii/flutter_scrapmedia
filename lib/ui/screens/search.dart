import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showText(context),
            ],
          ),
        ));
  }

  Widget _showText(BuildContext context) {
    String _isbn = '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 100.0, 5.0, 0.0),
      child: TextField(
        onChanged: (text) {
          _isbn = text;
        },
        onSubmitted: (_) {
          Navigator.pop(context, _isbn);
        },
        textInputAction: TextInputAction.search,
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Type ISBN(13)',
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
            child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => {Navigator.pop(context, _isbn)}),
          ),
        ),
      ),
    );
  }
}
