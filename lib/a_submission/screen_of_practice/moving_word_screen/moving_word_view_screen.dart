import 'package:flutter/material.dart';
import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:typing_speed_test_app/a_submission/screen_of_practice/moving_word_screen/moving_word_history_screen.dart';
import '../../../database/database_helper.dart';
import '../../../models/typing_test_model.dart';

class MovingWordViewScreen extends StatefulWidget {
  const MovingWordViewScreen({super.key});

  @override
  State<MovingWordViewScreen> createState() => _MovingWordViewScreenState();
}

class _MovingWordViewScreenState extends State<MovingWordViewScreen>
    with TickerProviderStateMixin {
  // Speed settings
  String selectedSpeed = 'Medium';
  Map<String, int> speedSettings = {
    'Slow': 5,
    'Medium': 3,
    'Fast': 2,
    'Very Fast': 1,
  };

  // Word generation
  final Set<String> _usedWords = <String>{};
  final int _maxUniqueWords = 100;
  final int _minWordLength = 2;
  final int _maxWordLength = 9;

  // Database integration
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String _testType = 'moving_word_vertical';
  final List<String> _wordsAttempted = [];

  // Game state
  bool isTestStarted = false;
  bool showSpeedSelector = true;
  bool isStopped = false;
  String currentWord = '';
  String typedText = '';
  Timer? wordTimer;
  bool isPaused = false;
  Duration remainingTime = Duration.zero;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Statistics
  int totalWordsTyped = 0;
  DateTime? testStartTime;
  Duration testDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    wordTimer?.cancel();
    _animationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _generateRandomWord() {
    String word;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      final wp = WordPair.random();
      word = wp.first.toLowerCase();
      attempts++;

      if (word.length >= _minWordLength && word.length <= _maxWordLength) {
        if (!_usedWords.contains(word)) {
          _usedWords.add(word);

          if (_usedWords.length > _maxUniqueWords) {
            _usedWords.clear();
            _usedWords.add(word);
          }

          return word;
        }
      }

      if (attempts > maxAttempts) {
        if (word.length < _minWordLength) {
          final wp2 = WordPair.random();
          final word2 = wp2.first.toLowerCase();
          if (word2.length >= _minWordLength) {
            word = word2;
          } else {
            word = word + word2;
            if (word.length > _maxWordLength) {
              word = word.substring(0, _maxWordLength);
            }
          }
        } else if (word.length > _maxWordLength) {
          word = word.substring(0, _maxWordLength);
        }

        String uniqueWord = word;
        int suffix = 1;
        while (_usedWords.contains(uniqueWord) && suffix < 10) {
          uniqueWord = word + suffix.toString();
          suffix++;
        }

        if (_usedWords.contains(uniqueWord)) {
          _usedWords.clear();
          uniqueWord = word;
        }

        _usedWords.add(uniqueWord);
        return uniqueWord;
      }
    } while (true);
  }

  void _pauseGame() {
    if (!isPaused && isTestStarted) {
      setState(() {
        isPaused = true;
      });

      _animationController.stop();

      if (wordTimer != null && wordTimer!.isActive) {
        wordTimer!.cancel();

        double remainingProgress = 1.0 - _animationController.value;
        int totalDuration = speedSettings[selectedSpeed]!;
        remainingTime = Duration(
          seconds: (remainingProgress * totalDuration).ceil(),
        );
      }
    }
  }

  void _resumeGame() {
    if (isPaused && isTestStarted && !isStopped) {
      setState(() {
        isPaused = false;
      });

      _animationController.forward();

      if (remainingTime.inSeconds > 0) {
        wordTimer = Timer(remainingTime, () {
          _onWordTimeout();
        });
      }
    }
  }

  void _stopGame() {
    setState(() {
      isStopped = true;
      isPaused = false;
      isTestStarted = false;
      showSpeedSelector = true;
    });

    wordTimer?.cancel();
    _animationController.stop();
    _animationController.reset();

    _textController.clear();

    currentWord = '';
    typedText = '';
    remainingTime = Duration.zero;
  }

  void startTest() {
    setState(() {
      showSpeedSelector = false;
      isTestStarted = true;
      isStopped = false;
      isPaused = false;
      testStartTime = DateTime.now();
      totalWordsTyped = 0;
      _usedWords.clear();
      _wordsAttempted.clear();
    });
    _showNextWord();
  }

  void _showNextWord() {
    final newWord = _generateRandomWord();
    _wordsAttempted.add(newWord);

    setState(() {
      currentWord = newWord;
      typedText = '';
    });

    _textController.clear();

    int duration = speedSettings[selectedSpeed]!;
    _animationController.duration = Duration(seconds: duration);

    _animationController.reset();
    _animationController.forward();

    wordTimer = Timer(Duration(seconds: duration), () {
      _onWordTimeout();
    });
  }

  void _onWordTimeout() {
    setState(() {
      totalWordsTyped++;
    });
    _showNextWord();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onWordTyped(String word) {
    wordTimer?.cancel();

    setState(() {
      totalWordsTyped++;
    });

    _showNextWord();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  double _calculateWPM() {
    if (testStartTime == null) return 0.0;

    Duration elapsed = DateTime.now().difference(testStartTime!);
    double minutes = elapsed.inMilliseconds / 60000.0;

    if (minutes > 0) {
      return totalWordsTyped / minutes;
    }
    return 0.0;
  }

  Future<void> _saveSession() async {
    _pauseGame();

    if (totalWordsTyped == 0) {
      _showMessage(
        'Nothing to save',
        'Complete at least one word before saving',
        isError: true,
      );
      _resumeGame();
      return;
    }

    try {
      double wpm = _calculateWPM();
      Duration elapsed = testStartTime != null
          ? DateTime.now().difference(testStartTime!)
          : Duration.zero;
      double accuracy = 100.0; // Default accuracy for simplicity

      // Save to database
      final typingTest = TypingTestModel(
        testType: _testType,
        originalText: _wordsAttempted.join(' '),
        typedText: _wordsAttempted.join(' '),
        wpm: wpm,
        accuracy: accuracy,
        correctWords: totalWordsTyped,
        wrongWords: 0,
        totalWords: totalWordsTyped,
        timeSeconds: elapsed.inSeconds,
        testDate: DateTime.now(),
      );

      await _dbHelper.saveTypingTest(typingTest);

      _showSaveSuccessDialog(wpm, elapsed);
    } catch (e) {
      _showMessage('Save Failed', 'Error saving session: $e', isError: true);
      _resumeGame();
    }
  }

  void _showSaveSuccessDialog(double wpm, Duration elapsed) {
    final Color primaryColor = _getSpeedColor(selectedSpeed);
    final Color secondaryColor = _getSecondaryColor(selectedSpeed);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  'Saved!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WPM: ${wpm.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Words: $totalWordsTyped',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resumeGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    ).then((_) {
      _resumeGame();
    });
  }

  void _showMessage(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isError ? Icons.error : Icons.info,
                color: isError ? Colors.red : Colors.blue,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showHistory() {
    _pauseGame();

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const MovingWordHistoryScreen(),
          ),
        )
        .then((_) {
          _resumeGame();
        });
  }

  Widget _buildSpeedSelector() {
    final Color primaryColor = const Color(0xFF6366F1);
    final Color bgColor = const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.flash_on, size: 48, color: primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Choose Your Speed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how fast words should move',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              ...speedSettings.entries.map((entry) {
                final bool isSelected = selectedSpeed == entry.key;
                final Color speedColor = _getSpeedColor(entry.key);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedSpeed = entry.key;
                        });
                        startTest();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    speedColor,
                                    speedColor.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? speedColor
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? speedColor.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 12 : 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isSelected ? Colors.white : speedColor)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getSpeedIcon(entry.key),
                                color: isSelected ? Colors.white : speedColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${entry.value} seconds per word',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: isSelected ? Colors.white : speedColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSpeedColor(String speed) {
    switch (speed) {
      case 'Slow':
        return const Color(0xFF10B981);
      case 'Medium':
        return const Color(0xFF3B82F6);
      case 'Fast':
        return const Color(0xFFF59E0B);
      case 'Very Fast':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6366F1);
    }
  }

  Color _getSecondaryColor(String speed) {
    switch (speed) {
      case 'Slow':
        return const Color(0xFF34D399);
      case 'Medium':
        return const Color(0xFF60A5FA);
      case 'Fast':
        return const Color(0xFFFBBF24);
      case 'Very Fast':
        return const Color(0xFFF87171);
      default:
        return const Color(0xFF818CF8);
    }
  }

  IconData _getSpeedIcon(String speed) {
    switch (speed) {
      case 'Slow':
        return Icons.directions_walk;
      case 'Medium':
        return Icons.directions_run;
      case 'Fast':
        return Icons.directions_bike;
      case 'Very Fast':
        return Icons.rocket_launch;
      default:
        return Icons.speed;
    }
  }

  Widget _buildMovingWordView() {
    final Color primaryColor = _getSpeedColor(selectedSpeed);
    final Color secondaryColor = _getSecondaryColor(selectedSpeed);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            secondaryColor.withOpacity(0.2),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Control buttons only
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.8),
                  secondaryColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildControlButtons(),
          ),
          // Main word display area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  double screenHeight = MediaQuery.of(context).size.height;
                  double maxFallDistance = screenHeight * 0.4;

                  double topPosition;
                  if (_animation.value < 0.15) {
                    topPosition = -50 + (_animation.value / 0.15) * 100;
                  } else if (_animation.value < 0.85) {
                    topPosition = 50 + (_animation.value - 0.15) * 100;
                  } else {
                    double finalFallProgress = (_animation.value - 0.85) / 0.15;
                    topPosition = 120 + finalFallProgress * maxFallDistance;
                  }

                  return Stack(
                    children: [
                      // Word display - simple and big
                      Positioned(
                        top: topPosition,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 25,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  secondaryColor,
                                  primaryColor.withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: secondaryColor.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(5, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              currentWord,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Seconds countdown below the word
                      Positioned(
                        top: topPosition + 85,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  secondaryColor.withOpacity(0.8),
                                  primaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              isPaused
                                  ? 'PAUSED'
                                  : '${((1 - _animation.value) * speedSettings[selectedSpeed]!).ceil()}s',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Simple pause overlay
                      if (isPaused)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  primaryColor.withOpacity(0.3),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'PAUSED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Colorful input field
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              autofocus: true,
              enabled: !isPaused,
              onChanged: (value) {
                if (!isPaused) {
                  setState(() {
                    typedText = value;
                  });
                  if (value.trim().toLowerCase() == currentWord.toLowerCase()) {
                    _onWordTyped(value.trim());
                  }
                }
              },
              onSubmitted: (value) {
                if (!isPaused) {
                  _onWordTyped(value.trim());
                }
              },
              decoration: InputDecoration(
                hintText: isPaused ? 'Game paused...' : 'Type the word here',
                hintStyle: TextStyle(
                  color: primaryColor.withOpacity(0.6),
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.8),
                        secondaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.keyboard, color: Colors.white),
                ),
              ),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pause/Resume Button
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPaused
                  ? [Colors.green, Colors.lightGreen]
                  : [Colors.orange, Colors.amber],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isPaused ? Colors.green : Colors.orange).withOpacity(
                  0.4,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isPaused ? _resumeGame : _pauseGame,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPaused ? 'Resume' : 'Pause',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        // Stop Button
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.red, Colors.pink]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showStopConfirmation(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stop, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Stop',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showStopConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: const Color(0xFFEF4444), size: 28),
              const SizedBox(width: 8),
              const Text('Stop Game?'),
            ],
          ),
          content: const Text(
            'Are you sure you want to stop the current game? Your progress will be lost unless you save it first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveSession();
                _stopGame();
              },
              child: const Text('Save & Stop'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _stopGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Stop Without Saving'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = showSpeedSelector
        ? const Color(0xFF6366F1)
        : _getSpeedColor(selectedSpeed);

    return Scaffold(
      backgroundColor: showSpeedSelector ? null : const Color(0xFFF8FAFC),
      appBar: isTestStarted
          ? AppBar(
              title: Row(
                children: [
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Moving Words',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$selectedSpeed Mode',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: _saveSession,
                    icon: const Icon(Icons.save_alt),
                    tooltip: 'Save Session',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: _showHistory,
                    icon: const Icon(Icons.history),
                    tooltip: 'View History',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          : AppBar(
              title: Row(
                children: [
                  const Text(
                    'Moving Words',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: _saveSession,
                    icon: const Icon(Icons.save_alt),
                    tooltip: 'Save Session',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: _showHistory,
                    icon: const Icon(Icons.history),
                    tooltip: 'View History',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
      body: showSpeedSelector ? _buildSpeedSelector() : _buildMovingWordView(),
    );
  }
}
