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
  StreamController<String> ethMacStreamController = StreamController<String>();
  StreamController<String> wifiMacStreamController = StreamController<String>();
  StreamController<String> fwStreamController = StreamController<String>();
  StreamController<String> ipStreamController = StreamController<String>();
  StreamController<String> natTypeStreamController = StreamController<String>();

  StreamController<String> outboundConnectionStreamController =
      StreamController<String>();
  StreamController<String> inboundConnectionStreamController =
      StreamController<String>();
  StreamController<String> lastChallengeStreamController =
      StreamController<String>();
  StreamController<bool> dataRequestCompleteStreamController =
      StreamController<bool>.broadcast();
  StreamController<String> blockchainHeightStreamController =
      StreamController<String>();

  Map<String, String> diagnosticsResults;
  int blockchainHeight;

  @override
  void dispose() {
    super.dispose();
    ethMacStreamController.close();
    wifiMacStreamController.close();
    fwStreamController.close();
    ipStreamController.close();
    natTypeStreamController.close();

    outboundConnectionStreamController.close();
    inboundConnectionStreamController.close();
    lastChallengeStreamController.close();
    blockchainHeightStreamController.close();

    dataRequestCompleteStreamController.close();
  }

  Future getLastChallenge() {
    return http
        .get(
      "https://api.helium.io/v1/hotspots/" +
          widget.hotspotPublicKey +
          "/challenges",
    )
        .then((value) {
      var parsed = json.decode(value.body);
      print(parsed);
      if (parsed['data'].length != 0) {
        lastChallengeStreamController.add(
            new DateTime.fromMillisecondsSinceEpoch(
                    parsed['data'][0]['time'] * 1000)
                .toString());
        var timeDiff = new DateTime.now().millisecondsSinceEpoch -
            parsed['data'][0]['time'] * 1000;
        print(new DateTime.fromMillisecondsSinceEpoch(
            parsed['data'][0]['time'] * 1000));
        // if data list is empty check if cursor exist
        // if cursor exist then request another page
        // if data is not empty then use last time
        // if data list and cursor are empty then stop
      } else {
        print("DATA LIST EMPTY TRYING AGAIN");
        return http
            .get(
          "https://api.helium.io/v1/hotspots/" +
              widget.hotspotPublicKey +
              "/challenges?cursor=" +
              parsed['cursor'],
        )
            .then((value) {
          var parsed = json.decode(value.body);
          print(parsed);
          if (parsed['data'].length != 0) {
            lastChallengeStreamController.add(
                new DateTime.fromMillisecondsSinceEpoch(
                    parsed['data'][0]['time'] * 1000)
                    .toString());
          }
        });
      }
    });
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();

    widget.hotspotDiagnosticsChar.read().then((value) {
      if (new String.fromCharCodes(value) != "failed") {
        diagnosticsResults =
            protos.diagnostics_v1.fromBuffer(value).diagnostics;
        print(diagnosticsResults);
      }
      // blockchain height http
      http.get("https://api.helium.io/v1/blocks/height").then((value) {
        var parsed = json.decode(value.body);
        print(parsed['data']['height']);
        blockchainHeightStreamController
            .add(parsed['data']['height'].toString());
        blockchainHeight = parsed['data']['height'];

        getLastChallenge().then((value) {

          // Add data to streams
          print(diagnosticsResults);
          diagnosticsResults.forEach((key, value) {
            switch (key) {
              case 'height':
                blockchainHeightStreamController.add(
                    ((int.parse(value) / blockchainHeight).toInt() * 100)
                            .toString() +
                        '%');
                break;
              case 'eth':
                ethMacStreamController.add(value);
                break;
              case 'wifi':
                wifiMacStreamController.add(value);
                break;
              case 'fw':
                fwStreamController.add(value);
                break;
              case 'ip':
                ipStreamController.add(value);
                break;
              case 'nat_type':
                natTypeStreamController.add(value);
                break;
              case 'connected':
                if (value == 'yes')
                  outboundConnectionStreamController.add('OK');
                else
                  outboundConnectionStreamController.add('No Connection');
                break;
              case 'dialable':
                if (value == 'yes')
                  inboundConnectionStreamController.add('OK');
                else
                  inboundConnectionStreamController.add('No Connection');
                break;
              default:
                print("no key match");
                break;
            }
          });
          dataRequestCompleteStreamController.add(true);
        });
        //     .catchError((e) {
        //   print(
        //       "Helium Blockchain Hotspot Challenges API Error: ${e.toString()}");
        // });
      });
      // .catchError((e) {
      //   print("Helium Blockchain Height API Error");
      // });
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
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  //Share.share('check out my website https://example.com');
                }),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          // StreamBuilder<Map<String, String>>(
          //     stream: hotspotDiagnosticsStreamController.stream,
          //     builder: (c, snapshot) {
          //       if (snapshot.data != null) {
          //         return new ListView.builder(
          //           itemCount: snapshot.data.length,
          //           itemBuilder: (BuildContext context, int index) {
          //             switch (snapshot.data.keys.elementAt(index)) {
          //               case 'eth':
          //                 String key = snapshot.data.keys.elementAt(index);
          //                 return new Column(
          //                   children: <Widget>[
          //                     new ListTile(
          //                       title: new Text("$key"),
          //                       subtitle: new Text("${snapshot.data[key]}"),
          //                     ),
          //                     new Divider(
          //                       height: 2.0,
          //                     ),
          //                   ],
          //                 );
          //               case 'height':
          //                 String key = snapshot.data.keys.elementAt(index);
          //                 return new Column(
          //                   children: <Widget>[
          //                     new ListTile(
          //                       title: new Text("$key"),
          //                       subtitle: new Text(
          //                           "${(int.parse(snapshot.data[key]) / blockchainHeight)}"),
          //                     ),
          //                     new Divider(
          //                       height: 2.0,
          //                     ),
          //                   ],
          //                 );
          //               default:
          //                 return new Column();
          //             }
          //           },
          //         );
          //       } else
          //         return Container();
          //       // return ListView.builder(
          //       //   physics: NeverScrollableScrollPhysics(),
          //       //   scrollDirection: Axis.vertical,
          //       //   shrinkWrap: true,
          //       //   itemCount: snapshot.data.length,
          //       //   itemBuilder: (context, index) {
          //       //     return ListTile(
          //       //       title: Text(snapshot.data[index].toString()),
          //       //       leading: snapshot.data[index].toString() == 'something'
          //       //           ? Icon(
          //       //               Icons.check_circle,
          //       //               color: Colors.grey,
          //       //               size: 24.0,
          //       //               semanticLabel: 'Connected to Network',
          //       //             )
          //       //           : Icon(
          //       //               Icons.wifi_lock,
          //       //               color: Colors.grey,
          //       //               size: 24.0,
          //       //               semanticLabel: 'Available Network',
          //       //             ),
          //       //       trailing: Icon(Icons.keyboard_arrow_right),
          //       //     );
          //       //   },
          //       // );
          //     }),
          StreamBuilder<String>(
              stream: outboundConnectionStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('Outbound Peer-to-Peer Connection'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: inboundConnectionStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('Inbound Peer-to-Peer Connection'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: blockchainHeightStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('Blockchain Height'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: lastChallengeStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('Last Challenged'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: fwStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('Hotspot Firmware'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: wifiMacStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('Wi-Fi MAC'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: ethMacStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('Ethernet MAC'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: natTypeStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('NAT Type'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: ipStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text('IP Address'),
                    subtitle: Text(snapshot.data.toString()),
                  )
                ]);
              }),
        ])));
  }
}
