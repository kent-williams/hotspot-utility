import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/gen/hotspotutility.pb.dart' as protos;

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({
    Key key,
    this.device,
    this.hotspotDiagnosticsChar,
  }) : super(key: key);
  final BluetoothDevice device;
  final BluetoothCharacteristic hotspotDiagnosticsChar;

  _DiagnosticsScreenState createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  StreamController<Map<String, String>> hotspotDiagnosticsStreamController =
      StreamController<Map<String, String>>();

  Map<String, String> diagnosticsResults;

  @override
  void dispose() {
    super.dispose();
    hotspotDiagnosticsStreamController.close();
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();

    widget.hotspotDiagnosticsChar.read().then((value) {
      if (new String.fromCharCodes(value) != "failed") {
        var diagnosticsResults =
            protos.diagnostics_v1.fromBuffer(value).diagnostics;
        hotspotDiagnosticsStreamController.add(diagnosticsResults);
      }
    }).catchError((e) {
      print("Error: hotspotDiagnosticsChar Read Failure: ${e.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Diagnostics Report"),
          actions: <Widget>[],
        ),
        body: StreamBuilder<Map<String, String>>(
                stream: hotspotDiagnosticsStreamController.stream,
                builder: (c, snapshot) {
                  if (snapshot.data != null) {
                    return new ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = snapshot.data.keys.elementAt(index);
                        return new Column(
                          children: <Widget>[
                            new ListTile(
                              title: new Text("$key"),
                              subtitle: new Text("${snapshot.data[key]}"),
                            ),
                            new Divider(
                              height: 2.0,
                            ),
                          ],
                        );
                      },
                    );
                  }
                  else
                    return Container();
                  // return ListView.builder(
                  //   physics: NeverScrollableScrollPhysics(),
                  //   scrollDirection: Axis.vertical,
                  //   shrinkWrap: true,
                  //   itemCount: snapshot.data.length,
                  //   itemBuilder: (context, index) {
                  //     return ListTile(
                  //       title: Text(snapshot.data[index].toString()),
                  //       leading: snapshot.data[index].toString() == 'something'
                  //           ? Icon(
                  //               Icons.check_circle,
                  //               color: Colors.grey,
                  //               size: 24.0,
                  //               semanticLabel: 'Connected to Network',
                  //             )
                  //           : Icon(
                  //               Icons.wifi_lock,
                  //               color: Colors.grey,
                  //               size: 24.0,
                  //               semanticLabel: 'Available Network',
                  //             ),
                  //       trailing: Icon(Icons.keyboard_arrow_right),
                  //     );
                  //   },
                  // );
                }));
  }
}
