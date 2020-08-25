import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/gen/hotspotutility.pb.dart' as protos;

class WifiConnectScreen extends StatefulWidget {
  const WifiConnectScreen(
      {Key key,
      this.currentWifiSsid,
      this.device,
      this.wifiNetworkSelected,
      this.wifiSsidChar,
      this.wifiConfiguredServices,
      this.wifiConnectChar,
      this.wifiRemoveChar})
      : super(key: key);
  final String currentWifiSsid;
  final BluetoothDevice device;
  final String wifiNetworkSelected;
  final BluetoothCharacteristic wifiSsidChar;
  final List<String> wifiConfiguredServices;
  final BluetoothCharacteristic wifiConnectChar;
  final BluetoothCharacteristic wifiRemoveChar;

  _WifiConnectScreenState createState() => _WifiConnectScreenState();
}

class _WifiConnectScreenState extends State<WifiConnectScreen> {
  List<int> availableSsidResults;
  final passwordController = TextEditingController();
  // Initially password is obscure
  bool _obscureText = true;
  StreamController<String> wifiConnectionStatusStreamController =
      StreamController<String>.broadcast();
  StreamController<bool> wifiConnectionSuccessStreamController =
      StreamController<bool>();
  bool _seenConnecting = false;

  @override
  void dispose() {
    super.dispose();
    wifiConnectionStatusStreamController.close();
    wifiConnectionSuccessStreamController.close();

    widget.wifiSsidChar.setNotifyValue(false).then((value) {
      print("WiFi SSID Char Notification Enabled Result: " + value.toString());

      widget.wifiConnectChar.setNotifyValue(false).then((value) {
        print("WiFi Connect Char Notification Enabled Result: " +
            value.toString());
      });
    });
  }

  @protected
  @mustCallSuper
  void initState() {
    if (widget.currentWifiSsid == widget.wifiNetworkSelected) {
      wifiConnectionStatusStreamController.add('Connected');
      wifiConnectionSuccessStreamController.add(true);
    } else {
      wifiConnectionStatusStreamController.add('');
      wifiConnectionSuccessStreamController.add(false);
    }
  }

  readChars(List<BluetoothCharacteristic> chars) async {
    await Future.forEach(chars, (char) async {
      await char.read();
    });
  }

