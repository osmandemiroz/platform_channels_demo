import 'package:flutter/material.dart';
import 'method_channel_screen.dart';
import 'event_channel_screen.dart';
import 'basic_message_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Native Bridge',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Native Bridge',
                              applicationVersion: '1.0.0',
                              applicationIcon: const FlutterLogo(size: 40),
                              applicationLegalese:
                                  '© 2023 Native Bridge\nA Flutter Platform Channels Showcase',
                              children: [
                                const SizedBox(height: 16),
                                const Text(
                                  'This app demonstrates the implementation of Flutter Platform Channels for communication with native code on Android and iOS.',
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore Flutter-Native Communication',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Channel Options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Method Channel Card
                      _buildChannelCard(
                        context,
                        title: 'Method Channel',
                        description:
                            'Call native methods from Flutter and receive results asynchronously',
                        icon: Icons.call_made_rounded,
                        iconColor: const Color(0xFF407BFF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MethodChannelScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Event Channel Card
                      _buildChannelCard(
                        context,
                        title: 'Event Channel',
                        description:
                            'Receive continuous streams of data from the native platform',
                        icon: Icons.stream_rounded,
                        iconColor: const Color(0xFF3ECF8E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EventChannelScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Basic Message Channel Card
                      _buildChannelCard(
                        context,
                        title: 'Basic Message Channel',
                        description:
                            'Simple message passing between Flutter and native platforms',
                        icon: Icons.message_rounded,
                        iconColor: const Color(0xFFF57C00),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BasicMessageScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Additional Info
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            const Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Color(0xFFFFB300),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'About Platform Channels',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Platform channels enable Flutter to communicate with native code on iOS and Android. They are essential for accessing device capabilities not available in Flutter\'s standard APIs.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.code,
                                  size: 18,
                                  color: Color(0xFF407BFF),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Check out the source code',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFFBBBBBB),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
