import 'package:flutter/services.dart';

Future<void> testChannel() async {
  const channel = MethodChannel('com.freespace.native');
  print('Current root: ${await channel.invokeMethod('getScanRootPath')}');
  await channel.invokeMethod('setScanRoot', {'path': '/Users/aryanraj/Downloads'});
  print('New root: ${await channel.invokeMethod('getScanRootPath')}');
}
