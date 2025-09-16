import 'package:typing_speed_test_app/import_export_file.dart';

class WordPracticeController extends GetxController {
  final TextEditingController inputController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final RxList<String> originalWords = <String>[].obs;
  final RxList<String> typedWords = <String>[].obs;

  final RxInt currentIndex = 0.obs;

  final RxInt correct = 0.obs;
  final RxInt wrong = 0.obs;
  final RxInt totalAttempts = 0.obs;
  final RxInt sessionSeconds = 0.obs;

  final Stopwatch stopwatch = Stopwatch();
  Timer? _tickTimer;

  bool isInfinite = true;

  final RxBool isPracticeActive = false.obs;

  final RxMap<String, List<Map<String, dynamic>>> history =
      <String, List<Map<String, dynamic>>>{}.obs;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String testType = 'word';

  final int defaultInitialReveal = 1;

  @override
  void onInit() {
    super.onInit();
    _initController();
  }

  Future<void> _initController() async {
    await _dbHelper.cleanupFiniteWordRecords();
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

  final Set<String> _usedWords = <String>{};
  final Random _random = Random();
  int _maxUniqueWords = 100;

  final int minWordLength = 2;
  final int maxWordLength = 9;

  String _generateRandomWord() {
    String word;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      final wp = WordPair.random();
      word = wp.first.toLowerCase();
      attempts++;

      if (word.length >= minWordLength && word.length <= maxWordLength) {
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
        if (word.length < minWordLength) {
          final wp2 = WordPair.random();
          final word2 = wp2.first.toLowerCase();
          if (word2.length >= minWordLength) {
            word = word2;
          } else {
            word = word + word2;
            if (word.length > maxWordLength) {
              word = word.substring(0, maxWordLength);
            }
          }
        } else if (word.length > maxWordLength) {
          word = word.substring(0, maxWordLength);
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

  void _revealNextWord() {
    originalWords.add(_generateRandomWord());
  }

  void startInfiniteSession() {
    isInfinite = true;
    _clearSessionState();
    _revealNextWord();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => focusNode.requestFocus(),
    );
  }


  void _clearSessionState() {
    originalWords.clear();
    typedWords.clear();
    _usedWords.clear();
    currentIndex.value = 0;
    correct.value = 0;
    wrong.value = 0;
    totalAttempts.value = 0;
    sessionSeconds.value = 0;
    isPracticeActive.value = false;
    stopwatch.reset();
    inputController.clear();
  }

  String get currentWord {
    if (currentIndex.value < originalWords.length) {
      return originalWords[currentIndex.value];
    }
    return '';
  }

  void onChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !stopwatch.isRunning) {
      stopwatch.start();
      isPracticeActive.value = true;
    }

    if (trimmed.isNotEmpty &&
        trimmed.toLowerCase() == currentWord.toLowerCase()) {
      submitTyped(trimmed);
      inputController.clear();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => focusNode.requestFocus(),
      );
      return;
    }

    if (value.endsWith(' ')) {
      if (trimmed.isNotEmpty) submitTyped(trimmed);
      inputController.clear();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => focusNode.requestFocus(),
      );
    }
  }

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

    currentIndex.value++;
    _revealNextWord();
  }

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

  void restartInfinite() => startInfiniteSession();

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

  Future<void> saveCurrentSessionManual({bool resetAfterSave = true}) async {
    if (totalAttempts.value == 0) {
      Get.snackbar(
        'Nothing to save',
        'Complete at least one word before saving',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isPracticeActive.value = false;
    if (stopwatch.isRunning) stopwatch.stop();
    sessionSeconds.value = stopwatch.elapsed.inSeconds;

    await saveSessionToHistory();

    Get.snackbar(
      'Saved',
      'Session saved for today',
      snackPosition: SnackPosition.BOTTOM,
    );

    if (resetAfterSave) {
      resetSessionKeepMode();
    }
  }

  Future<void> saveSessionToHistory() async {
    final dateKey = _todayKey();
    final session = _createSessionMap();

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
          'session_type': 'infinite',
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
