// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:platform_channels_demo/channels/method_channel_handler.dart';
import 'package:platform_channels_demo/widgets/app_back_button.dart';
import 'package:platform_channels_demo/widgets/feature_card.dart';
import 'package:platform_channels_demo/widgets/result_display.dart';

class MethodChannelScreen extends StatefulWidget {
  const MethodChannelScreen({super.key});

  @override
  State<MethodChannelScreen> createState() => _MethodChannelScreenState();
}

class _MethodChannelScreenState extends State<MethodChannelScreen>
    with SingleTickerProviderStateMixin {
  final MethodChannelHandler _methodHandler = MethodChannelHandler();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  // Use specific types for each result
  String? _batteryLevelResult;
  String? _deviceInfoResult;
  String? _calculationResult;

  @override
  void initState() {
    super.initState();

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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getBatteryLevel() async {
    setState(() => _isLoading = true);
    try {
      final batteryLevel = await _methodHandler.getBatteryLevel();
      setState(() {
        _batteryLevelResult = '$batteryLevel%';
      });
    } on PlatformException catch (e) {
      setState(() {
        _batteryLevelResult = 'Error: ${e.message}';
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
        _deviceInfoResult = deviceInfo;
      });
    } on PlatformException catch (e) {
      setState(() {
        _deviceInfoResult = 'Error: ${e.message}';
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
        _calculationResult = 'Sum: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _calculationResult = 'Error: ${e.message}';
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
          padding: const EdgeInsets.all(20),
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
                              _batteryLevelResult ??
                              'Press the button to get battery level',
                          isLoading: _isLoading && _batteryLevelResult == null,
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
                              _deviceInfoResult ??
                              'Press the button to get device info',
                          isLoading: _isLoading && _deviceInfoResult == null,
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
                              _calculationResult ??
                              'Press the button to calculate',
                          isLoading: _isLoading && _calculationResult == null,
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
