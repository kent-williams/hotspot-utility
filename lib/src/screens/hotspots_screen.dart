import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/src/screens/hotspot_screen.dart';
import 'package:hotspotutility/src/widgets/bluetooth_device_widgets.dart';

final List<Guid> scanFilterServiceUuids = [
  Guid('0fda92b2-44a2-4af2-84f5-fa682baa2b8d')
];

class HotspotsScreen extends StatelessWidget {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          return FindDevicesScreen();
        });
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);
  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key key}) : super(key: key);

  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  StreamController<bool> showTipCardStreamController = StreamController<bool>();

  @override
  void dispose() {
    super.dispose();
    showTipCardStreamController.close();
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    showTipCardStreamController.add(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Hotspots'),
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBlue.instance.startScan(
            timeout: Duration(seconds: 3),
            withServices: scanFilterServiceUuids),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<bool>(
                  stream: showTipCardStreamController.stream,
                  initialData: false,
                  builder: (c, snapshot) {
                    if (snapshot.data == true) {
                      return
                        SizedBox(
                          child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.all(20),
                          elevation: 5.0,
                          child: InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: () {
                              print('Card tapped.');
                            },
                            child: Container(
                              child: Text(
                                'To scan for hotspots, first press the black button on the left side of your hotspot, wait for the hotspot LED to turn blue, then press the magnifying glass button in the bottom right of the app to scan.',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .copyWith(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            r.device.state.listen((connectionState) {
                              print("connectionState Hotspots Screen: " +
                                  connectionState.toString());
                              if (connectionState ==
                                  BluetoothDeviceState.disconnected) {
                                r.device.connect();
                              }
                            }, onDone: () {
                              print("Connection State Check Complete");
                            }, onError: (error) {
                              print("Connection Error: " + error);
                            });
                            return HotspotScreen(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () {
                  showTipCardStreamController.add(false);
                  FlutterBlue.instance.startScan(
                      timeout: Duration(seconds: 3),
                      withServices: scanFilterServiceUuids);
                });
          }
        },
      ),
    );
  }
}
