import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;
import 'package:hotspotutility/gen/hotspotutility.pb.dart' as protos;

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({
    Key key,
    this.device,
    this.hotspotDiagnosticsChar,
    this.hotspotName,
    this.hotspotPublicKey,
  }) : super(key: key);
  final BluetoothDevice device;
  final BluetoothCharacteristic hotspotDiagnosticsChar;
  final String hotspotName;
  final String hotspotPublicKey;

  _DiagnosticsScreenState createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  StreamController<Map<String, String>> hotspotDiagnosticsStreamController =
      StreamController<Map<String, String>>();
  StreamController<int> blockchainHeightStreamController =
      StreamController<int>();

  Map<String, String> diagnosticsResults;

  @override
  void dispose() {
    super.dispose();
    hotspotDiagnosticsStreamController.close();
    blockchainHeightStreamController.close();
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
      // blockchain height http
      http.get("https://api.helium.io/v1/blocks/height").then((value) {
        var parsed = json.decode(value.body);
        print(parsed['data']['height']);
        blockchainHeightStreamController.add(parsed['data']['height']);
        // hotspot challenge http
        print(widget.hotspotPublicKey);
        http
            .get("https://api.helium.io/v1/hotspots/" + widget.hotspotPublicKey + "/challenges", )
            .then((value) {
          var parsed = json.decode(value.body);
          // blockchainHeightStreamController.add(parsed['data']['time']);
          print(new DateTime.fromMillisecondsSinceEpoch(parsed['data'][0]['time'] * 1000));
          // if data list is empty check if cursor exist
          // if cursor exist then request another page
          // if data is not empty then use last time
          // if data list and cursor are empty then stop
        }).catchError((e) {
          print("Helium Blockchain Hotspot Challenges API Error: ${e.toString()}");
        });
      }).catchError((e) {
        print("Helium Blockchain Height API Error");
      });
    }).catchError((e) {
      print("Error: hotspotDiagnosticsChar Read Failure: ${e.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Diagnostics Report",
                style: TextStyle(fontSize: 17.0),
              ),
              Text(
                widget.hotspotName,
                style: TextStyle(fontSize: 15.0),
              )
            ],
          ),
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
              } else
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
