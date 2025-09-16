import 'package:typing_speed_test_app/import_export_file.dart';
import 'services/api_service.dart';

class SentencePracticeController extends GetxController {
  // Remote content from API
  final RxList<Map<String, dynamic>> paragraphList =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  // Typing logic
  final RxList<String> words = <String>[].obs;
  final RxInt currentWordIndex = 0.obs;
  final RxString userInput = ''.obs;

  // Add a variable to store the full typed sentence
  final RxString typedSentence = ''.obs; // <--- ADDED THIS LINE

  // Store original sentence for comparison
  String originalSentence = '';

  // Use a default Stopwatch instance to avoid null checks in view
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;

  final RxInt correctCharCount = 0.obs;
  final RxInt totalCharTyped = 0.obs;
  final RxInt correctWordCount = 0.obs;

  final RxDouble wpm = 0.0.obs;
  final RxDouble cpm = 0.0.obs;
  final RxDouble accuracy = 0.0.obs;

  final RxBool sessionStarted = false.obs;

  // session completed (show result card)
  final RxBool sessionCompleted = false.obs;

  // last session summary (used for result card and for saving)
  final RxMap<String, dynamic> lastSession = <String, dynamic>{}.obs;

  // ----------------- History (GetStorage) -----------------
  final _box = GetStorage();
  final String _storageKey = 'sentence_history_v1';

