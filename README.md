# Hotspot Utility

Unofficial Helium Hotspot Utility Mobile App for iOS and Android built with Flutter

[iOS - App Store](https://apps.apple.com/us/app/helium-hotspot-utility/id1527367455)  
[Android - Play Store](https://play.google.com/store/apps/details?id=com.kentwilliams.hotspotutility)

## Development Environment

[Flutter Getting Started](https://flutter.dev/docs/get-started/install)

## Generate Protobuf

### Windows - Android Studio
* Download compiled release of protoc [here](https://github.com/protocolbuffers/protobuf/releases) (add bin to path)
* Clone https://github.com/dart-lang/protobuf
* run `flutter pub pub install` inside protobuf/protoc_plugin
* run `pub pub global activate protoc_plugin` to get .dart files into C:\Users\{User}\AppData\Roaming\Pub\Cache\bin (move files from here to protoc bin dir)
* Install dart-sdk `choco install dart-sdk`
* cd protos
* run `protoc --dart_out=..\lib\gen .\hotspotutility.proto`
* run `protoc --objc_out=..\ios\gen .\hotspotutility.proto`
