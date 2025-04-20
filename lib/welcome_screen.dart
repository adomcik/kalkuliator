import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const WelcomeScreen({
    super.key,
    required this.onContinue,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Set system UI overlay style for status bar icons
    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light // White icons for dark background
          : SystemUiOverlayStyle.dark, // Dark icons for light background
    );

    // TextStyle and buttonStyle constants to avoid repetition
    final headingStyle = TextStyle(
      fontSize: 30, // Increased by 5 px
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : Colors.black,
    );



    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF007AFF),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),  // More rounded button
      ),
    );

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 68.0, bottom: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Top content (Welcome message and icon)
              Column(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 100,
                    color: const Color(0xFF007AFF),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Kalkuliator',
                    style: headingStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your sleek and simple calculator is ready to go.',
                    style: isDarkMode
                        ? TextStyle(fontSize: 16, color: Colors.white70)
                        : TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Move only the bullet points section to the right
              Padding(
                padding: const EdgeInsets.only(left: 0.0), // Adjust only the bullet points' padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align all to the left
                  children: [
                    const SizedBox(height: 65), // Increase space between bullet points
                    _buildFeatureRow(
                      icon: Icons.calculate, // Math icon
                      title: 'Elegant and simple design.',
                      subtext: 'Easy to use calculator with a elegant design.',
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 40), // Increase space between bullet points
                    _buildFeatureRow(
                      icon: Icons.volume_up,
                      title: 'Sound effects',
                      subtext: 'Hear the buttons make a calm and soothing sound!',
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 40), // Increase space between bullet points
                    _buildFeatureRow(
                      icon: Icons.brightness_6,
                      title: 'Light and Dark mode',
                      subtext: 'Automatically switches depending on your settings.',
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
              const Spacer(), // Spacer to push the button to the bottom
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) => CalculatorScreen(
                          themeMode: themeMode,
                          onThemeChanged: onThemeChanged,
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                    onContinue(); // Call the provided callback
                  },
                  style: buttonStyle,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtext,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18, // Increased by 2 px
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
