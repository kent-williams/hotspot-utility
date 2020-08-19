import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/src/screens/wifi_available_ssid_screen.dart';
import 'package:http/http.dart' as http;

class HotspotScreen extends StatefulWidget {
  const HotspotScreen({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  _HotspotScreenState createState() => _HotspotScreenState();
}

class _HotspotScreenState extends State<HotspotScreen> {
  BluetoothCharacteristic wifiServicesChar;
  BluetoothCharacteristic wifiConfiguredServicesChar;
  BluetoothCharacteristic wifiSsidChar;
  BluetoothCharacteristic wifiConnectChar;
  BluetoothCharacteristic wifiRemoveChar;
  BluetoothCharacteristic ethernetOnlineChar;
  BluetoothCharacteristic hotspotFirmwareChar;
  BluetoothCharacteristic publicKeyChar;

  bool wifiSsidBuilt = false;
  bool foundChars = true;
  String wifiSsidResult = 'None';
  String publicKeyResult = 'None';

  StreamController<String> hotspotNameStreamController =
      StreamController<String>();
  StreamController<String> wifiSsidStreamController =
      StreamController<String>();
  StreamController<bool> charReadStatusStreamController =
      StreamController<bool>.broadcast();
  StreamController<String> ethernetStatusStreamController =
      StreamController<String>();
  StreamController<String> hotspotFirmwareStreamController =
  StreamController<String>();

  @override
  void dispose() {
    super.dispose();
    hotspotNameStreamController.close();
    wifiSsidStreamController.close();
    charReadStatusStreamController.close();
    ethernetStatusStreamController.close();
    hotspotFirmwareStreamController.close();
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    hotspotNameStreamController.add('');
    wifiSsidStreamController.add('');
    charReadStatusStreamController.add(false);
    ethernetStatusStreamController.add('');
    hotspotFirmwareStreamController.add('');

    widget.device.state.listen((connectionState) {
      if (connectionState == BluetoothDeviceState.connected) {
        widget.device.discoverServices().then((services) {
          _findChars(services);
          // public key
          publicKeyChar.read().then((value) {
            publicKeyResult = new String.fromCharCodes(value);
            // hotspot info http
            http
                .get("https://api.helium.io/v1/hotspots/" + publicKeyResult)
                .then((value) {
              var parsed = json.decode(value.body);
              hotspotNameStreamController.add(parsed['data']['name']);
            })
            .catchError((e) {
              print("Helium API Error");
            });
            // current wifi ssid
            wifiSsidChar.read().then((value) {
              wifiSsidResult = new String.fromCharCodes(value);
              // add result to stream
              wifiSsidStreamController.add(wifiSsidResult);
              // ethernet status
              ethernetOnlineChar.read().then((value) {
                var ethernetStatusResult = new String.fromCharCodes(value);
                // add result to stream
                if (ethernetStatusResult == 'true') {
                  ethernetStatusStreamController.add('Connected');
                } else {
                  ethernetStatusStreamController.add('Disconnected');
                }
                hotspotFirmwareChar.read().then((value) {
                  // indicate last char read is done
                  charReadStatusStreamController.add(true);
                  // add result to stream
                  hotspotFirmwareStreamController.add(new String.fromCharCodes(value));
                });
              });
            });
          });
        });
      }
    });
  }

  void _findChars(List<BluetoothService> services) {
    if (services != null) {
      var hotspotService = services.singleWhere(
          (s) => s.uuid.toString() == "0fda92b2-44a2-4af2-84f5-fa682baa2b8d",
          orElse: () => null);
      var deviceInformationService = services.singleWhere(
              (s) => s.uuid.toString() == "0000180a-0000-1000-8000-00805f9b34fb",
          orElse: () => null);
      if (hotspotService != null) {
        wifiSsidChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "7731de63-bc6a-4100-8ab1-89b2356b038b",
            orElse: () => null);
        wifiServicesChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "d7515033-7e7b-45be-803f-c8737b171a29",
            orElse: () => null);
        wifiConfiguredServicesChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "e125bda4-6fb8-11ea-bc55-0242ac130003",
            orElse: () => null);
        wifiConnectChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "398168aa-0111-4ec0-b1fa-171671270608",
            orElse: () => null);
        wifiRemoveChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "8cc6e0b3-98c5-40cc-b1d8-692940e6994b",
            orElse: () => null);
        ethernetOnlineChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "e5866bd6-0288-4476-98ca-ef7da6b4d289",
            orElse: () => null);
        hotspotFirmwareChar = deviceInformationService.characteristics.singleWhere(
                (c) => c.uuid.toString() == "00002a26-0000-1000-8000-00805f9b34fb",
            orElse: () => null);
        publicKeyChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "0a852c59-50d3-4492-bfd3-22fe58a24f01",
            orElse: () => null);
      }
    } else {
      print("Erro: Services is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<String>(
            stream: hotspotNameStreamController.stream,
            initialData: '',
            builder: (c, snapshot) {
              if (snapshot.data != '') {
                return Text(snapshot.data);
              } else {
                return Text('');
              }
            }),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: (snapshot.data == BluetoothDeviceState.connected)
                    ? Text('Connected to Hotspot Bluetooth')
                    : Text('Disconnected from Hotspot Bluetooth'),
                trailing: StreamBuilder<bool>(
                    stream: charReadStatusStreamController.stream,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data == false) {
                        return CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.grey),
                        );
                      } else {
                        return Icon(null);
                      }
                    })),
          ),
          StreamBuilder<String>(
              stream: wifiSsidStreamController.stream,
              initialData: 'None',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.wifi),
                    title: Text('Wi-Fi Network'),
                    subtitle: Text(snapshot.data),
                    trailing: StreamBuilder<bool>(
                        stream: charReadStatusStreamController.stream,
                        initialData: false,
                        builder: (c, snapshot) {
                          if (snapshot.data == true) {
                            return IconButton(
                              icon: Icon(Icons.settings),
                              tooltip: 'Configure Wi-Fi Network',
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return WifiAvailableScreen(
                                      currentWifiSsid: wifiSsidResult,
                                      device: widget.device,
                                      wifiServicesChar: wifiServicesChar,
                                      wifiConfiguredServicesChar:
                                          wifiConfiguredServicesChar,
                                      wifiSsidChar: wifiSsidChar,
                                      wifiConnectChar: wifiConnectChar,
                                      wifiRemoveChar: wifiRemoveChar);
                                }));
                              },
                            );
                          } else {
                            return Icon(null);
                          }
                        }),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: ethernetStatusStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.settings_ethernet),
                    title: Text('Ethernet'),
                    subtitle: Text(snapshot.data),
                    trailing: Text('Auto Connects'),
                  )
                ]);
              }),
          StreamBuilder<String>(
              stream: hotspotFirmwareStreamController.stream,
              initialData: '',
              builder: (c, snapshot) {
                return Column(children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.system_update),
                    title: Text('Firmware Version'),
                    subtitle: Text(snapshot.data),
                  )
                ]);
              })
        ]),
      ),
    );
  }
}
