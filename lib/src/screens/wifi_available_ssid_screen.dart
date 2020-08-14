import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/gen/hotspotutility.pb.dart' as protos;
import 'package:hotspotutility/src/screens/wifi_connect_screen.dart';

class WifiAvailableScreen extends StatefulWidget {
  const WifiAvailableScreen(
      {Key key,
      this.currentWifiSsid,
      this.device,
      this.wifiServicesChar,
      this.wifiConfiguredServicesChar,
      this.wifiSsidChar,
      this.wifiConnectChar,
      this.wifiRemoveChar})
      : super(key: key);
  final String currentWifiSsid;
  final BluetoothDevice device;
  final BluetoothCharacteristic wifiServicesChar;
  final BluetoothCharacteristic wifiConfiguredServicesChar;
  final BluetoothCharacteristic wifiSsidChar;
  final BluetoothCharacteristic wifiConnectChar;
  final BluetoothCharacteristic wifiRemoveChar;

  _WifiAvailableScreenState createState() => _WifiAvailableScreenState();
}

class _WifiAvailableScreenState extends State<WifiAvailableScreen> {
  StreamController<List<String>> wifiSsidListStreamController =
      StreamController<List<String>>();

  List<String> configuredSsidResults;

  @override
  void dispose() {
    super.dispose();
    wifiSsidListStreamController.close();
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    wifiSsidListStreamController.add([]);

    widget.wifiConfiguredServicesChar.read().then((value) {
      configuredSsidResults =
          protos.wifi_services_v1.fromBuffer(value).services.toList();

      widget.wifiServicesChar.read().then((value) {
        if (new String.fromCharCodes(value) != "failed") {
          var availableSsidResults =
              protos.wifi_services_v1.fromBuffer(value).services;
          wifiSsidListStreamController.add(availableSsidResults);
        }
      });
    }).catchError((e) {
      print("Error: wifiConfiguredServices Failure: ${e.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Available Wi-Fi Networks"),
          actions: <Widget>[],
        ),
        body: SingleChildScrollView(
            child: StreamBuilder<List<String>>(
                stream: wifiSsidListStreamController.stream,
                initialData: [],
                builder: (c, snapshot) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Text(snapshot.data[index].toString()),
                          leading: snapshot.data[index].toString() ==
                                  widget.currentWifiSsid
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.grey,
                                  size: 24.0,
                                  semanticLabel: 'Connected to Network',
                                )
                              : Icon(
                                  Icons.wifi_lock,
                                  color: Colors.grey,
                                  size: 24.0,
                                  semanticLabel: 'Available Network',
                                ),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return WifiConnectScreen(
                                  currentWifiSsid: widget.currentWifiSsid,
                                  device: widget.device,
                                  wifiNetworkSelected:
                                      snapshot.data[index].toString(),
                                  wifiSsidChar: widget.wifiSsidChar,
                                  wifiConfiguredServices: configuredSsidResults,
                                  wifiConnectChar: widget.wifiConnectChar,
                                  wifiRemoveChar: widget.wifiRemoveChar);
                            }));
                          });
                    },
                  );
                })));
  }
}
