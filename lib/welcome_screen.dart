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

    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    double headingFontSize = (screenWidth * 0.0715).clamp(0, 30);
    double featureTitleFontSize = (screenWidth * 0.045).clamp(0, 18);
    double featureSubFontSize = (screenWidth * 0.032).clamp(0, 13);
    double buttonFontSize = (screenWidth * 0.045).clamp(0, 18);
    double buttonPadding = (screenHeight * 0.018).clamp(0, 16);

    final headingStyle = TextStyle(
      fontSize: headingFontSize,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : Colors.black,
    );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF007AFF),
      padding: EdgeInsets.symmetric(vertical: buttonPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            top: screenHeight * 0.085,
            bottom: screenHeight * 0.03,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Image.asset('assets/icon.png', width: 72, height: 72),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Welcome to Kalkuliator',
                    style: headingStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.08),
                    _buildFeatureRow(
                      icon: Icons.calculate,
                      title: 'Elegant and simple design',
                      subtext: 'Easy to use calculator with an elegant design.',
                      isDarkMode: isDarkMode,
                      titleFontSize: featureTitleFontSize,
                      subFontSize: featureSubFontSize,
                      maxWidth: screenWidth * 0.75,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    _buildFeatureRow(
                      icon: Icons.volume_up,
                      title: 'Toggleable sound effects',
                      subtext: 'Buttons give instant audio feedback.',
                      isDarkMode: isDarkMode,
                      titleFontSize: featureTitleFontSize,
                      subFontSize: featureSubFontSize,
                      maxWidth: screenWidth * 0.75,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    _buildFeatureRow(
                      icon: Icons.brightness_6,
                      title: 'Light and dark modes',
                      subtext:
                          'Automatically switches depending on your\nphone\'s settings.',
                      isDarkMode: isDarkMode,
                      titleFontSize: featureTitleFontSize,
                      subFontSize: featureSubFontSize,
                      maxWidth: screenWidth * 0.75,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                CalculatorScreen(
                                  themeMode: themeMode,
                                  onThemeChanged: onThemeChanged,
                                ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          );
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                    onContinue();
                  },
                  style: buttonStyle,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: buttonFontSize,
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
    required double titleFontSize,
    required double subFontSize,
    required double maxWidth,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: isDarkMode ? Colors.white : Colors.black),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: subFontSize,
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
