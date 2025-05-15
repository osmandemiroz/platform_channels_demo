// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/services.dart';

/// Handles receiving event streams from the native platform.
class EventChannelHandler {
  /// The event channel used for receiving data streams from the native platform.
  static const EventChannel _eventChannel = EventChannel(
    'com.example.native_bridge/events',
  );

  /// Gets a stream of events from the platform.
  ///
  /// Returns a broadcast stream that can be listened to multiple times.
  /// Events typically contain a map with 'type', 'value', and 'timestamp' keys.
  Stream<dynamic> get eventStream => _eventChannel.receiveBroadcastStream();

  /// Converts the raw event stream to a more specific type if needed.
  ///
  /// This is useful when you know the structure of the events and want
  /// to provide a typed API for consuming code.
  Stream<Map<dynamic, dynamic>> get typedEventStream =>
      eventStream.map((event) => event as Map<dynamic, dynamic>);
}
