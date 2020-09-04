import 'dart:async';

import 'package:flutter/services.dart';

class Tacsflutter {
  static const MethodChannel _channel = const MethodChannel('tacsflutter');

  static Future<bool> buildKeyring() async {
    final bool keyringBuilt = await _channel.invokeMethod('buildKeyring');
    return keyringBuilt;
  }
}
