import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'welcome_screen.dart';

int _debugTapCounter = 0;
DateTime? _lastDebugTapTime;
int _remainingTaps = 0;
bool _showTapCounter = false;

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
  bool _showDebugButton = false;
  String _appVersion = '1.0.0';
  int _debugMenuTitleTapCount = 0;

  final List<String> _soundEffects = ['hl2.mp3', 'metal.mp3', 'click.mp3'];
  String _selectedSound = 'hl2.mp3';

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasShownShuffleToast = false;
  static const List<String> kOriginalButtonLayout = [
    'AC',
    '+/-',
    '%',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    '=',
  ];

  final List<String> _buttonLabels = List.from(kOriginalButtonLayout);

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  void _toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;
    });

    if (_isSoundEnabled) {
      Fluttertoast.showToast(
        msg: 'Sound effects enabled',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(221, 39, 39, 39),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Sound effects disabled',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(221, 39, 39, 39),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _playSound() async {
    if (_isSoundEnabled) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/$_selectedSound'));
      } catch (e) {
        print("Error playing sound: $e");
      }
    }
  }

  void _onPressed(String value) async {
    await _playSound();
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
            if (_isResultCalculated && _result.isNotEmpty) {
              // Handle toggling sign when we have a calculated result
              setState(() {
                _result =
                    _result.startsWith('-')
                        ? _result.substring(1)
                        : '-$_result';
                _input = _result; // Make the toggled result the new input
                _isResultCalculated = false;
              });
            } else if (_input.isNotEmpty) {
              // Handle normal case when inputting numbers
              final numberMatch = RegExp(r'(-?\d+\.?\d*)$').firstMatch(_input);

              if (numberMatch != null) {
                final String number = numberMatch.group(0)!;
                final int numberStart = numberMatch.start;

                // Toggle the sign
                final String newNumber =
                    number.startsWith('-')
                        ? number.substring(1) // Remove minus
                        : '-$number'; // Add minus

                // Rebuild the input
                setState(() {
                  _input = _input.substring(0, numberStart) + newNumber;
                });
              }
            }
            break;
          case '%':
            if (_input.isNotEmpty) {
              _input += value;
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
    String expression = input.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)%'),
      (match) => (double.parse(match.group(1)!) / 100).toString(),
    );

    expression = expression
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

    String resultStr = result
        .toStringAsFixed(11)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return resultStr.length > 12 ? resultStr.substring(0, 12) : resultStr;
  }

  void _shuffleButtons() {
    setState(() {
      _buttonLabels.shuffle();
    });

    if (!_hasShownShuffleToast) {
      Fluttertoast.showToast(
        msg: 'Info: Hold the button again to unshuffle',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(221, 39, 39, 39),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      _hasShownShuffleToast = true;
    }
  }

  void _restoreOriginalButtons() {
    setState(() {
      _buttonLabels
        ..clear()
        ..addAll(kOriginalButtonLayout);
    });
  }

  IconData _getSoundIcon(String sound) {
    switch (sound) {
      case 'hl2.mp3':
        return Icons.science;
      case 'metal.mp3':
        return Icons.construction;
      case 'click.mp3':
        return Icons.touch_app;
      default:
        return Icons.music_note;
    }
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(
                    'Sound Effects',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  value: _isSoundEnabled,
                  onChanged: (val) {
                    Navigator.pop(context);
                    _toggleSound();
                  },
                  secondary: Icon(
                    _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
                ..._soundEffects.map((sound) {
                  return ListTile(
                    leading: Icon(
                      _getSoundIcon(sound),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      sound.replaceAll('.mp3', '').toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    trailing:
                        _selectedSound == sound
                            ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : null,
                    onTap:
                        !_isSoundEnabled
                            ? null
                            : () {
                              setState(() {
                                _selectedSound = sound;
                              });
                              Navigator.pop(context);
                            },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTopLeftTap() {
    final now = DateTime.now();

    if (_lastDebugTapTime == null ||
        now.difference(_lastDebugTapTime!) >
            const Duration(milliseconds: 500)) {
      _debugTapCounter = 0;
    }

    _lastDebugTapTime = now;
    _debugTapCounter++;

    setState(() {
      if (_debugTapCounter >= 7) {
        _showDebugButton = true;
        _debugTapCounter = 0;

        Fluttertoast.showToast(
          msg: 'Debug mode enabled',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(221, 39, 39, 39),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  void _handleDebugMenuTitleTap() {
    Fluttertoast.cancel();

    setState(() {
      _debugMenuTitleTapCount++;
      _remainingTaps = 7 - _debugMenuTitleTapCount;
      _showTapCounter = _remainingTaps > 0 && _debugMenuTitleTapCount >= 4;
    });

    if (_showTapCounter) {
      Fluttertoast.showToast(
        msg:
            '$_remainingTaps more tap${_remainingTaps == 1 ? '' : 's'} to see the credits',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(221, 39, 39, 39),
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } else if (_debugMenuTitleTapCount >= 7) {
      _showCredits();
      setState(() {
        _debugMenuTitleTapCount = 0;
        _remainingTaps = 0;
      });
    }
  }

  void _showCredits() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: backgroundColor,
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🌟 Credits 🌟',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCreditItem(
                  'Developers:',
                  'Adomas, Vincentas, Tautvydas',
                  Icons.design_services,
                  textColor,
                ),
                const SizedBox(height: 10),
                Divider(color: textColor.withOpacity(0.5)),
                const SizedBox(height: 10),
                Text(
                  'Special Thanks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'To Vincentas Vincas Šeštakauskas for cooking this sh*t up.',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Version $_appVersion',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (_isSoundEnabled) {
                        _playSound();
                      }
                    },
                    child: const Text('Close', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreditItem(
    String role,
    String name,
    IconData icon,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Fluttertoast.showToast(
      msg: 'App will now close and reset.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color.fromARGB(221, 248, 53, 53),
      textColor: Colors.white,
      fontSize: 16.0,
    );
    await Future.delayed(const Duration(seconds: 2));
    SystemNavigator.pop();
  }

  void _showDebugMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = MediaQuery.of(context).size.height * 0.85;

            return Container(
              constraints: BoxConstraints(maxHeight: availableHeight + 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _handleDebugMenuTitleTap,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 18, bottom: 8),
                            child: Text(
                              'Debug Menu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Container(
                                color: Theme.of(context).cardColor,
                                child: ListTile(
                                  dense: false,
                                  leading: const Icon(Icons.home),
                                  title: const Text('Show Welcome Screen'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => WelcomeScreen(
                                              themeMode: widget.themeMode,
                                              onThemeChanged:
                                                  widget.onThemeChanged,
                                              onContinue:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Divider(height: 1),
                              Container(
                                color: Theme.of(context).cardColor,
                                child: SwitchListTile(
                                  dense: false,
                                  secondary: Icon(
                                    _isSoundEnabled
                                        ? Icons.volume_up
                                        : Icons.volume_off,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  title: const Text('Sound Effects'),
                                  value: _isSoundEnabled,
                                  onChanged: (val) {
                                    Navigator.pop(context);
                                    _toggleSound();
                                  },
                                ),
                              ),
                              Container(
                                color: Theme.of(context).cardColor,
                                child: ListTile(
                                  dense: false,
                                  leading: const Icon(Icons.music_note),
                                  title: const Text('Show Sound Effect Menu'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showSoundPicker();
                                  },
                                ),
                              ),
                              const Divider(height: 1),
                              Container(
                                color: Theme.of(context).cardColor,
                                child: ListTile(
                                  dense: false,
                                  leading: const Icon(Icons.shuffle),
                                  title: const Text('Shuffle Buttons'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _shuffleButtons();
                                  },
                                ),
                              ),
                              Container(
                                color: Theme.of(context).cardColor,
                                child: ListTile(
                                  dense: false,
                                  leading: const Icon(Icons.undo),
                                  title: const Text('Unshuffle Buttons'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _restoreOriginalButtons();
                                  },
                                ),
                              ),
                              const Divider(height: 1),
                              Container(
                                color: Theme.of(context).cardColor,
                                child: ListTile(
                                  dense: false,
                                  leading: const Icon(
                                    Icons.refresh,
                                    color: Colors.red,
                                  ),
                                  title: const Text(
                                    'Full App Reset',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Clear all app data and close the app',
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'Confirm Full Reset',
                                            ),
                                            content: const Text(
                                              'This will clear ALL app data and close the app. Continue?',
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed:
                                                    () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  'RESET',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _resetApp();
                                                },
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 16,
                    child: Text(
                      'v$_appVersion',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoundButton(
    String text, {
    Color? color,
    bool isNumber = false,
    int? index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isTopFunctionButton = index != null && index < 3;

    final buttonColor =
        color ??
        (isNumber
            ? (isDark
                ? const Color.fromARGB(255, 43, 43, 43)
                : const Color.fromARGB(255, 160, 160, 160))
            : (isTopFunctionButton
                ? (isDark
                    ? const Color.fromARGB(255, 83, 83, 83)
                    : const Color.fromARGB(255, 104, 104, 104))
                : const Color.fromARGB(255, 0, 122, 255)));

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: ElevatedButton(
            onPressed: () => _onPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideButton(String text, {Color? color, bool isNumber = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor =
        isNumber
            ? (isDark
                ? const Color.fromARGB(255, 43, 43, 43)
                : const Color.fromARGB(255, 160, 160, 160))
            : (color ?? const Color(0xFF007AFF));

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: AspectRatio(
          aspectRatio: 2.1,
          child: ElevatedButton(
            onPressed: () => _onPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> buttons) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
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
                Positioned(
                  top: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: _handleTopLeftTap,
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.transparent,
                    ),
                  ),
                ),
                if (_showDebugButton)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.bug_report,
                        color: Colors.red,
                        size: 28,
                      ),
                      tooltip: 'Debug',
                      onPressed: _showDebugMenu,
                    ),
                  ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.music_note, size: 28),
                        onPressed: _showSoundPicker,
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(top: 50, right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.shuffle, size: 28),
                    onPressed: _shuffleButtons,
                    onLongPress: _restoreOriginalButtons,
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
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    top: 60,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: _isResultCalculated ? 24 : fontSize,
                                color:
                                    _isResultCalculated
                                        ? Colors.grey
                                        : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                              ),
                              child: Text(
                                _input,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result,
                        style: TextStyle(
                          fontSize: 62,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      _buildRow([
                        _buildRoundButton(_buttonLabels[0], index: 0),
                        _buildRoundButton(_buttonLabels[1], index: 1),
                        _buildRoundButton(_buttonLabels[2], index: 2),
                        _buildRoundButton(_buttonLabels[3], index: 3),
                      ]),
                      _buildRow([
                        _buildRoundButton(_buttonLabels[4], isNumber: true),
                        _buildRoundButton(_buttonLabels[5], isNumber: true),
                        _buildRoundButton(_buttonLabels[6], isNumber: true),
                        _buildRoundButton(_buttonLabels[7], isNumber: false),
                      ]),
                      _buildRow([
                        _buildRoundButton(_buttonLabels[8], isNumber: true),
                        _buildRoundButton(_buttonLabels[9], isNumber: true),
                        _buildRoundButton(_buttonLabels[10], isNumber: true),
                        _buildRoundButton(_buttonLabels[11], isNumber: false),
                      ]),
                      _buildRow([
                        _buildRoundButton(_buttonLabels[12], isNumber: true),
                        _buildRoundButton(_buttonLabels[13], isNumber: true),
                        _buildRoundButton(_buttonLabels[14], isNumber: true),
                        _buildRoundButton(_buttonLabels[15], isNumber: false),
                      ]),
                      _buildRow([
                        _buildWideButton(_buttonLabels[16], isNumber: true),
                        _buildRoundButton(_buttonLabels[17], isNumber: true),
                        _buildRoundButton(
                          _buttonLabels[18],
                          color: Colors.orange,
                          isNumber: false,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
