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
      StreamController<String>();
  StreamController<bool> wifiConnectionSuccessStreamController =
      StreamController<bool>();

  @override
  void dispose() {
    super.dispose();
    wifiConnectionStatusStreamController.close();
    wifiConnectionSuccessStreamController.close();
  }

  @protected
  @mustCallSuper
  void initState() {
    wifiConnectionStatusStreamController.add('');
    wifiConnectionSuccessStreamController.add(false);
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

    if (widget.currentWifiSsid != "" || widget.currentWifiSsid != null) {
      wifiSsidRemove.service = widget.currentWifiSsid;
      await widget.wifiRemoveChar.write(wifiSsidRemove.writeToBuffer());
    }

    if (widget.wifiConfiguredServices.length > 0) {
      wifiSsidRemove.service = widget.wifiConfiguredServices[0];
      await widget.wifiRemoveChar.write(wifiSsidRemove.writeToBuffer());
    }

    await widget.wifiConnectChar.write(wifiCredentials.writeToBuffer());
    wifiConnectionStatusStreamController.add("Connecting...");
  }

  Widget _buildSsidValue() {
    if (widget.wifiSsidChar != null) {
      return StreamBuilder<List<int>>(
          stream: widget.wifiSsidChar.value,
          builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.hasData) {
              if (widget.wifiNetworkSelected ==
                  new String.fromCharCodes(snapshot.data)) {
                wifiConnectionStatusStreamController.add("Connected");
                wifiConnectionSuccessStreamController.add(true);
              } else if (new String.fromCharCodes(snapshot.data) != "") {
                wifiConnectionStatusStreamController.add("Not Connected");
              }
              return Container();
            } else
              return Container();
          });
    } else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to Network"),
        actions: <Widget>[],
      ),
      body: Column(children: <Widget>[
        ListTile(
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
        ),
        TextFormField(
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
                // Update the state i.e. toogle the state of passwordVisible variable
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          controller: passwordController,
          obscureText: _obscureText,
        ),
        FutureBuilder<bool>(
            future: widget.wifiSsidChar.setNotifyValue(true),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return Container();
            }),
        _buildSsidValue(),
        SizedBox(
            width: double.infinity,
            child: RaisedButton(
                onPressed: () => _writeWifiCredentials(passwordController.text),
                child: Text(
                  "Connect",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button
                      .copyWith(color: Colors.black),
                ))),
        SizedBox(
            width: double.infinity,
            child: RaisedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text(
                  "Back Home",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button
                      .copyWith(color: Colors.black),
                )))
      ]),
    );
  }
}
