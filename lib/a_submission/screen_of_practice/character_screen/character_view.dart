import 'package:typing_speed_test_app/import_export_file.dart';

class CharacterView extends StatefulWidget {
  CharacterView({Key? key}) : super(key: key);

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView>
    with SingleTickerProviderStateMixin {
  final CharacterController controller = Get.put(CharacterController());
  late final ColoredTextController coloredController = ColoredTextController(
    controller,
  );
  late AnimationController _animationController;

  // --- App color system matching homescreen ---
  final Color _bgColor = const Color(0xFFF6F8FA);
  final Color _textDark = const Color(0xFF1F2937);
  final Color _primary = const Color(0xFF0EA5E9);
  final Color _primaryDark = const Color(0xFF0284C7);
  final Color _teal = const Color(0xFF14B8A6);
  final Color _tealDark = const Color(0xFF0D9488);
  final Color _amber = const Color(0xFFF59E0B);

  final Color _indigo = const Color(0xFF6366F1);

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

  // Removed difficulty chip builder

  Widget _buildTopStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _statCard(
            'Correct',
            Obx(
              () => Text(
                '${controller.correct.value}',
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
                '${controller.wrong.value}',
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
                '${controller.accuracy.value.toStringAsFixed(0)}%',
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
            'CPM',
            Obx(
              () => Text(
                controller.cpm.value.toStringAsFixed(0),
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

  // Removed difficulty selector

  Widget _buildCharacterCard() {
    return Obx(() {
      final ch = controller.currentCharacter.value;
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
                          'Type This Character',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.22),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(child: _buildCharacterDisplay(ch)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // Enhanced character display with monospace font for better distinction
  Widget _buildCharacterDisplay(String character) {
    // Special handling for confusing characters
    final bool isConfusingChar = [
      'I',
      'l',
      'L',
      '1',
      'i',
      'O',
      '0',
      'o',
    ].contains(character);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main character display with monospace font
        Text(
          character,
          style: TextStyle(
            fontSize: isConfusingChar ? 36 : 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'Courier',
            // Monospace font for better character distinction
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
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
        controller: coloredController,
        autofocus: true,
        textAlign: TextAlign.center,
        cursorColor: _primary,
        onChanged: (val) {
          // determine newly typed char
          final typedLen = controller.typedCharacters.length;
          if (val.length > typedLen) {
            final newChar = val.characters.last;
            controller.onKeyTyped(newChar);
          }
          // keep the controller in sync with stored typedCharacters
          coloredController.text = controller.typedCharacters.join();
          coloredController.selection = TextSelection.collapsed(
            offset: coloredController.text.length,
          );
        },
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textDark,
          fontFamily:
              'Courier', // Monospace font for better character distinction
        ),
        decoration: InputDecoration(
          hintText: 'Type here...',
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
                  Obx(
                    () => Text(
                      controller.originalCharacters.join(''),
                      style: TextStyle(
                        fontSize: 15,
                        color: _textDark,
                        fontFamily: 'Courier', // Monospace font
                      ),
                    ),
                  ),
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
                        children: controller.getColoredTypedText(),
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

  // ------------------- Bottom Bar (Save & History) -------------------
  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () => controller.saveCurrentSessionManual(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.history, color: _primary),
                label: Text('History', style: TextStyle(color: _primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: _primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () =>
                    Get.to(() => CharacterHistoryView(controller: controller)),
              ),
            ),
          ],
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
          'Character Practice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.saveCurrentSession(),
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save Session',
          ),
          IconButton(
            onPressed: () =>
                Get.to(() => CharacterHistoryView(controller: controller)),
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
            const SizedBox(height: 10),
            _buildCharacterCard(),
            _buildInputField(),
            _buildHistoryPreview(),
          ],
        ),
      ),
    );
  }
}

/// ---------------- History Screen ----------------
class CharacterHistoryView extends StatelessWidget {
  final CharacterController controller;

  const CharacterHistoryView({Key? key, required this.controller})
    : super(key: key);

  List<TextSpan> _getColoredCharactersComparison(
    String originalChars,
    String typedChars,
  ) {
    final spans = <TextSpan>[];
    final originalList = originalChars.split(' ');
    final typedList = typedChars.split(' ');

    for (int i = 0; i < originalList.length; i++) {
      final originalChar = originalList[i];
      final typedChar = i < typedList.length ? typedList[i] : '';

      // Add space before character (except first character)
      if (i > 0) {
        spans.add(
          const TextSpan(
            text: ' ',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Courier', // Monospace font
            ),
          ),
        );
      }

      // Compare characters
      if (typedChar.isEmpty) {
        // Character not typed yet - show in gray
        spans.add(
          TextSpan(
            text: originalChar,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier', // Monospace font
            ),
          ),
        );
      } else {
        // Show typed character with color based on correctness
        final isCorrect = originalChar == typedChar;
        spans.add(
          TextSpan(
            text: typedChar,
            style: TextStyle(
              color: isCorrect ? Colors.black : Colors.red,
              fontWeight: isCorrect ? FontWeight.normal : FontWeight.bold,
              fontFamily: 'Courier', // Monospace font
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

    final difficulty = session['difficulty'] ?? '-';
    final total = session['total']?.toString() ?? '-';
    final correct = session['correct']?.toString() ?? '-';
    final wrong = session['wrong']?.toString() ?? '-';
    final accuracy = session['accuracy'] != null
        ? (session['accuracy'] as num).toStringAsFixed(2)
        : '-';
    final cpm = session['cpm'] != null
        ? (session['cpm'] as num).toStringAsFixed(2)
        : '-';

    final original = (session['original'] as List?)?.join(' ') ?? '';
    final typed = (session['typed'] as List?)?.join(' ') ?? '';

    // Difficulty colors
    Color difficultyColor;
    switch (difficulty) {
      case 'Easy':
        difficultyColor = const Color(0xFF14B8A6); // teal
        break;
      case 'Medium':
        difficultyColor = const Color(0xFFF59E0B); // amber
        break;
      case 'Confusing':
        difficultyColor = const Color(0xFF6366F1); // indigo
        break;
      default:
        difficultyColor = const Color(0xFF0EA5E9); // primary
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            Text(timeStr, style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: difficultyColor.withOpacity(0.2)),
              ),
              child: Text(
                difficulty,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: difficultyColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _miniStat('Correct', correct, const Color(0xFF14B8A6)),
            _miniStat('Wrong', wrong, Colors.redAccent),
            _miniStat('Accuracy', '$accuracy%', const Color(0xFF0EA5E9)),
            _miniStat('CPM', cpm, const Color(0xFF6366F1)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.text_snippet, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      "Original Characters",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(original, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.keyboard, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      "Typed Characters (Red = Incorrect)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Show colored comparison if we have both original and typed text
                if (original.isNotEmpty && typed.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontFamily:
                            'Courier', // Monospace font for better character distinction
                      ),
                      children: _getColoredCharactersComparison(
                        original,
                        typed,
                      ),
                    ),
                  )
                else
                  Text(
                    typed,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily:
                          'Courier', // Monospace font for better character distinction
                    ),
                  ),
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
          'Character History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0EA5E9),
        // _primary
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Clear all history?'),
                  content: const Text(
                    'This will permanently delete all saved history.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text('Yes, delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await controller.clearAllHistory();
                Get.back();
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
                Icon(Icons.history, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No history yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete some character tests to see your results here',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return HistoryView(
          history: controller.history,
          testType: 'character',
          onClearHistory: () => controller.clearHistory(),
        );
      }),
    );
  }
}
