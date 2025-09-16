import 'package:typing_speed_test_app/import_export_file.dart';

// Simple Character Practice Controller
class CharacterController extends GetxController {
  final List<String> characterSet = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
    '0','1','2','3','4','5', '6','7','8', '9',
    '.', ',', '?', '!', ';', ':'
  ];

  // Current state
  final RxString currentCharacter = ''.obs;
  final RxString feedback = ''.obs;
  final RxInt correct = 0.obs;
  final RxInt wrong = 0.obs;
  final RxDouble accuracy = 0.0.obs;
  final RxDouble cpm = 0.0.obs;
  // Removed difficulty system
  final RxBool isPracticeActive = false.obs;

  // Typing history
  final RxList<String> originalCharacters = <String>[].obs;
  final RxList<String> typedCharacters = <String>[].obs;

  // Controllers and timers
  final textController = TextEditingController();
  final Stopwatch stopwatch = Stopwatch();
  Timer? _feedbackTimer;
  Timer? _tickTimer;
  final Random _rand = Random();

  // Database and history
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final RxList<TypingTestModel> history = <TypingTestModel>[].obs;
  static const String testType = 'character';

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    resetPractice();
    _startTicker();
  }

  // Start the stats update timer
  void _startTicker() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (stopwatch.isRunning) updateStats();
    });
  }

  // Generate a new random character from the clear character set
  void generateNewCharacter() {
    currentCharacter.value = characterSet[_rand.nextInt(characterSet.length)];
    originalCharacters.add(currentCharacter.value);
  }

  // Handle user key input
  void onKeyTyped(String char) {
    if (char.isEmpty) return;

    // Start the test on first key press
    if (!stopwatch.isRunning) {
      stopwatch.start();
      isPracticeActive.value = true;
    }

    // Check if character is correct
    if (char == currentCharacter.value) {
      correct.value++;
      feedback.value = '✓ Correct';
    } else {
      wrong.value++;
      feedback.value = '✗ Wrong (expected: ${currentCharacter.value})';
    }

    typedCharacters.add(char);
    updateStats();
    generateNewCharacter();

    // Clear feedback after 1 second
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 1), () {
      feedback.value = '';
    });
  }

  // Reset practice session
  void resetPractice() {
    correct.value = 0;
    wrong.value = 0;
    accuracy.value = 0.0;
    cpm.value = 0.0;
    originalCharacters.clear();
    typedCharacters.clear();
    feedback.value = '';
    isPracticeActive.value = false;
    stopwatch.reset();
    textController.clear();
    generateNewCharacter();
  }

  // Update statistics
  void updateStats() {
    final total = correct.value + wrong.value;
    accuracy.value = total > 0 ? (correct.value / total) * 100 : 0.0;

    final minutes = stopwatch.elapsed.inSeconds / 60.0;
    cpm.value = minutes > 0 ? typedCharacters.length / minutes : 0.0;
  }

  // Save current session to database
  Future<void> saveCurrentSession() async {
    if (correct.value + wrong.value == 0) {
      Get.snackbar('Nothing to save', 'Type some characters first!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (stopwatch.isRunning) stopwatch.stop();
    isPracticeActive.value = false;
    updateStats();

    // Create test result
    final test = TypingTestModel(
      testType: testType,
      originalText: originalCharacters.join(' '),
      typedText: typedCharacters.join(' '),
      wpm: cpm.value / 5, // Convert CPM to WPM
      accuracy: accuracy.value,
      correctWords: correct.value,
      wrongWords: wrong.value,
      totalWords: correct.value + wrong.value,
      timeSeconds: stopwatch.elapsed.inSeconds,
      testDate: DateTime.now(),
    );

    // Save to database
    await _dbHelper.saveTypingTest(test);
    await loadHistory();

    Get.snackbar('Saved!', 'Your progress has been saved', snackPosition: SnackPosition.BOTTOM);
    resetPractice();
  }

  // Load history from database
  Future<void> loadHistory() async {
    try {
      history.value = await _dbHelper.getTypingHistory(testType);
    } catch (e) {
      history.clear();
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    await _dbHelper.clearHistory(testType);
    history.clear();
  }

  // Get colored text spans for display
  List<InlineSpan> getColoredText() {
    final spans = <InlineSpan>[];
    for (int i = 0; i < typedCharacters.length; i++) {
      final expected = i < originalCharacters.length ? originalCharacters[i] : '';
      final typed = typedCharacters[i];
      final isCorrect = typed == expected;

      spans.add(TextSpan(
        text: typed,
        style: TextStyle(
          color: isCorrect ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'Courier', // Monospace font for better character distinction
        ),
      ));

      if (i < typedCharacters.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }
    return spans;
  }

  // Backward compatibility methods for views
  List<TextSpan> getColoredTypedText() => getColoredText().cast<TextSpan>();
  Future<void> saveCurrentSessionManual({bool resetAfterSave = true}) async {
    await saveCurrentSession();
  }
  Future<void> clearAllHistory() => clearHistory();
  Future<void> deleteHistoryForDate(String dateKey) => clearHistory();

  @override
  void onClose() {
    _feedbackTimer?.cancel();
    _tickTimer?.cancel();
    stopwatch.stop();
    textController.dispose();
    super.onClose();
  }
}

// Helper class for colored text display
class ColoredTextController extends TextEditingController {
  final CharacterController controller;

  ColoredTextController(this.controller);

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, bool? withComposing}) {
    final spans = controller.getColoredText();
    return TextSpan(style: style, children: spans);
  }
}
