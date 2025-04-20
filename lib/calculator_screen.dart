import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package
import 'dart:io'; // Add this import for platform detection
import 'package:flutter/cupertino.dart'; // Import Cupertino package
import 'package:math_expressions/math_expressions.dart'; // Import math_expressions package

class CalculatorScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) onThemeChanged;

  const CalculatorScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '';
  bool _isResultCalculated = false;
  bool _isSoundEnabled = false;
  final int _maxInputLength = 15;

  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize the audio player

  final List<String> _buttonLabels = [
    'AC', '+/-', '÷', '7', '8', '9', '×', '4', '5', '6', '-', '1', '2', '3', '+', '0', '.', '=',
  ];

  void _toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isSoundEnabled) {
      if (Platform.isAndroid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sound effects have been enabled, it\'s going to be loud for now!',
              style: TextStyle(color: isDark ? Colors.white : Colors.white), // Always white text
            ),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (Platform.isIOS) {
        showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Sound effects enabled'),
            content: const Text('It\'s going to be loud for now!'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } else {
      if (Platform.isAndroid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sound effects have been disabled, it\'s quiet for now.',
              style: TextStyle(color: isDark ? Colors.white : Colors.white), // Always white text
            ),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (Platform.isIOS) {
        showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Sound effects disabled'),
            content: const Text('No more sounds, it\'s quiet for now.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _playSound() async {
    if (_isSoundEnabled) {
      try {
        final player = AudioPlayer(); // Create a new instance for each sound
        await player.play(AssetSource('sounds/click.mp3'));
        // Optionally dispose the player after the sound finishes
        player.onPlayerComplete.listen((event) {
          player.dispose();
        });
      } catch (e) {
        // Handle error if needed
      }
    }
  }

  void _onPressed(String value) async {
    await _playSound(); // Play sound when a button is pressed
    setState(() {
      if (_isResultCalculated) {
        if (value == 'AC') {
          _input = '';
          _result = '';
          _isResultCalculated = false;
        } else if (value != '=') {
          _input = _result + value;
          _result = '';
          _isResultCalculated = false;
        }
      } else {
        switch (value) {
          case 'AC':
            _input = '';
            _result = '';
            break;
          case '=':
            try {
              _result = _calculateResult(_input);
              _isResultCalculated = true;
            } catch (e) {
              _result = 'Error';
              _isResultCalculated = true;
              print("Error calculating result: $e");
            }
            break;
          case '+/-':
            if (_input.isNotEmpty) {
              // Find the last operator (+, -, ×, ÷)
              final lastOp = _input.lastIndexOf(RegExp(r'[+\-×÷]'));
              String before = lastOp >= 0 ? _input.substring(0, lastOp + 1) : '';
              String number = lastOp >= 0 ? _input.substring(lastOp + 1) : _input;

              // Remove all leading '-' from number
              number = number.replaceFirst(RegExp(r'^-+'), '');

              // Toggle sign: add '-' if not present, remove if present
              if (number.isNotEmpty && !number.startsWith('-')) {
                number = '-$number';
              }
              _input = before + number;
            }
            break;
          case '.':
            if (!_input.contains('.')) _input += value;
            break;
          default:
            if (_input.length < _maxInputLength) _input += value;
            break;
        }
      }
    });
  }

  String _calculateResult(String input) {
    final expression = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(',', '.')
        .replaceAll(' ', '');

    if (expression.isEmpty) return 'Error';

    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
      return _formatResult(eval);
    } catch (e) {
      return 'Error';
    }
  }

  String _formatResult(double result) {
    if (result == 0) return '0';
    if (result.abs() >= 1e6 || result.abs() <= 1e-6) {
      return result.toStringAsExponential(2).replaceAll('e+', 'e');
    }

    String resultStr = result.toStringAsFixed(11).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return resultStr.length > 12 ? resultStr.substring(0, 12) : resultStr;
  }

  void _shuffleButtons() {
    setState(() {
      _buttonLabels.shuffle();
    });
  }

  Widget _buildRoundButton(String text, {Color? color, bool isNumber = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isNumber
        ? (isDark ? const Color(0xFF3F3F3F) : const Color(0xFF818181))
        : (color ?? const Color(0xFF007AFF));

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        width: 80,
        height: 80,
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Text(text, style: const TextStyle(fontSize: 30, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildWideButton(String text, {Color? color, bool isNumber = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isNumber
        ? (isDark ? const Color(0xFF3F3F3F) : const Color(0xFF818181))
        : (color ?? const Color(0xFF007AFF));

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        width: 172,
        height: 80,
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            padding: EdgeInsets.zero,
          ),
          child: Text(text, style: const TextStyle(fontSize: 30, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> buttons) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons);
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose of the audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    double fontSize = 48;
    if (_input.length > 10) fontSize = 42;
    if (_input.length > 12) fontSize = 38;
    if (_input.length > 14) fontSize = 32;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: IconButton(
                    icon: Icon(
                      _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                      size: 28,
                    ),
                    onPressed: _toggleSound,
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(top: 50, right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.shuffle, size: 28),
                    onPressed: _shuffleButtons,
                  ),
                ),
              ],
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_isResultCalculated) return;
                  setState(() {
                    if (_input.isNotEmpty) {
                      _input = _input.substring(0, _input.length - 1);
                    }
                  });
                },
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: _isResultCalculated ? 24 : fontSize,
                          color: _isResultCalculated
                              ? Colors.grey
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        child: Text(_input),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result,
                        style: TextStyle(
                          fontSize: 62,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildRow([
              _buildWideButton(_buttonLabels[0], isNumber: false),
              _buildRoundButton(_buttonLabels[1], isNumber: false),
              const SizedBox(width: 8),
              _buildRoundButton(_buttonLabels[2], isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton(_buttonLabels[3], isNumber: true),
              _buildRoundButton(_buttonLabels[4], isNumber: true),
              _buildRoundButton(_buttonLabels[5], isNumber: true),
              const SizedBox(width: 8),
              _buildRoundButton(_buttonLabels[6], isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton(_buttonLabels[7], isNumber: true),
              _buildRoundButton(_buttonLabels[8], isNumber: true),
              _buildRoundButton(_buttonLabels[9], isNumber: true),
              const SizedBox(width: 8),
              _buildRoundButton(_buttonLabels[10], isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton(_buttonLabels[11], isNumber: true),
              _buildRoundButton(_buttonLabels[12], isNumber: true),
              _buildRoundButton(_buttonLabels[13], isNumber: true),
              const SizedBox(width: 8),
              _buildRoundButton(_buttonLabels[14], isNumber: false),
            ]),
            _buildRow([
              _buildWideButton(_buttonLabels[15], isNumber: true),
              _buildRoundButton(_buttonLabels[16], isNumber: true),
              const SizedBox(width: 8),
              _buildRoundButton(_buttonLabels[17], color: Colors.orange, isNumber: false),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
