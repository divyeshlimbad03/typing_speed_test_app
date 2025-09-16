import 'package:typing_speed_test_app/import_export_file.dart';

class WordPracticeView extends StatefulWidget {
  WordPracticeView({Key? key}) : super(key: key);

  @override
  State<WordPracticeView> createState() => _WordPracticeViewState();
}

class _WordPracticeViewState extends State<WordPracticeView>
    with SingleTickerProviderStateMixin {
  final WordPracticeController c = Get.put(WordPracticeController());
  late AnimationController _animationController;

  // --- App color system matching character screen ---
  final Color _bgColor = const Color(0xFFF6F8FA);
  final Color _textDark = const Color(0xFF1F2937);
  final Color _primary = const Color(0xFF0EA5E9);
  final Color _primaryDark = const Color(0xFF0284C7);
  final Color _teal = const Color(0xFF14B8A6);
  final Color _tealDark = const Color(0xFF0D9488);
  final Color _amber = const Color(0xFFF59E0B);
  final Color _amberDark = const Color(0xFFD97706);
  final Color _indigo = const Color(0xFF6366F1);
  final Color _indigoDark = const Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _statCard(
    String title,
    Widget valueWidget,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _animationController.value) * 10),
            child: Opacity(
              opacity: _animationController.value,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(child: valueWidget),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        color: color.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.tune, size: 18, color: _textDark),
                const SizedBox(width: 8),
                Text(
                  'Practice Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildModeChip('Infinite', _teal),
              const SizedBox(width: 8),
              _buildModeChip('25 Words', _amber),
              const SizedBox(width: 8),
              _buildModeChip('50 Words', _indigo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, Color color) {
    bool selected = false;
    if (label == 'Infinite') {
      selected = c.isInfinite;
    } else if (label == '25 Words') {
      selected = !c.isInfinite && c.finiteCount == 25;
    } else if (label == '50 Words') {
      selected = !c.isInfinite && c.finiteCount == 50;
    }

    return GestureDetector(
      onTap: () {
        if (label == 'Infinite') {
          c.restartInfinite();
        } else if (label == '25 Words') {
          c.restartFinite(25);
        } else if (label == '50 Words') {
          c.restartFinite(50);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 18, color: _textDark),
              const SizedBox(width: 8),
              Text(
                'Session Preview',
                style: TextStyle(fontWeight: FontWeight.w700, color: _textDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_fields, size: 14, color: _primaryDark),
                      const SizedBox(width: 6),
                      Text(
                        'Original:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final revealed = c.originalWords.join(' ');
                    final revealedCount = c.originalWords.length;
                    final totalText = c.isInfinite
                        ? '∞'
                        : c.finiteCount.toString();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          revealed,
                          style: TextStyle(fontSize: 15, color: _textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$revealedCount / $totalText revealed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.keyboard, size: 14, color: _tealDark),
                      const SizedBox(width: 6),
                      Text(
                        'Typed:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _tealDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => RichText(
                      text: TextSpan(
                        children: c.getColoredTypedText(),
                        style: TextStyle(color: _textDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _statCard(
            'Correct',
            Obx(
              () => Text(
                '${c.correct.value}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _teal,
                ),
              ),
            ),
            _teal,
            Icons.check_circle_outline,
          ),
          _statCard(
            'Wrong',
            Obx(
              () => Text(
                '${c.wrong.value}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
            Colors.redAccent,
            Icons.cancel_outlined,
          ),
          _statCard(
            'Accuracy',
            Obx(
              () => Text(
                '${c.accuracy.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
            ),
            _primary,
            Icons.analytics_outlined,
          ),
          _statCard(
            'WPM',
            Obx(
              () => Text(
                c.wpm.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _indigo,
                ),
              ),
            ),
            _indigo,
            Icons.speed,
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard() {
    return Obx(() {
      final word = c.currentWord;
      final idx = c.currentIndex.value + 1;
      final totalText = c.isInfinite ? '∞' : c.finiteCount.toString();

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _animationController.value) * 20),
            child: Opacity(
              opacity: _animationController.value,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryDark, _primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Type This Word ($idx of $totalText)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Obx(() {
                      final s = c.sessionSeconds.value;
                      final mm = (s ~/ 60).toString().padLeft(2, '0');
                      final ss = (s % 60).toString().padLeft(2, '0');
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Time: $mm:$ss',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildInputField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _primary.withOpacity(0.15)),
      ),
      child: TextField(
        controller: c.inputController,
        focusNode: c.focusNode,
        autofocus: true,
        onChanged: c.onChanged,
        onSubmitted: c.onSubmitted,
        textAlign: TextAlign.center,
        cursorColor: _primary,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Type the word and press space...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
        ),
        title: const Text(
          'Word Practice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () => c.saveCurrentSessionManual(),
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save Session',
          ),
          IconButton(
            onPressed: () => Get.to(() => WordHistoryView(controller: c)),
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'View History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, bottom: 24),
        child: Column(
          children: [
            _buildTopStats(),
            _buildModeSelector(),
            _buildWordCard(),
            _buildInputField(),
            _buildHistoryPreview(),
          ],
        ),
      ),
    );
  }
}

/// ---------------- HISTORY SCREEN ----------------
class WordHistoryView extends StatelessWidget {
  final WordPracticeController controller;

  // Define colors for consistency
  final Color _primary = const Color(0xFF0EA5E9);
  final Color _teal = const Color(0xFF14B8A6);

  const WordHistoryView({Key? key, required this.controller}) : super(key: key);

  /// Create colored comparison text for words
  List<TextSpan> _getColoredWordsComparison(
    String originalWords,
    String typedWords,
  ) {
    final spans = <TextSpan>[];
    final originalList = originalWords.split(' ');
    final typedList = typedWords.split(' ');

    for (int i = 0; i < originalList.length; i++) {
      final originalWord = originalList[i];
      final typedWord = i < typedList.length ? typedList[i] : '';

      // Add space before word (except first word)
      if (i > 0) {
        spans.add(
          const TextSpan(
            text: ' ',
            style: TextStyle(color: Colors.black),
          ),
        );
      }

      // Compare words
      if (typedWord.isEmpty) {
        // Word not typed yet - show in gray
        spans.add(
          TextSpan(
            text: originalWord,
            style: const TextStyle(color: Colors.grey),
          ),
        );
      } else {
        // Show typed word with color based on correctness
        final isCorrect = originalWord.toLowerCase() == typedWord.toLowerCase();
        spans.add(
          TextSpan(
            text: typedWord,
            style: TextStyle(
              color: isCorrect ? Colors.black : Colors.red,
              fontWeight: isCorrect ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        );
      }
    }

    return spans;
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(Map<String, dynamic> session) {
    final ts = session['timestamp'] as String? ?? '';
    final dt = DateTime.tryParse(ts);
    final timeStr = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : ts;

    final total = session['total']?.toString() ?? '-';
    final correct = session['correct']?.toString() ?? '-';
    final wrong = session['wrong']?.toString() ?? '-';
    final accuracy = session['accuracy'] != null
        ? (session['accuracy'] as num).toStringAsFixed(2)
        : '-';
    final wpm = session['wpm'] != null
        ? (session['wpm'] as num).toStringAsFixed(2)
        : '-';
    final cpm = session['cpm'] != null
        ? (session['cpm'] as num).toStringAsFixed(2)
        : '-';

    final original = (session['originalWords'] as List?)?.join(' ') ?? '';
    final typed = (session['typedWords'] as List?)?.join(' ') ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(timeStr, style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(
              'Total: $total',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        subtitle: Wrap(
          children: [
            _miniStat('Correct', correct, Colors.green),
            _miniStat('Wrong', wrong, Colors.red),
            _miniStat('Accuracy', '$accuracy%', const Color(0xFF00BCD4)),
            _miniStat('WPM', wpm, const Color(0xFF009688)),
            _miniStat('CPM', cpm, Colors.indigo),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.text_snippet, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      "Original Words",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(original, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.keyboard, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      "Typed Words (Red = Incorrect)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Show colored comparison if we have both original and typed text
                if (original.isNotEmpty && typed.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, height: 1.4),
                      children: _getColoredWordsComparison(original, typed),
                    ),
                  )
                else
                  Text(typed, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Word History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Clear all history?'),
                  content: const Text(
                    'This will permanently delete all history for all days.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Yes, delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await controller.clearAllHistory();
                Get.back(); // close history screen
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No history yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save sessions to see them here',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final dates = controller.history.keys.toList()
          ..sort((a, b) => b.compareTo(a));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dates.length,
          itemBuilder: (context, idx) {
            final date = dates[idx];
            final sessions = controller.history[date] ?? [];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ExpansionTile(
                title: Text(
                  date,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${sessions.length} session(s)'),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_today, color: _primary, size: 18),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        ...sessions.map((s) => _sessionCard(s)).toList(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () async {
                                final confirm = await Get.dialog<bool>(
                                  AlertDialog(
                                    title: Text('Delete history for $date?'),
                                    content: const Text(
                                      'This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: const Text('No'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Get.back(result: true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await controller.deleteHistoryForDate(date);
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete Day'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
