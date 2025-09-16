import 'package:typing_speed_test_app/import_export_file.dart';

class WordPracticeController extends GetxController {
  // UI controllers
  final TextEditingController inputController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // Revealed list and typed history
  final RxList<String> originalWords = <String>[].obs;
  final RxList<String> typedWords = <String>[].obs;

  // Index of current revealed word (0-based)
  final RxInt currentIndex = 0.obs;

  // Stats
  final RxInt correct = 0.obs;
  final RxInt wrong = 0.obs;
  final RxInt totalAttempts = 0.obs;
  final RxInt sessionSeconds = 0.obs;

  // Timer/stopwatch
  final Stopwatch stopwatch = Stopwatch();
  Timer? _tickTimer;

  // Mode: infinite by default
  bool isInfinite = true;
  int finiteCount = 0;

  // expose practice active state (useful for UI)
  final RxBool isPracticeActive = false.obs;

  // Persistence (history)
  final RxMap<String, List<Map<String, dynamic>>> history =
      <String, List<Map<String, dynamic>>>{}.obs;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String testType = 'word';

  // Default starting reveal
  final int defaultInitialReveal = 1;

  @override
  void onInit() {
    super.onInit();
    _initController();
  }

  Future<void> _initController() async {
    await loadHistoryFromDatabase();
    startInfiniteSession();
    _startTicker();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => focusNode.requestFocus(),
    );
  }

  void _startTicker() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (stopwatch.isRunning)
        sessionSeconds.value = stopwatch.elapsed.inSeconds;
    });
  }

  // Word generation state to prevent repetition
  final Set<String> _usedWords = <String>{};
  final Random _random = Random();
  int _maxUniqueWords = 100; // Reset used words after this many words

  // Word length settings for random variety
  final int minWordLength = 2;
  final int maxWordLength = 9;

  /// Generate a single random word with random length using english_words package
  /// Ensures no word repetition within a session
  String _generateRandomWord() {
    String word;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      final wp = WordPair.random();
      word = wp.first.toLowerCase();
      attempts++;

      // Check if word meets length requirements
      if (word.length >= minWordLength && word.length <= maxWordLength) {
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
        if (word.length < minWordLength) {
          // If word is too short, try to extend it
          final wp2 = WordPair.random();
          final word2 = wp2.first.toLowerCase();
          if (word2.length >= minWordLength) {
            word = word2;
          } else {
            // Create a word of minimum length by combining
            word = word + word2;
            if (word.length > maxWordLength) {
              word = word.substring(0, maxWordLength);
            }
          }
        } else if (word.length > maxWordLength) {
          // If word is too long, truncate it
          word = word.substring(0, maxWordLength);
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

  /// Reveal next unique word by appending to originalWords
  void _revealNextWord() {
    originalWords.add(_generateRandomWord());
  }

  /// Start / restart infinite session
  void startInfiniteSession() {
    isInfinite = true;
    finiteCount = 0;
    _clearSessionState();
    // reveal first
    _revealNextWord();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => focusNode.requestFocus(),
    );
  }

  /// Start finite session (revealed one-by-one)
  void startFiniteSession(int count) {
    isInfinite = false;
    finiteCount = count;
    _clearSessionState();
    if (count > 0) _revealNextWord();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => focusNode.requestFocus(),
    );
  }

  void _clearSessionState() {
    originalWords.clear();
    typedWords.clear();
    _usedWords.clear(); // Clear used words for new session
    currentIndex.value = 0;
    correct.value = 0;
    wrong.value = 0;
    totalAttempts.value = 0;
    sessionSeconds.value = 0;
    isPracticeActive.value = false;
    stopwatch.reset();
    inputController.clear();
  }

  /// Current active (to-type) word
  String get currentWord {
    if (currentIndex.value < originalWords.length) {
      return originalWords[currentIndex.value];
    }
    return '';
  }

  /// Input change handler — submit on trailing space OR when correct word is typed
  void onChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !stopwatch.isRunning) {
      stopwatch.start();
      isPracticeActive.value = true;
    }

    // Auto-advance: submit immediately when correct word is typed
    if (trimmed.isNotEmpty &&
        trimmed.toLowerCase() == currentWord.toLowerCase()) {
      submitTyped(trimmed);
      inputController.clear();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => focusNode.requestFocus(),
      );
      return;
    }

    // Also submit on trailing space (original behavior)
    if (value.endsWith(' ')) {
      if (trimmed.isNotEmpty) submitTyped(trimmed);
      inputController.clear();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => focusNode.requestFocus(),
      );
    }
  }

  /// Submit on Enter or explicit call
  void onSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      if (!stopwatch.isRunning) {
        stopwatch.start();
        isPracticeActive.value = true;
      }
      submitTyped(trimmed);
      inputController.clear();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => focusNode.requestFocus(),
      );
    }
  }

  /// Evaluate typed word, record stats, and reveal next word if allowed
  void submitTyped(String typed) {
    final expected = currentWord;
    if (expected.isEmpty) return;

    totalAttempts.value++;

    final isCorrect = typed.toLowerCase() == expected.toLowerCase();
    if (isCorrect) {
      correct.value++;
    } else {
      wrong.value++;
    }

    typedWords.add(typed);

    // Advance and reveal next
    if (isInfinite) {
      currentIndex.value++;
      _revealNextWord();
    } else {
      if (currentIndex.value < finiteCount - 1) {
        currentIndex.value++;
        _revealNextWord();
      } else {
        // reached end
        currentIndex.value++;
        stopwatch.stop();
        isPracticeActive.value = false;
      }
    }
  }

  /// Reset progress but keep mode (reveal first word again)
  void resetSessionKeepMode() {
    typedWords.clear();
    correct.value = 0;
    wrong.value = 0;
    totalAttempts.value = 0;
    sessionSeconds.value = 0;
    currentIndex.value = 0;
    originalWords.clear();
    stopwatch.reset();
    inputController.clear();
    _revealNextWord();
    isPracticeActive.value = false;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => focusNode.requestFocus(),
    );
  }

  /// Restart infinite session
  void restartInfinite() => startInfiniteSession();

  /// Restart finite session of count
  void restartFinite(int count) => startFiniteSession(count);

  double get accuracy => (correct.value + wrong.value) == 0
      ? 0
      : (correct.value / (correct.value + wrong.value)) * 100;

  double get wpm {
    if (sessionSeconds.value == 0) return 0;
    final minutes = sessionSeconds.value / 60.0;
    return minutes == 0 ? 0 : correct.value / minutes;
  }

  double get cpm {
    if (sessionSeconds.value == 0) return 0;
    int chars = 0;
    for (int i = 0; i < typedWords.length; i++) {
      final typed = typedWords[i];
      final expected = i < originalWords.length ? originalWords[i] : '';
      if (typed.toLowerCase() == expected.toLowerCase())
        chars += expected.length;
    }
    final minutes = sessionSeconds.value / 60.0;
    return minutes == 0 ? 0 : chars / minutes;
  }

  List<TextSpan> getColoredTypedText() {
    final spans = <TextSpan>[];
    for (int i = 0; i < typedWords.length; i++) {
      final typed = typedWords[i];
      final expected = i < originalWords.length ? originalWords[i] : '';
      final ok = typed.toLowerCase() == expected.toLowerCase();
      final prefix = i == 0 ? '' : ' ';
      spans.add(
        TextSpan(
          text: prefix + typed,
          style: TextStyle(
            color: ok ? Colors.green : Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );
    }
    return spans;
  }

  /// ---------------- HISTORY PERSISTENCE ----------------

  Map<String, dynamic> _createSessionMap() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'total': totalAttempts.value,
      'correct': correct.value,
      'wrong': wrong.value,
      'accuracy': double.parse(accuracy.toStringAsFixed(2)),
      'wpm': double.parse(wpm.toStringAsFixed(2)),
      'cpm': double.parse(cpm.toStringAsFixed(2)),
      'originalWords': List<String>.from(originalWords),
      'typedWords': List<String>.from(typedWords),
    };
  }

  /// Save the current session under today's date key (YYYY-MM-DD)
  Future<void> saveCurrentSessionManual({bool resetAfterSave = true}) async {
    // don't save empty sessions
    if (totalAttempts.value == 0) {
      Get.snackbar(
        'Nothing to save',
        'Complete at least one word before saving',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Stop timer and mark inactive
    isPracticeActive.value = false;
    if (stopwatch.isRunning) stopwatch.stop();
    sessionSeconds.value = stopwatch.elapsed.inSeconds;

    // persist session
    await saveSessionToHistory();

    // show confirmation
    Get.snackbar(
      'Saved',
      'Session saved for today',
      snackPosition: SnackPosition.BOTTOM,
    );

    if (resetAfterSave) {
      // reset to fresh session keeping same mode
      resetSessionKeepMode();
    }
  }

  Future<void> saveSessionToHistory() async {
    final dateKey = _todayKey();
    final session = _createSessionMap();

    // Save to database
    final typingTest = TypingTestModel(
      testType: testType,
      originalText: originalWords.take(typedWords.length).join(' '),
      typedText: typedWords.join(' '),
      wpm: wpm,
      accuracy: accuracy,
      correctWords: correct.value,
      wrongWords: wrong.value,
      totalWords: totalAttempts.value,
      timeSeconds: sessionSeconds.value,
      testDate: DateTime.now(),
    );

    await _dbHelper.saveTypingTest(typingTest);

    // Update local history for UI
    final existing = history[dateKey] ?? <Map<String, dynamic>>[];
    existing.insert(0, session);
    history[dateKey] = existing;
  }

  Future<void> loadHistoryFromDatabase() async {
    try {
      final testHistory = await _dbHelper.getTypingHistory(testType);
      final Map<String, List<Map<String, dynamic>>> temp = {};

      for (final test in testHistory) {
        final dateKey = _dateKeyFromDateTime(test.testDate);
        final session = {
          'timestamp': test.testDate.toIso8601String(),
          'total': test.totalWords,
          'correct': test.correctWords,
          'wrong': test.wrongWords,
          'accuracy': test.accuracy,
          'wpm': test.wpm,
          'cpm': test.wpm * 5,
          'duration_seconds': test.timeSeconds,
          'session_type': isInfinite ? 'infinite' : 'finite',
          'originalWords': test.originalText.split(' '),
          'typedWords': test.typedText.split(' '),
        };

        if (temp[dateKey] == null) {
          temp[dateKey] = <Map<String, dynamic>>[];
        }
        temp[dateKey]!.add(session);
      }

      history.assignAll(temp);
    } catch (e) {
      history.clear();
    }
  }

  Future<void> deleteHistoryForDate(String dateKey) async {
    await _dbHelper.clearHistory(testType);
    history.remove(dateKey);
  }

  Future<void> clearAllHistory() async {
    await _dbHelper.clearHistory(testType);
    history.clear();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _dateKeyFromDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _tickTimer?.cancel();
    stopwatch.stop();
    inputController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
