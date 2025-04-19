import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '';
  bool _isResultCalculated = false; // Flag to check if result has been calculated
  final int _maxInputLength = 15; // Max character limit for input

  void _onPressed(String value) {
    setState(() {
      if (_isResultCalculated) {
        // If result is already calculated, reset input and use result as the new input
        if (value == 'AC') {
          _input = '';
          _result = '';
          _isResultCalculated = false; // Reset flag when 'AC' is pressed
        } else if (value == '=') {
          return; // Do nothing if '=' is pressed when the result is already calculated
        } else {
          // Use the current result as the new input when an operator is pressed
          _input = _result + value;
          _result = '';
          _isResultCalculated = false; // Allow further input after calculation
        }
      } else {
        if (value == 'AC') {
          _input = '';
          _result = '';
        } else if (value == '=') {
          try {
            _result = _calculateResult(_input);
            _isResultCalculated = true; // Mark result as calculated
          } catch (e) {
            _result = 'Error';
            _isResultCalculated = true; // Keep the result as 'Error' and lock input
          }
        } else if (value == '+/-') {
          if (_input.isNotEmpty) {
            if (_input[0] == '-') {
              // If the input starts with a minus sign, remove it (make it positive)
              _input = _input.substring(1);
            } else {
              // If the input doesn't start with a minus sign, add one (make it negative)
              _input = '-' + _input;
            }
          }
        } else {
          if (_input.length < _maxInputLength) {
            // Prevent adding multiple decimal points in the same number
            if (value == ',' && !_input.contains(',')) {
              _input += ',';
            } else if (value != ',') {
              _input += value;
            }
          }
        }
      }
    });
  }

  // Helper method to evaluate mathematical expressions
  String _calculateResult(String input) {
    // We replace '×' with '*' and '÷' with '/' for compatibility
    final expression = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(',', '.') // Convert comma to dot for calculation
        .replaceAll(' ', ''); // Remove any spaces from input

    try {
      final result = _evaluateExpression(expression);

      // Check if the result should be displayed in scientific notation
      if (result.abs() >= 1e6 || result.abs() <= 1e-6) {
        // Convert to scientific notation and remove '+' sign
        return result.toStringAsExponential(0).replaceAll('e+', 'e');
      }

      return result.toString();
    } catch (e) {
      return 'Error';
    }
  }

  // Evaluating the expression using dart:core
  double _evaluateExpression(String expression) {
    // Handle cases where there is a negative number at the beginning
    if (expression[0] == '-') {
      expression = '0' + expression; // Add 0 before negative number (e.g. "-5" becomes "0-5")
    }

    // Replace '--' with '+' for correct handling of double negatives (e.g., --5 => +5)
    expression = expression.replaceAll('--', '+');

    // Add spaces around operators to help split the expression
    expression = expression.replaceAll(RegExp(r'(?<=\d)(?=[^\d\s])'), ' ').replaceAll(RegExp(r'(?<=\D)(?=\d)'), ' ');

    final components = expression.split(' ').where((e) => e.isNotEmpty).toList();

    double result = 0.0;
    String operator = '+';

    for (var component in components) {
      if (component == '+' || component == '-') {
        operator = component; // Set the operator for the next number
      } else if (component == '*' || component == '/') {
        operator = component; // Set multiplication or division operator
      } else {
        double number = double.parse(component);

        // Perform calculation based on the current operator
        if (operator == '+') {
          result += number;
        } else if (operator == '-') {
          result -= number;
        } else if (operator == '*') {
          result *= number;
        } else if (operator == '/') {
          if (number == 0) {
            throw Exception('Cannot divide by zero');
          }
          result /= number;
        }
      }
    }

    return result;
  }

  // Updated _buildRoundButton method with 'isNumber' parameter
  Widget _buildRoundButton(String text, {Color? color, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 88,
        height: 88,
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: isNumber ? const Color.fromARGB(255, 63, 63, 63) : (color ?? const Color(0xFF007AFF)), // Gray background for numbers
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 31, // Increased font size by 3px
              color: Colors.white, // White text color for all buttons
            ),
          ),
        ),
      ),
    );
  }

  // Updated _buildWideButton method with 'isNumber' parameter
  Widget _buildWideButton(String text, {Color? color, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 188,
        height: 88,
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: isNumber ? const Color.fromARGB(255, 63, 63, 63) : (color ?? const Color(0xFF007AFF)), // Gray background for numbers
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 31, // Increased font size by 3px
              color: Colors.white, // White text color for all buttons
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adjust font size based on the length of the input
    double fontSize = 48; // Base font size
    if (_input.length > 10) {
      fontSize = 42; // Slightly smaller font size after 10 characters
    }
    if (_input.length > 12) {
      fontSize = 38; // Slightly smaller font size after 12 characters
    }
    if (_input.length > 14) {
      fontSize = 36; // Limit font size to 36 after 14 characters (minimum size)
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_isResultCalculated) return; // Don't allow editing after result
                  setState(() {
                    if (_input.isNotEmpty) {
                      _input = _input.substring(0, _input.length - 1); // Delete the last character
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
                      Text(
                        _input, // Keep commas in the input display
                        style: TextStyle(
                          fontSize: fontSize, // Adjusted font size
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result,
                        style: const TextStyle(
                            fontSize: 52, color: Colors.greenAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Buttons
            _buildRow([
              _buildWideButton('AC', isNumber: false),
              _buildRoundButton('+/-', isNumber: false),
              const SizedBox(width: 12),
              _buildRoundButton('÷', isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton('7', isNumber: true),
              _buildRoundButton('8', isNumber: true),
              _buildRoundButton('9', isNumber: true),
              const SizedBox(width: 12),
              _buildRoundButton('×', isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton('4', isNumber: true),
              _buildRoundButton('5', isNumber: true),
              _buildRoundButton('6', isNumber: true),
              const SizedBox(width: 12),
              _buildRoundButton('-', isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton('1', isNumber: true),
              _buildRoundButton('2', isNumber: true),
              _buildRoundButton('3', isNumber: true),
              const SizedBox(width: 12),
              _buildRoundButton('+', isNumber: false),
            ]),
            _buildRow([
              _buildWideButton('0', isNumber: true),
              _buildRoundButton(',', isNumber: true), // Allow comma as input
              const SizedBox(width: 12),
              _buildRoundButton('=', color: Colors.orange, isNumber: false),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
