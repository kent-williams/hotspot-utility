import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[],
        ),
        body: ListView(
          children: ListTile.divideTiles(context: context, tiles: [
            ListTile(title: Text('Version'), trailing: Text("0.1.3")),
            ListTile(
              title: Text('Source Code - Git Hub'),
              onTap: () {
                launch('https://github.com/kent-williams/hotspot-utility');
              },
            ),
          ]).toList(),
        ));
  }
}