  /// history map: { 'YYYY-MM-DD' : [ { session... }, ... ] }
  final RxMap<String, List<Map<String, dynamic>>> history =
      <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _ensureStorage().then((_) => _loadHistory());
    fetchParagraphs();
  }

  Future<void> _ensureStorage() async {
    try {
      await GetStorage.init();
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadHistory() async {
    final raw = _box.read(_storageKey);
    if (raw is Map) {
      final casted = <String, List<Map<String, dynamic>>>{};
      raw.forEach((k, v) {
        final list = <Map<String, dynamic>>[];
        if (v is List) {
          for (final item in v) {
            if (item is Map) {
              list.add(item.map((key, value) => MapEntry('$key', value)));
            }
          }
        }
        casted['$k'] = list;
      });
      history.assignAll(casted);
    } else {
      history.clear();
    }
  }

  Future<void> _persistHistory() async {
    await _box.write(_storageKey, history);
  }

  Future<void> clearAllHistory() async {
    history.clear();
    await _persistHistory();
  }

  Future<void> deleteHistoryForDate(String date) async {
    history.remove(date);
    await _persistHistory();
  }

  Future<void> saveCurrentSessionManual() async {
    // Ensure lastSession has data
    if (lastSession.isEmpty) {
      Get.snackbar(
        'Nothing to save',
        'No finished session to save',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final now = DateTime.now();
    final dateKey =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final session = Map<String, dynamic>.from(lastSession);

    final list = history[dateKey] ?? <Map<String, dynamic>>[];
    // insert at front to show latest first
    list.insert(0, session);
    history[dateKey] = list;
    await _persistHistory();

    Get.snackbar(
      'Saved',
      'Session saved to history',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ----------------- Fetch content from API -----------------
  Future<void> fetchParagraphs() async {
    isLoading.value = true;
    try {
      final paragraphs = await ApiService.fetchParagraphs();
      paragraphList.value = paragraphs;
    } catch (e) {
      paragraphList.clear();
      Get.snackbar(
        'Error',
        'Failed to load paragraphs: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------- Session logic -----------------
  void startSession(Map<String, dynamic> paragraphData) {
    final content = paragraphData['content'] as String;
    sessionStarted.value = true;
    sessionCompleted.value = false;
    lastSession.clear();

    words.value = content.trim().split(RegExp(r'\s+'));
    originalSentence = content.trim(); // Store original sentence
    currentWordIndex.value = 0;
    userInput.value = '';
    typedSentence.value = ''; // <--- RESET typedSentence HERE
    correctCharCount.value = 0;
    totalCharTyped.value = 0;
    correctWordCount.value = 0;

    stopwatch = Stopwatch()..start();

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => calculateStats());
  }

  /// Public: prepare final stats and mark sessionCompleted.
  /// This was previously private; now it's public so View can call it.
  void prepareLastSessionAndShow() {
    // compute final stats first
    calculateStats();

    final now = DateTime.now();
    final elapsed = stopwatch.elapsed;
    lastSession.assignAll({
      'timestamp': now.toIso8601String(),
      'wpm': double.parse(wpm.value.toStringAsFixed(2)),
      'cpm': double.parse(cpm.value.toStringAsFixed(2)),
      'accuracy': double.parse(accuracy.value.toStringAsFixed(2)),
      'totalWords': words.length,
      'completedWords': currentWordIndex.value,
      'correctChars': correctCharCount.value,
      'totalCharsTyped': totalCharTyped.value,
      'duration_seconds': elapsed.inSeconds,
      'duration_label':
          '${(elapsed.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
      'preview': words.take(20).join(' '),
      'typed': typedSentence.value, // <--- ADDED THIS LINE
      'original': originalSentence, // Store original sentence for comparison
    });

    // stop timers
    if (stopwatch.isRunning) stopwatch.stop();
    timer?.cancel();

    // mark completed so view can show result card
    sessionCompleted.value = true;
    sessionStarted.value = false;
  }

  void updateInput(String input) {
    // keep raw for UI
    userInput.value = input;

    // Only count actual new typed characters toward totalCharTyped.
    // (This is a simple heuristic — you may improve detection later.)
    totalCharTyped.value++;

    // Word boundary: user pressed space
    if (input.endsWith(' ')) {
      final typedWord = input.trimRight();
      final expected = currentWordIndex.value < words.length
          ? words[currentWordIndex.value]
          : '';

      if (typedWord.isNotEmpty) {
        // count correct characters in the word (position-wise)
        final minLen = typedWord.length < expected.length
            ? typedWord.length
            : expected.length;
        for (int i = 0; i < minLen; i++) {
          if (typedWord[i] == expected[i]) {
            correctCharCount.value++;
          }
        }
      }

      // Word is considered correct only if full match
      if (typedWord == expected) {
        correctWordCount.value++;
      }

      // Append the typed word to the full typed sentence
      typedSentence.value += typedWord + ' '; // <--- ADDED THIS LINE

      // Advance to next word
      currentWordIndex.value++;

      // Clear input for next word
      userInput.value = '';

      // Completed the whole paragraph
      if (currentWordIndex.value >= words.length) {
        // compute final stats and prepare lastSession
        calculateStats();
        prepareLastSessionAndShow();
      }
    }
  }

  void calculateStats() {
    final minutes = (stopwatch.elapsed.inSeconds) / 60.0;
    if (minutes > 0) {
      wpm.value = correctWordCount.value / minutes;
      cpm.value = correctCharCount.value / minutes;
      accuracy.value = totalCharTyped.value > 0
          ? (correctCharCount.value / totalCharTyped.value) * 100
          : 0;
    } else {
      wpm.value = 0.0;
      cpm.value = 0.0;
      accuracy.value = 0.0;
    }
  }

  List<InlineSpan> getStyledCurrentWord() {
    if (currentWordIndex.value >= words.length) return const <InlineSpan>[];
    final original = words[currentWordIndex.value];
    final typed = userInput.value;
    final spans = <InlineSpan>[];

    for (int i = 0; i < original.length; i++) {
      if (i < typed.length) {
        spans.add(
          TextSpan(
            text: original[i],
            style: TextStyle(
              color: typed[i] == original[i]
                  ? const Color(0xFF80DEEA)
                  : Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      } else {
        spans.add(
          const TextSpan(
            text: '',
            style: TextStyle(color: Colors.white),
          ),
        );
        // Append the remaining characters as a single span of white text
        spans.add(
          TextSpan(
            text: original.substring(i),
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      }
    }
    return spans;
  }

  void resetSession() {
    sessionStarted.value = false;
    sessionCompleted.value = false;
    words.clear();
    originalSentence = ''; // Reset original sentence
    currentWordIndex.value = 0;
    userInput.value = '';
    typedSentence.value = ''; // <--- RESET typedSentence HERE
    correctCharCount.value = 0;
    totalCharTyped.value = 0;
    correctWordCount.value = 0;
    wpm.value = 0.0;
    cpm.value = 0.0;
    accuracy.value = 0.0;
    timer?.cancel();
    if (stopwatch.isRunning) stopwatch.stop();
    stopwatch = Stopwatch();
    lastSession.clear();
  }

  @override
  void onClose() {
    timer?.cancel();
    if (stopwatch.isRunning) stopwatch.stop();
    super.onClose();
  }

  /// Create a RichText widget that shows the comparison between original and typed text
  /// Red for incorrect characters, black for correct ones
  List<TextSpan> getColoredComparisonText(
    String originalText,
    String typedText,
  ) {
    final spans = <TextSpan>[];
    final originalWords = originalText.split(' ');
    final typedWords = typedText.trim().split(' ');

    for (int i = 0; i < originalWords.length; i++) {
      final originalWord = originalWords[i];
      final typedWord = i < typedWords.length ? typedWords[i] : '';

      // Add space before word (except first word)
      if (i > 0) {
        spans.add(
          const TextSpan(
            text: ' ',
            style: TextStyle(color: Colors.black),
          ),
        );
      }

      // Compare word character by character
      if (typedWord.isEmpty) {
        // Word not typed yet - show in gray
        spans.add(
          TextSpan(
            text: originalWord,
            style: const TextStyle(color: Colors.grey),
          ),
        );
      } else {
        // Word was typed - compare character by character
        final maxLength = originalWord.length > typedWord.length
            ? originalWord.length
            : typedWord.length;

        for (int j = 0; j < maxLength; j++) {
          if (j < originalWord.length && j < typedWord.length) {
            // Both have character at this position
            final originalChar = originalWord[j];
            final typedChar = typedWord[j];
            spans.add(
              TextSpan(
                text: originalChar,
                style: TextStyle(
                  color: originalChar.toLowerCase() == typedChar.toLowerCase()
                      ? Colors.black
                      : Colors.red,
                  fontWeight:
                      originalChar.toLowerCase() == typedChar.toLowerCase()
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            );
          } else if (j < originalWord.length) {
            // Original has more characters (typed word is shorter)
            spans.add(
              TextSpan(
                text: originalWord[j],
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }
          // If typed word is longer, we ignore extra characters
        }
      }
    }

    return spans;
  }
}
