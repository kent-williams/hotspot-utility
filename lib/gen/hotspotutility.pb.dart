///
//  Generated code. Do not modify.
//  source: hotspotutility.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class wifi_services_v1 extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('wifi_services_v1', createEmptyInstance: create)
    ..pPS(1, 'services')
    ..hasRequiredFields = false
  ;

  wifi_services_v1._() : super();
  factory wifi_services_v1() => create();
  factory wifi_services_v1.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory wifi_services_v1.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  wifi_services_v1 clone() => wifi_services_v1()..mergeFromMessage(this);
  wifi_services_v1 copyWith(void Function(wifi_services_v1) updates) => super.copyWith((message) => updates(message as wifi_services_v1));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static wifi_services_v1 create() => wifi_services_v1._();
  wifi_services_v1 createEmptyInstance() => create();
  static $pb.PbList<wifi_services_v1> createRepeated() => $pb.PbList<wifi_services_v1>();
  @$core.pragma('dart2js:noInline')
  static wifi_services_v1 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<wifi_services_v1>(create);
  static wifi_services_v1 _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get services => $_getList(0);
}

class wifi_connect_v1 extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('wifi_connect_v1', createEmptyInstance: create)
    ..aOS(1, 'service')
    ..aOS(2, 'password')
    ..hasRequiredFields = false
  ;

  wifi_connect_v1._() : super();
  factory wifi_connect_v1() => create();
  factory wifi_connect_v1.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory wifi_connect_v1.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  wifi_connect_v1 clone() => wifi_connect_v1()..mergeFromMessage(this);
  wifi_connect_v1 copyWith(void Function(wifi_connect_v1) updates) => super.copyWith((message) => updates(message as wifi_connect_v1));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static wifi_connect_v1 create() => wifi_connect_v1._();
  wifi_connect_v1 createEmptyInstance() => create();
  static $pb.PbList<wifi_connect_v1> createRepeated() => $pb.PbList<wifi_connect_v1>();
  @$core.pragma('dart2js:noInline')
  static wifi_connect_v1 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<wifi_connect_v1>(create);
  static wifi_connect_v1 _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get service => $_getSZ(0);
  @$pb.TagNumber(1)
  set service($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasService() => $_has(0);
  @$pb.TagNumber(1)
  void clearService() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => clearField(2);
}

class wifi_remove_v1 extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('wifi_remove_v1', createEmptyInstance: create)
    ..aOS(1, 'service')
    ..hasRequiredFields = false
  ;

  wifi_remove_v1._() : super();
  factory wifi_remove_v1() => create();
  factory wifi_remove_v1.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory wifi_remove_v1.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  wifi_remove_v1 clone() => wifi_remove_v1()..mergeFromMessage(this);
  wifi_remove_v1 copyWith(void Function(wifi_remove_v1) updates) => super.copyWith((message) => updates(message as wifi_remove_v1));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static wifi_remove_v1 create() => wifi_remove_v1._();
  wifi_remove_v1 createEmptyInstance() => create();
  static $pb.PbList<wifi_remove_v1> createRepeated() => $pb.PbList<wifi_remove_v1>();
  @$core.pragma('dart2js:noInline')
  static wifi_remove_v1 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<wifi_remove_v1>(create);
  static wifi_remove_v1 _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get service => $_getSZ(0);
  @$pb.TagNumber(1)
  set service($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasService() => $_has(0);
  @$pb.TagNumber(1)
  void clearService() => clearField(1);
}

