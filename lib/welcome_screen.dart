import 'package:flutter/material.dart';
import 'calculator_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key}); // Fix here, passing key to super()

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 0, 0, 0) : Colors.white, // White background in light mode, iOS blue in dark mode
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              Column(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 100,
                    color: isDarkMode ? Color(0xFF007AFF) : Color(0xFF007AFF), // Icon color for light/dark mode
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Kalkuliator', // Changed from 'CalcMate' to 'Kalkuliator'
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black, // Black text in light mode
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your sleek and simple calculator is ready to go.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54, // Dark text in light mode
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => CalculatorScreen()), // Remove 'const'
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF007AFF), // iOS blue button background
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
}
