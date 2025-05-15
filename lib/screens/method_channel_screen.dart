import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_back_button.dart';
import '../widgets/feature_card.dart';
import '../widgets/result_display.dart';
import '../channels/method_channel_handler.dart';

class MethodChannelScreen extends StatefulWidget {
  const MethodChannelScreen({super.key});

  @override
  State<MethodChannelScreen> createState() => _MethodChannelScreenState();
}

class _MethodChannelScreenState extends State<MethodChannelScreen>
    with SingleTickerProviderStateMixin {
  late MethodChannelHandler _methodHandler;
  final Map<String, dynamic> _results = {
    'batteryLevel': null,
    'deviceInfo': null,
    'calculation': null,
  };
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _methodHandler = MethodChannelHandler();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getBatteryLevel() async {
    setState(() => _isLoading = true);
    try {
      final batteryLevel = await _methodHandler.getBatteryLevel();
      setState(() {
        _results['batteryLevel'] = batteryLevel;
      });
    } on PlatformException catch (e) {
      setState(() {
        _results['batteryLevel'] = 'Error: ${e.message}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getDeviceInfo() async {
    setState(() => _isLoading = true);
    try {
      final deviceInfo = await _methodHandler.getDeviceInfo();
      setState(() {
        _results['deviceInfo'] = deviceInfo;
      });
    } on PlatformException catch (e) {
      setState(() {
        _results['deviceInfo'] = 'Error: ${e.message}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateSum() async {
    setState(() => _isLoading = true);
    try {
      // Using a and b as 42 and 24 for a nice demo
      final result = await _methodHandler.calculateSum(42, 24);
      setState(() {
        _results['calculation'] = 'Sum: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _results['calculation'] = 'Error: ${e.message}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Method Channel'),
        leading: const AppBackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              const Text(
                'Method channels allow Flutter to call platform-specific methods and receive results asynchronously.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF767676),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Feature Cards
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Battery Level Card
                      FeatureCard(
                        title: 'Battery Level',
                        description:
                            'Gets the current battery level using native APIs',
                        icon: Icons.battery_full_rounded,
                        iconColor: const Color(0xFF407BFF),
                        onActionPressed: _isLoading ? null : _getBatteryLevel,
                        actionText: 'Get Battery Level',
                        resultWidget: ResultDisplay(
                          value:
                              _results['batteryLevel'] != null
                                  ? '${_results['batteryLevel']}%'
                                  : 'Press the button to get battery level',
                          isLoading:
                              _isLoading && _results['batteryLevel'] == null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Device Info Card
                      FeatureCard(
                        title: 'Device Information',
                        description:
                            'Retrieves device details from the native platform',
                        icon: Icons.phone_android_rounded,
                        iconColor: const Color(0xFF3ECF8E),
                        onActionPressed: _isLoading ? null : _getDeviceInfo,
                        actionText: 'Get Device Info',
                        resultWidget: ResultDisplay(
                          value:
                              _results['deviceInfo'] ??
                              'Press the button to get device info',
                          isLoading:
                              _isLoading && _results['deviceInfo'] == null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Calculation Card
                      FeatureCard(
                        title: 'Native Calculation',
                        description:
                            'Computes a sum on the native side (42 + 24)',
                        icon: Icons.calculate_rounded,
                        iconColor: const Color(0xFFE91E63),
                        onActionPressed: _isLoading ? null : _calculateSum,
                        actionText: 'Calculate Sum',
                        resultWidget: ResultDisplay(
                          value:
                              _results['calculation'] ??
                              'Press the button to calculate',
                          isLoading:
                              _isLoading && _results['calculation'] == null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Code Reference
              Container(
                margin: const EdgeInsets.only(top: 20),
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
                        'const methodChannel = MethodChannel("com.example.native_bridge/methods");',
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
}
