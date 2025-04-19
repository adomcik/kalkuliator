import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '';
  bool _isResultCalculated = false;
  final int _maxInputLength = 15;

  void _onPressed(String value) {
    setState(() {
      if (_isResultCalculated) {
        if (value == 'AC') {
          _input = '';
          _result = '';
          _isResultCalculated = false;
        } else if (value == '=') {
          return;
        } else {
          _input = _result + value;
          _result = '';
          _isResultCalculated = false;
        }
      } else {
        if (value == 'AC') {
          _input = '';
          _result = '';
        } else if (value == '=') {
          try {
            _result = _calculateResult(_input);
            _isResultCalculated = true;
          } catch (e) {
            _result = 'Error';
            _isResultCalculated = true;
          }
        } else if (value == '+/-') {
          if (_input.isNotEmpty) {
            if (_input[0] == '-') {
              _input = _input.substring(1);
            } else {
              _input = '-$_input';
            }
          }
        } else {
          if (_input.length < _maxInputLength) {
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

String _calculateResult(String input) {
  final expression = input
      .replaceAll('×', '*')
      .replaceAll('÷', '/')
      .replaceAll(',', '.')
      .replaceAll(' ', '');

  try {
    final result = _evaluateExpression(expression);

    if (result == 0) {
      return '0';
    }

    if (result.abs() >= 1e6 || result.abs() <= 1e-6) {
      return result.toStringAsExponential(2).replaceAll('e+', 'e');
    }

    // If it's a whole number, remove the .0
    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    }

    return result.toString();
  } catch (e) {
    return 'Error';
  }
}



  double _evaluateExpression(String expression) {
    if (expression[0] == '-') {
      expression = '0$expression';
    }
    expression = expression.replaceAll('--', '+');
    expression = expression.replaceAll(RegExp(r'(?<=\d)(?=[^\d\s])'), ' ').replaceAll(RegExp(r'(?<=\D)(?=\d)'), ' ');

    final components = expression.split(' ').where((e) => e.isNotEmpty).toList();

    double result = 0.0;
    String operator = '+';

    for (var component in components) {
      if (component == '+' || component == '-') {
        operator = component;
      } else if (component == '*' || component == '/') {
        operator = component;
      } else {
        double number = double.parse(component);

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

  Widget _buildRoundButton(String text, {Color? color, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        width: 80,
        height: 80,
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: isNumber ? const Color.fromARGB(255, 63, 63, 63) : (color ?? const Color(0xFF007AFF)),
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideButton(String text, {Color? color, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        width: 172,
        height: 80,
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: isNumber ? const Color.fromARGB(255, 63, 63, 63) : (color ?? const Color(0xFF007AFF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
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
    double fontSize = 48;
    if (_input.length > 10) fontSize = 42;
    if (_input.length > 12) fontSize = 38;
    if (_input.length > 14) fontSize = 32;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
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
                      Text(
                        _input,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result,
                        style: const TextStyle(fontSize: 52, color: Colors.greenAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildRow([
              _buildWideButton('AC', isNumber: false),
              _buildRoundButton('+/-', isNumber: false),
              const SizedBox(width: 8),
              _buildRoundButton('÷', isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton('7', isNumber: true),
              _buildRoundButton('8', isNumber: true),
              _buildRoundButton('9', isNumber: true),
              const SizedBox(width: 8),
              _buildRoundButton('×', isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton('4', isNumber: true),
              _buildRoundButton('5', isNumber: true),
              _buildRoundButton('6', isNumber: true),
              const SizedBox(width: 8),
              _buildRoundButton('-', isNumber: false),
            ]),
            _buildRow([
              _buildRoundButton('1', isNumber: true),
              _buildRoundButton('2', isNumber: true),
              _buildRoundButton('3', isNumber: true),
              const SizedBox(width: 8),
              _buildRoundButton('+', isNumber: false),
            ]),
            _buildRow([
              _buildWideButton('0', isNumber: true),
              _buildRoundButton(',', isNumber: true),
              const SizedBox(width: 8),
              _buildRoundButton('=', color: Colors.orange, isNumber: false),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