  _writeWifiCredentials(String password) async {
    var wifiCredentials = protos.wifi_connect_v1.create();
    var wifiSsidRemove = protos.wifi_remove_v1.create();

    wifiCredentials.service = widget.wifiNetworkSelected;
    wifiCredentials.password = password;

    print("current WiFi ssid: " + widget.currentWifiSsid);

    widget.wifiSsidChar.setNotifyValue(true).then((value) {
      print("WiFi SSID Char Notification Enabled Result: " + value.toString());

      widget.wifiConnectChar.setNotifyValue(true).then((value) {
        print("WiFi Connect Char Notification Enabled Result: " +
            value.toString());

        if (widget.currentWifiSsid != "" && widget.currentWifiSsid != null) {
          // Remove Currently Connected WiFi Network
          wifiSsidRemove.service = widget.currentWifiSsid;
          print("network to remove: " + wifiSsidRemove.service.toString());
          widget.wifiRemoveChar
              .write(wifiSsidRemove.writeToBuffer())
              .then((value) {
            print("Remove Current WiFi SSID Write Result: " + value.toString());

            // Check if there are any other WiFi Configure Services
            print("Configured Services: " +
                widget.wifiConfiguredServices.toString());

            // Check if any WiFi Networks are already Configured
            if (widget.wifiConfiguredServices.length > 0) {
              // Remove WiFi Configured Services
              wifiSsidRemove.service = widget.wifiConfiguredServices[0];
              print("configured network to remove: " +
                  wifiSsidRemove.service.toString());
              widget.wifiRemoveChar
                  .write(wifiSsidRemove.writeToBuffer())
                  .then((value) {
                print("Remove Configured WiFi SSID Write Result: " +
                    value.toString());

                // Connect to new WiFi Network
                wifiConnectionStatusStreamController.add("Connecting...");
                widget.wifiConnectChar
                    .write(wifiCredentials.writeToBuffer())
                    .then((value) {
                  print("WiFi Connect Char Result: " + value.toString());

                  // Wait for connection result
                  StreamSubscription<String> subscription;
                  subscription = wifiConnectionStatusStreamController.stream
                      .listen((value) {
                    if (value == "Failed") {
                      subscription.cancel();
                      // Remove WiFi Network After Failure
                      var wifiSsidRemove = protos.wifi_remove_v1.create();
                      wifiSsidRemove.service = widget.wifiNetworkSelected;
                      print("network to remove after failure 1: " +
                          wifiSsidRemove.service.toString());
                      widget.wifiRemoveChar
                          .write(wifiSsidRemove.writeToBuffer())
                          .then((value) {});
                    }
                  });
                });
              });
            } else {
              // Connect to new WiFi Network
              wifiConnectionStatusStreamController.add("Connecting...");
              widget.wifiConnectChar
                  .write(wifiCredentials.writeToBuffer())
                  .then((value) {
                print("WiFi Connect Char Result: " + value.toString());

                // Wait for connection result
                StreamSubscription<String> subscription;
                subscription =
                    wifiConnectionStatusStreamController.stream.listen((value) {
                  if (value == "Failed") {
                    subscription.cancel();
                    // Remove WiFi Network After Failure
                    var wifiSsidRemove = protos.wifi_remove_v1.create();
                    wifiSsidRemove.service = widget.wifiNetworkSelected;
                    print("network to remove after failure 2: " +
                        wifiSsidRemove.service.toString());
                    widget.wifiRemoveChar
                        .write(wifiSsidRemove.writeToBuffer())
                        .then((value) {});
                  }
                });
              });
            }
          });
        } else {
          //
          // Check if there are any other WiFi Configure Services
          print("Configured Services: " +
              widget.wifiConfiguredServices.toString());

          // Check if any WiFi Networks are already Configured
          if (widget.wifiConfiguredServices.length > 0) {
            // Remove WiFi Configured Services
            wifiSsidRemove.service = widget.wifiConfiguredServices[0];
            print("configured network to remove: " +
                wifiSsidRemove.service.toString());
            widget.wifiRemoveChar
                .write(wifiSsidRemove.writeToBuffer())
                .then((value) {
              print("Remove Configured WiFi SSID Write Result: " +
                  value.toString());

              // Connect to new WiFi Network
              wifiConnectionStatusStreamController.add("Connecting...");
              widget.wifiConnectChar
                  .write(wifiCredentials.writeToBuffer())
                  .then((value) {
                print("WiFi Connect Char Result: " + value.toString());

                // Wait for connection result
                StreamSubscription<String> subscription;
                subscription =
                    wifiConnectionStatusStreamController.stream.listen((value) {
                  if (value == "Failed") {
                    subscription.cancel();
                    // Remove WiFi Network After Failure
                    var wifiSsidRemove = protos.wifi_remove_v1.create();
                    wifiSsidRemove.service = widget.wifiNetworkSelected;
                    print("network to remove after failure 3: " +
                        wifiSsidRemove.service.toString());
                    widget.wifiRemoveChar
                        .write(wifiSsidRemove.writeToBuffer())
                        .then((value) {});
                  }
                });
              });
            });
          } else {
            // Connect to new WiFi Network
            wifiConnectionStatusStreamController.add("Connecting...");
            widget.wifiConnectChar
                .write(wifiCredentials.writeToBuffer())
                .then((value) {
              print("WiFi Connect Char Result: " + value.toString());

              // Wait for connection result
              StreamSubscription<String> subscription;
              subscription =
                  wifiConnectionStatusStreamController.stream.listen((value) {
                if (value == "Failed") {
                  subscription.cancel();
                  // Remove WiFi Network After Failure
                  var wifiSsidRemove = protos.wifi_remove_v1.create();
                  wifiSsidRemove.service = widget.wifiNetworkSelected;
                  print("network to remove after failure 4: " +
                      wifiSsidRemove.service.toString());
                  widget.wifiRemoveChar
                      .write(wifiSsidRemove.writeToBuffer())
                      .then((value) {});
                }
              });
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to Network"),
        actions: <Widget>[],
      ),
      body: Column(children: <Widget>[
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10.0, left: 30.0, right: 30.0),
            child: ListTile(
              title: Text(widget.wifiNetworkSelected),
              leading: StreamBuilder<bool>(
                  stream: wifiConnectionSuccessStreamController.stream,
                  initialData: false,
                  builder: (c, snapshot) {
                    if (snapshot.data == true) {
                      return Icon(Icons.check_circle);
                    } else {
                      return Icon(Icons.wifi_lock);
                    }
                  }),
              trailing: StreamBuilder<String>(
                  stream: wifiConnectionStatusStreamController.stream,
                  initialData: "",
                  builder: (c, snapshot) {
                    return Text(snapshot.data);
                  }),
            )),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10.0, left: 40.0, right: 40.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter Wi-Fi Password Here',
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    // Update the state i.e. toggle the state of password Visible variable
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              controller: passwordController,
              obscureText: _obscureText,
            )),
        StreamBuilder<List<int>>(
            stream: widget.wifiSsidChar.value,
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              if (snapshot.hasData) {
                print("WiFi SSID: " + new String.fromCharCodes(snapshot.data));
                return Container();
              } else
                return Container();
            }),
        StreamBuilder<List<int>>(
            stream: widget.wifiConnectChar.value,
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              if (snapshot.hasData) {
                print(
                    "WiFi Connect: " + new String.fromCharCodes(snapshot.data));
                if ("connected" == new String.fromCharCodes(snapshot.data) &&
                    _seenConnecting) {
                  wifiConnectionStatusStreamController.add("Connected");
                  wifiConnectionSuccessStreamController.add(true);
                  _seenConnecting = false;
                } else if ("not_found" ==
                        new String.fromCharCodes(snapshot.data) ||
                    "error" == new String.fromCharCodes(snapshot.data) ||
                    "failed" == new String.fromCharCodes(snapshot.data) ||
                    "invalid" == new String.fromCharCodes(snapshot.data)) {
                  wifiConnectionStatusStreamController.add("Failed");
                  wifiConnectionSuccessStreamController.add(false);
                } else if ("connecting" ==
                    new String.fromCharCodes(snapshot.data)) {
                  _seenConnecting = true;
                }
                return Container();
              } else
                return Container();
            }),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10.0, left: 40.0, right: 40.0),
            child: RaisedButton(
                onPressed: () => _writeWifiCredentials(passwordController.text),
                child: Text(
                  "Connect",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button
                      .copyWith(color: Colors.black),
                ))),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10.0, left: 40.0, right: 40.0),
            child: RaisedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text(
                  "Back to Hotspots",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button
                      .copyWith(color: Colors.black),
                )))
      ]),
    );
  }
}
