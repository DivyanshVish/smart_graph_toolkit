
import 'package:flutter/services.dart';

class SmartGraphToolkit {
  final methodChannel = const MethodChannel('smart_graph_toolkit');

  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
