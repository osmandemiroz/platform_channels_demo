// Flutter imports:
import 'package:flutter/services.dart';

/// Handles communication with the platform through method channels.
class MethodChannelHandler {
  /// The method channel used for communication with the native platform.
  static const MethodChannel _methodChannel = MethodChannel(
    'com.example.native_bridge/methods',
  );

  /// Gets the battery level from the platform.
  ///
  /// Returns the battery level as an integer percentage.
  /// Throws [PlatformException] if the method is not implemented or fails.
  Future<int> getBatteryLevel() async {
    try {
      final result = await _methodChannel.invokeMethod('getBatteryLevel');
      return result as int;
    } on PlatformException {
      rethrow;
    }
  }

  /// Gets device information from the platform.
  ///
  /// Returns a string with device details.
  /// Throws [PlatformException] if the method is not implemented or fails.
  Future<String> getDeviceInfo() async {
    try {
      final result = await _methodChannel.invokeMethod('getDeviceInfo');
      return result as String;
    } on PlatformException {
      rethrow;
    }
  }

  /// Calculates the sum of two integers on the platform side.
  ///
  /// Returns the sum as an integer.
  /// Throws [PlatformException] if the method is not implemented or fails.
  Future<int> calculateSum(int a, int b) async {
    try {
      final result = await _methodChannel.invokeMethod('computeSum', {
        'a': a,
        'b': b,
      });
      return result as int;
    } on PlatformException {
      rethrow;
    }
  }
}
