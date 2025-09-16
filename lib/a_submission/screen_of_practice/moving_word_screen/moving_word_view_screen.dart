import 'package:flutter/material.dart';
import 'dart:async';
import 'package:english_words/english_words.dart';
import '../../../database/database_helper.dart';
import '../../../models/typing_test_model.dart';
import 'moving_word_history_screen.dart';

/// A typing practice screen where words move vertically from top to bottom.
/// Features:
/// - Speed selection (Slow, Medium, Fast, Very Fast)
/// - Clean interface with only moving words visible
/// - App bar with save and history icons
/// - Infinite word generation using english_words package
/// - Automatic word progression and timing
/// - Statistics tracking (correct, missed, WPM)
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

  // Infinite word generation system (similar to WordPracticeController)
  final Set<String> _usedWords = <String>{};
  final int _maxUniqueWords = 100; // Reset used words after this many words
  final int _minWordLength = 2;
  final int _maxWordLength = 9;

  // Database integration
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String _testType = 'moving_word_vertical';
  final List<String> _wordsAttempted = []; // Track words for session

  // Game state
  bool isTestStarted = false;
  bool showSpeedSelector = true;
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
  int correctWords = 0;
  int missedWords = 0;
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
    // Updated animation: word stays visible in center for most of the time
    // Falls slowly from top (0.0) to center (0.3) and stays there until end (1.0)
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

  /// Generate a single random word with random length using english_words package
  /// Ensures no word repetition within a session (similar to WordPracticeController)
  String _generateRandomWord() {
    String word;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      final wp = WordPair.random();
      word = wp.first.toLowerCase();
      attempts++;

      // Check if word meets length requirements
      if (word.length >= _minWordLength && word.length <= _maxWordLength) {
        // Check if word hasn't been used recently
        if (!_usedWords.contains(word)) {
          _usedWords.add(word);

          // Reset used words set if it gets too large
          if (_usedWords.length > _maxUniqueWords) {
            _usedWords.clear();
            _usedWords.add(word);
          }

          return word;
        }
      }

      // Prevent infinite loops - if we can't find a unique word after many attempts,
      // create a modified word or clear the used words set
      if (attempts > maxAttempts) {
        if (word.length < _minWordLength) {
          // If word is too short, try to extend it
          final wp2 = WordPair.random();
          final word2 = wp2.first.toLowerCase();
          if (word2.length >= _minWordLength) {
            word = word2;
          } else {
            // Create a word of minimum length by combining
            word = word + word2;
            if (word.length > _maxWordLength) {
              word = word.substring(0, _maxWordLength);
            }
          }
        } else if (word.length > _maxWordLength) {
          // If word is too long, truncate it
          word = word.substring(0, _maxWordLength);
        }

        // If still repeated, add a number suffix to make it unique
        String uniqueWord = word;
        int suffix = 1;
        while (_usedWords.contains(uniqueWord) && suffix < 10) {
          uniqueWord = word + suffix.toString();
          suffix++;
        }

        // If we still can't find a unique word, clear the used set
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

      // Pause animation
      _animationController.stop();

      // Cancel current timer and calculate remaining time
      if (wordTimer != null && wordTimer!.isActive) {
        wordTimer!.cancel();

        // Calculate remaining time based on animation progress
        double remainingProgress = 1.0 - _animationController.value;
        int totalDuration = speedSettings[selectedSpeed]!;
        remainingTime = Duration(
          seconds: (remainingProgress * totalDuration).ceil(),
        );
      }
    }
  }

  void _resumeGame() {
    if (isPaused && isTestStarted) {
      setState(() {
        isPaused = false;
      });

      // Resume animation
      _animationController.forward();

      // Start new timer with remaining time
      if (remainingTime.inSeconds > 0) {
        wordTimer = Timer(remainingTime, () {
          _onWordTimeout();
        });
      }
    }
  }

  void startTest() {
    setState(() {
      showSpeedSelector = false;
      isTestStarted = true;
      testStartTime = DateTime.now();
      correctWords = 0;
      missedWords = 0;
      totalWordsTyped = 0;
      _usedWords.clear(); // Clear used words for new session
      _wordsAttempted.clear(); // Clear session word history
    });
    _showNextWord();
  }

  void _showNextWord() {
    // Generate a new random word for infinite practice
    final newWord = _generateRandomWord();
    _wordsAttempted.add(newWord); // Track word for session

    setState(() {
      currentWord = newWord;
      typedText = '';
    });

    // Clear the text input field
    _textController.clear();

    // Set animation duration to match the selected speed
    int duration = speedSettings[selectedSpeed]!;
    _animationController.duration = Duration(seconds: duration);

    _animationController.reset();
    _animationController.forward();

    // Set timer based on selected speed (same as animation duration)
    wordTimer = Timer(Duration(seconds: duration), () {
      _onWordTimeout();
    });
  }

  void _onWordTimeout() {
    // Word missed (not typed in time)
    setState(() {
      missedWords++;
      totalWordsTyped++;
    });
    _showNextWord();

    // Refocus the text input
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onWordTyped(String word) {
    wordTimer?.cancel();

    if (word.toLowerCase() == currentWord.toLowerCase()) {
      setState(() {
        correctWords++;
      });
    } else {
      setState(() {
        missedWords++;
      });
    }

    setState(() {
      totalWordsTyped++;
    });

    _showNextWord();

    // Refocus the text input
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
      return correctWords / minutes;
    }
    return 0.0;
  }

  Future<void> _saveSession() async {
    _pauseGame();

    // Don't save empty sessions
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
      // Calculate session data
      double wpm = _calculateWPM();
      Duration elapsed = testStartTime != null
          ? DateTime.now().difference(testStartTime!)
          : Duration.zero;
      double accuracy = totalWordsTyped > 0
          ? (correctWords / totalWordsTyped) * 100
          : 0.0;

      // Create typing test model
      final typingTest = TypingTestModel(
        testType: _testType,
        originalText: _wordsAttempted.join(' '),
        // Original words attempted
        typedText: _wordsAttempted.take(correctWords + missedWords).join(' '),
        // Session representation
        wpm: wpm,
        accuracy: accuracy,
        correctWords: correctWords,
        wrongWords: missedWords,
        totalWords: totalWordsTyped,
        timeSeconds: elapsed.inSeconds,
        testDate: DateTime.now(),
      );

      // Save to database
      await _dbHelper.saveTypingTest(typingTest);

      // Show success dialog
      _showSaveSuccessDialog(wpm, accuracy, elapsed);
    } catch (e) {
      _showMessage('Save Failed', 'Error saving session: $e', isError: true);
      _resumeGame();
    }
  }

  void _showSaveSuccessDialog(double wpm, double accuracy, Duration elapsed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Session Saved!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSaveStatRow(
                'Duration',
                '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
              ),
              _buildSaveStatRow('Total Words', '$totalWordsTyped'),
              _buildSaveStatRow('Correct Words', '$correctWords'),
              _buildSaveStatRow('Missed Words', '$missedWords'),
              _buildSaveStatRow('Accuracy', '${accuracy.toStringAsFixed(1)}%'),
              _buildSaveStatRow('WPM', wpm.toStringAsFixed(1)),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your progress has been saved to history!',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resumeGame();
              },
              child: const Text('Continue'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resumeGame();
                // Navigate to history screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MovingWordHistoryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('View History'),
            ),
          ],
        );
      },
    ).then((_) {
      _resumeGame();
    });
  }

  Widget _buildSaveStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showMessage(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
    // Pause the game when navigating to history
    _pauseGame();

    // Navigate to history screen
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const MovingWordHistoryScreen(),
          ),
        )
        .then((_) {
          // Resume the game when returning from history
          _resumeGame();
        });
  }

  Widget _buildSpeedSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Speed Setting',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ...speedSettings.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedSpeed = entry.key;
                    });
                    startTest();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: selectedSpeed == entry.key
                        ? Colors.blue
                        : Colors.grey[300],
                  ),
                  child: Text(
                    '${entry.key} (${entry.value} seconds per word)',
                    style: TextStyle(
                      fontSize: 18,
                      color: selectedSpeed == entry.key
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMovingWordView() {
    return Column(
      children: [
        // Main word display area
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // Calculate position for top-to-bottom falling animation
                double screenHeight = MediaQuery.of(context).size.height;
                double maxFallDistance =
                    screenHeight * 0.4; // Word can fall 40% of screen height

                // TOP-TO-BOTTOM animation with clear visibility:
                // Word starts above screen and falls down, staying visible for most duration
                double topPosition;

                if (_animation.value < 0.15) {
                  // First 15%: Word drops from above screen to top of visible area
                  topPosition =
                      -50 +
                      (_animation.value / 0.15) *
                          100; // From -50 to 50 pixels from top
                } else if (_animation.value < 0.85) {
                  // Middle 70%: Word stays clearly visible in upper-middle area
                  topPosition =
                      50 +
                      (_animation.value - 0.15) *
                          100; // Slowly drifts down in visible area
                } else {
                  // Last 15%: Word falls toward bottom and disappears
                  double finalFallProgress = (_animation.value - 0.85) / 0.15;
                  topPosition =
                      120 +
                      finalFallProgress *
                          maxFallDistance; // Falls toward bottom
                }

                return Stack(
                  children: [
                    // Progress indicator at top
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: LinearProgressIndicator(
                        value: _animation.value,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _animation.value > 0.7 ? Colors.red : Colors.blue,
                        ),
                        minHeight: 4,
                      ),
                    ),
                    // Word display
                    Positioned(
                      top: topPosition,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: Text(
                            currentWord,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Time remaining indicator
                    Positioned(
                      top: topPosition + 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          isPaused
                              ? 'PAUSED'
                              : '${((1 - _animation.value) * speedSettings[selectedSpeed]!).ceil()} sec',
                          style: TextStyle(
                            fontSize: 16,
                            color: isPaused
                                ? Colors.orange
                                : (_animation.value > 0.7
                                      ? Colors.red
                                      : Colors.grey.shade600),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Pause overlay
                    if (isPaused)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pause_circle_filled,
                                  color: Colors.white,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'GAME PAUSED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Close dialog to resume',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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
        // Text input field
        Container(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            autofocus: true,
            enabled: !isPaused,
            // Disable input when paused
            onChanged: (value) {
              if (!isPaused) {
                setState(() {
                  typedText = value;
                });

                // Auto-submit when word is complete and matches
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
              hintText: isPaused
                  ? 'Game paused...'
                  : 'Type the word: $currentWord',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.keyboard, color: Colors.blue),
              suffixIcon: typedText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textController.clear();
                        setState(() {
                          typedText = '';
                        });
                      },
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isTestStarted
          ? AppBar(
              title: Text('Moving Words'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: _saveSession,
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Session',
                ),
                IconButton(
                  onPressed: _showHistory,
                  icon: const Icon(Icons.history),
                  tooltip: 'View History',
                ),
              ],
            )
          : AppBar(
              title: const Text('Moving Words Test'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
      body: showSpeedSelector ? _buildSpeedSelector() : _buildMovingWordView(),
    );
  }
}
