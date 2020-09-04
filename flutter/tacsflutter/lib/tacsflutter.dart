import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class Tacsflutter {
  static const MethodChannel _channel = const MethodChannel('tacsflutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> buildKeyring(JsonDecoder json) async {
    final bool keyringBuilt = await _channel.invokeMethod('buildKeyring', json);
    return keyringBuilt;
  }

  static Future<bool> connect() async {
    final bool connect = await _channel.invokeMethod('connect');
    return connect;
  }

  static Future<bool> disconnect() async {
    final bool disconnect = await _channel.invokeMethod('disconnect');
    return disconnect;
  }

  static Future<bool> lock() async {
    final bool lock = await _channel.invokeMethod('lock');
    return lock;
  }

  static Future<bool> unlock() async {
    final bool unlock = await _channel.invokeMethod('unlock');
    return unlock;
  }

  static Future<bool> enableEngine() async {
    final bool enableEngine = await _channel.invokeMethod('enableEngine');
    return enableEngine;
  }

  static Future<bool> location() async {
    final bool location = await _channel.invokeMethod('location');
    return location;
  }

  static Future<bool> telematics() async {
    final bool telematics = await _channel.invokeMethod('telematics');
    return telematics;
  }

  static Future<bool> disableEngine() async {
    final bool disableEngine = await _channel.invokeMethod('disableEngine');
    return disableEngine;
  }
}
