// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:platform_channels_demo/channels/basic_message_handler.dart';

class BasicMessageScreen extends StatefulWidget {
  const BasicMessageScreen({super.key});

  @override
  State<BasicMessageScreen> createState() => _BasicMessageScreenState();
}

class _BasicMessageScreenState extends State<BasicMessageScreen>
    with SingleTickerProviderStateMixin {
  late BasicMessageHandler _messageHandler;
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _response;
  bool _isSending = false;
  final List<MessageExchange> _messageHistory = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _messageHandler = BasicMessageHandler();
    _messageHandler.messageReceiveHandler = _onMessageReceived;

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onMessageReceived(String message) {
    setState(() {
      _response = message;
      // Add to history
      _messageHistory.insert(
        0,
        MessageExchange(
          message: 'Received: $message',
          isFromPlatform: true,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    final message = _messageController.text;

    setState(() {
      _isSending = true;
      // Add to history
      _messageHistory.insert(
        0,
        MessageExchange(
          message: 'Sent: $message',
          isFromPlatform: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    try {
      final response = await _messageHandler.sendMessage(message);
      setState(() {
        _response = response;
        // Add to history
        _messageHistory.insert(
          0,
          MessageExchange(
            message: 'Response: $response',
            isFromPlatform: true,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        // Add to history
        _messageHistory.insert(
          0,
          MessageExchange(
            message: 'Error: $e',
            isFromPlatform: true,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
      });
    } finally {
      setState(() {
        _isSending = false;
      });
      // Clear text field on success
      _messageController.clear();
    }
  }

  void _clearHistory() {
    setState(() {
      _messageHistory.clear();
      _response = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Basic Message Channel'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_messageHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearHistory,
              tooltip: 'Clear message history',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              const Text(
                'Basic message channels enable simple communication between Flutter and platform code using string or binary messages.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF767676),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Message Input
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message to send...',
                        prefixIcon: const Icon(
                          Icons.message_outlined,
                          color: Color(0xFFF57C00),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                      enabled: !_isSending,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isSending
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Send Message'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Response & History Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Latest response section
                      if (_response != null) ...[
                        const Text(
                          'Latest Response:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF57C00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _response!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Message History
                      const Text(
                        'Message History:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Expanded(
                        child:
                            _messageHistory.isEmpty
                                ? Center(
                                  child: Text(
                                    'No messages exchanged yet',
                                    style: TextStyle(
                                      color: Colors.grey.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: _messageHistory.length,
                                  padding: EdgeInsets.zero,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final exchange = _messageHistory[index];
                                    return _buildMessageBubble(exchange);
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),

              // Code Reference
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.code, size: 20, color: Color(0xFF407BFF)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'basicMessageChannel.send("Hello from Flutter");',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Menlo',
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageExchange exchange) {
    final bubbleColor =
        exchange.isFromPlatform
            ? exchange.isError
                ? Colors.red.shade50
                : const Color(0xFFEEF2FF)
            : const Color(0xFFF57C00).withOpacity(0.1);

    final textColor =
        exchange.isFromPlatform
            ? exchange.isError
                ? Colors.red.shade800
                : const Color(0xFF407BFF)
            : const Color(0xFFF57C00);

    final alignment =
        exchange.isFromPlatform
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end;

    final time = _formatTime(exchange.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(exchange.message, style: TextStyle(color: textColor)),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    final seconds = dateTime.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class MessageExchange {
  MessageExchange({
    required this.message,
    required this.isFromPlatform,
    required this.timestamp,
    this.isError = false,
  });
  final String message;
  final bool isFromPlatform;
  final DateTime timestamp;
  final bool isError;
}
