import 'package:typing_speed_test_app/import_export_file.dart';

class NumberPracticeController extends GetxController {
  // Text Controller
  final TextEditingController textController = TextEditingController();

  // Observables
  final RxString currentNumber = ''.obs;
  final RxInt correct = 0.obs;
  final RxInt wrong = 0.obs;
  final RxDouble accuracy = 0.0.obs;
  final RxDouble cpm = 0.0.obs;
  final RxBool isPracticeActive = false.obs;
  final RxInt totalAttempts = 0.obs;

  // Timer / stopwatch
  final Stopwatch stopwatch = Stopwatch();
  Timer? _timer;

  // Number length settings
  final int minNumberLength = 3;
  final int maxNumberLength = 7;

  // History (targets & typed) for current session
  final RxList<String> originalNumbers = <String>[].obs;
  final RxList<String> typedNumbers = <String>[].obs;

  final Random _rand = Random();

  // Persistent history map: dateString -> List<sessionMap>
  final RxMap<String, List<Map<String, dynamic>>> history =
      <String, List<Map<String, dynamic>>>{}.obs;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String testType = 'number';

  @override
  void onInit() {
    super.onInit();
    _initController();
  }

  Future<void> _initController() async {
    await loadHistoryFromDatabase();
    generateNumber();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    textController.dispose();
    super.onClose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPracticeActive.value && stopwatch.isRunning) {
        updateStats();
      }
    });
  }

  void generateNumber() {
    final numberLength =
        _rand.nextInt(maxNumberLength - minNumberLength + 1) + minNumberLength;
    final buffer = StringBuffer();
    for (int i = 0; i < numberLength; i++) {
      buffer.write(_rand.nextInt(10).toString());
    }

    final newNumber = buffer.toString();
    currentNumber.value = newNumber;
    originalNumbers.add(newNumber);
    textController.clear();
  }

  void nextNumber() {
    // No limit: always generate a new number
    generateNumber();
  }

  /// Call this from TextField.onChanged
  /// Commits when user types a space (or exact match without space)
  void onInputChanged(String input) {
    final trimmed = input.trim();

    // Start session on first non-empty input
    if (trimmed.isNotEmpty && !isPracticeActive.value) {
      isPracticeActive.value = true;
      stopwatch.start();
    }

    // If user finished the entry (presses space) or exact match typed
    final finished = input.endsWith(' ') || trimmed == currentNumber.value;

    if (finished && trimmed.isNotEmpty) {
      totalAttempts.value++;

      if (trimmed == currentNumber.value) {
        correct.value++;
      } else {
        wrong.value++;
      }

      // record typed attempt (even if wrong)
      typedNumbers.add(trimmed);

      // prepare next
      nextNumber();

      // reset the input controller (keeps focus)
      textController.clear();
    }

    updateStats();
  }

  void updateStats() {
    final total = correct.value + wrong.value;
    if (total > 0) {
      accuracy.value = (correct.value / total) * 100;
    } else {
      accuracy.value = 0.0;
    }

    final elapsedSeconds = stopwatch.elapsed.inSeconds;
    if (elapsedSeconds > 0) {
      cpm.value = (correct.value * 60) / elapsedSeconds;
    } else {
      cpm.value = 0.0;
    }
  }

  void resetPractice({bool keepNumber = false}) {
    correct.value = 0;
    wrong.value = 0;
    accuracy.value = 0.0;
    cpm.value = 0.0;
    totalAttempts.value = 0;
    isPracticeActive.value = false;

    originalNumbers.clear();
    typedNumbers.clear();

    stopwatch.reset();

    if (keepNumber) {
      // keep current number (rarely used)
      textController.clear();
    } else {
      generateNumber();
    }
  }

  /// Save session without automatic completion
  /// This is intended to be called when user taps "Save"
  Future<void> saveCurrentSessionManual() async {
    // don't save empty sessions
    if (totalAttempts.value == 0) {
      Get.snackbar(
        'Nothing to save',
        'Complete at least one entry before saving',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Stop timer and mark inactive
    isPracticeActive.value = false;
    if (stopwatch.isRunning) stopwatch.stop();
    updateStats();

    // persist session
    await saveSessionToHistory();

    // show confirmation
    Get.snackbar(
      'Saved',
      'Session saved for today',
      snackPosition: SnackPosition.BOTTOM,
    );

    // reset practice afterwards for fresh start
    resetPractice();
  }

  // Keep this method for programmatic saves (used internally)
  Map<String, dynamic> _createSessionMap() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'total': totalAttempts.value,
      'correct': correct.value,
      'wrong': wrong.value,
      'accuracy': double.parse(accuracy.value.toStringAsFixed(2)),
      'cpm': double.parse(cpm.value.toStringAsFixed(2)),
      'originalNumbers': List<String>.from(originalNumbers),
      'typedNumbers': List<String>.from(typedNumbers),
    };
  }

  Future<void> saveSessionToHistory() async {
    final dateKey = _todayKey();
    final session = _createSessionMap();

    // Save to database
    final typingTest = TypingTestModel(
      testType: testType,
      originalText: originalNumbers.join(' '),
      typedText: typedNumbers.join(' '),
      wpm: cpm.value / 5,
      // Convert CPM to WPM
      accuracy: accuracy.value,
      correctWords: correct.value,
      wrongWords: wrong.value,
      totalWords: totalAttempts.value,
      timeSeconds: stopwatch.elapsed.inSeconds,
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
          'cpm': test.wpm * 5,
          'originalNumbers': test.originalText.split(' '),
          'typedNumbers': test.typedText.split(' '),
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

  /// Colored typed text spans for display
  List<TextSpan> getColoredTypedText() {
    final spans = <TextSpan>[];
    for (int i = 0; i < typedNumbers.length; i++) {
      final typed = typedNumbers[i];
      final expected = i < originalNumbers.length ? originalNumbers[i] : '';
      final isCorrect = typed == expected;
      spans.add(
        TextSpan(
          text: (i == 0 ? '' : ' ') + typed,
          style: TextStyle(
            color: isCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );
    }
    return spans;
  }
}
