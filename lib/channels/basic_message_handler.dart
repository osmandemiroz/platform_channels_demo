import 'package:flutter/services.dart';

/// Function type for receiving messages from the platform.
typedef MessageReceiveHandler = void Function(String message);

/// Handles simple message passing between Flutter and the native platform.
class BasicMessageHandler {
  /// The basic message channel used for message passing with the native platform.
  static const BasicMessageChannel<dynamic> _messageChannel =
      BasicMessageChannel<dynamic>(
        'com.example.native_bridge/basic_messages',
        StandardMessageCodec(),
      );

  /// Default constructor
  BasicMessageHandler() {
    _setupMessageHandler();
  }

  /// Sets up a handler for incoming messages.
  void _setupMessageHandler() {
    _messageChannel.setMessageHandler((dynamic message) async {
      if (_onMessageReceived != null && message != null) {
        _onMessageReceived!(message.toString());
      }
      return 'Message received by Flutter';
    });
  }

  /// Function to be called when a message is received from the platform.
  MessageReceiveHandler? _onMessageReceived;

  /// Sets a handler function to be called when messages are received.
  void setMessageReceiveHandler(MessageReceiveHandler handler) {
    _onMessageReceived = handler;
  }

  /// Sends a message to the platform and returns the response.
  ///
  /// Throws an exception if the platform doesn't respond or returns an error.
  Future<String> sendMessage(String message) async {
    try {
      final dynamic response = await _messageChannel.send(message);
      return response?.toString() ?? 'No response';
    } catch (e) {
      rethrow;
    }
  }
}
