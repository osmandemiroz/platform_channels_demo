// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:platform_channels_demo/channels/event_channel_handler.dart';

class EventChannelScreen extends StatefulWidget {
  const EventChannelScreen({super.key});

  @override
  State<EventChannelScreen> createState() => _EventChannelScreenState();
}

class _EventChannelScreenState extends State<EventChannelScreen>
    with SingleTickerProviderStateMixin {
  late EventChannelHandler _eventHandler;
  StreamSubscription<dynamic>? _eventSubscription;
  List<EventData> _events = [];
  bool _isListening = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _eventHandler = EventChannelHandler();

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
    _stopListening();
    _animationController.dispose();
    super.dispose();
  }

  void _startListening() {
    if (_eventSubscription != null) return;

    setState(() {
      _isListening = true;
    });

    _eventSubscription = _eventHandler.eventStream.listen(
      (dynamic event) {
        // Convert the event to our EventData model
        final eventData = EventData.fromJson(event as Map<dynamic, dynamic>);

        setState(() {
          _events.insert(0, eventData);
          // Keep only last 20 events
          if (_events.length > 20) {
            _events = _events.sublist(0, 20);
          }
        });
      },
      onError: (dynamic error) {
        setState(() {
          _events.insert(
            0,
            EventData(
              type: 'ERROR',
              value: error.toString(),
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        });
      },
      onDone: () {
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  void _stopListening() {
    if (_eventSubscription == null) return;

    _eventSubscription?.cancel();
    _eventSubscription = null;

    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Event Channel'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                'Event channels allow Flutter to receive a stream of events from the native platform, such as sensor data or status updates.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF767676),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // Controls
              Container(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                _isListening
                                    ? const Color(0xFF3ECF8E).withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.stream_rounded,
                            color:
                                _isListening
                                    ? const Color(0xFF3ECF8E)
                                    : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isListening
                                    ? 'Listening to events'
                                    : 'Not listening',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isListening
                                    ? 'Receiving events from native platform'
                                    : 'Press start to begin receiving events',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isListening ? null : _startListening,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3ECF8E),
                              disabledBackgroundColor: const Color(
                                0xFF3ECF8E,
                              ).withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Start Listening'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isListening ? _stopListening : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              disabledBackgroundColor: Colors.redAccent
                                  .withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Stop Listening'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Events header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Received Events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  if (_events.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _events.clear();
                        });
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Events list
              Expanded(
                child:
                    _events.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.hourglass_empty_rounded,
                                size: 48,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No events received yet',
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isListening
                                    ? 'Events will appear here as they arrive'
                                    : 'Press "Start Listening" to begin',
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: _events.length,
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final event = _events[index];
                            return _buildEventCard(event);
                          },
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
                        'eventChannel.receiveBroadcastStream().listen((event) { ... })',
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

  Widget _buildEventCard(EventData event) {
    final typeColor = _getEventTypeColor(event.type);
    final formattedTime = _formatTimestamp(event.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  event.type,
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formattedTime,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Value: ${event.value}', style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SENSOR_DATA':
      case 'ACCELEROMETER':
        return const Color(0xFF407BFF);
      case 'BATTERY_UPDATE':
      case 'GYROSCOPE':
        return const Color(0xFF3ECF8E);
      case 'LOCATION_UPDATE':
      case 'PROXIMITY':
        return const Color(0xFFF57C00);
      case 'ERROR':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    final seconds = dateTime.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class EventData {
  EventData({required this.type, required this.value, required this.timestamp});

  factory EventData.fromJson(Map<dynamic, dynamic> json) {
    return EventData(
      type: json['type'] as String,
      value: json['value'],
      timestamp: json['timestamp'] as int,
    );
  }
  final String type;
  final dynamic value;
  final int timestamp;
}
