import 'package:typing_speed_test_app/import_export_file.dart';

class NumberPracticeView extends StatelessWidget {
  NumberPracticeView({Key? key}) : super(key: key);

  final NumberPracticeController controller = Get.put(
    NumberPracticeController(),
  );

  Widget _statCard(
    String label,
    Widget valueWidget,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            FittedBox(child: valueWidget),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.darken(0.35)),
            ),
          ],
        ),
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
                '${controller.correct.value}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14B8A6),
                ),
              ),
            ),
            Icons.check_circle_outline,
            Color(0xFF14B8A6),
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
            Icons.cancel_outlined,
            Colors.redAccent,
          ),
          _statCard(
            'Accuracy',
            Obx(
              () => Text(
                '${controller.accuracy.value.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0EA5E9),
                ),
              ),
            ),
            Icons.percent,
            const Color(0xFF0EA5E9),
          ),
          _statCard(
            'CPM',
            Obx(
              () => Text(
                controller.cpm.value.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
            Icons.speed,
            const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Obx(() {
      final progressText = '${controller.totalAttempts.value} entries';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          children: [
            const Text(
              'Progress',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              progressText,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Spacer(),
            if (controller.isPracticeActive.value)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Running',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildNumberCard() {
    return Obx(() {
      final displayed = controller.currentNumber.value;
      final isActive = controller.isPracticeActive.value;
      final elapsed = controller.stopwatch.elapsed.inSeconds;
      final mm = (elapsed ~/ 60).toString().padLeft(2, '0');
      final ss = (elapsed % 60).toString().padLeft(2, '0');

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00BCD4), Color(0xFF009688)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Text(
                'Type This Number',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: Text(
                  displayed,
                  key: ValueKey(displayed),
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),

              Text(
                '${displayed.length} digits',
                style: TextStyle(color: Colors.white.withOpacity(0.90)),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$mm:$ss',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInputBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller.textController,
        keyboardType: TextInputType.number,
        autofocus: true,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        onChanged: controller.onInputChanged,
        decoration: InputDecoration(
          hintText: 'Type the number and press space',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSessionPreviewCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.list_alt, color: Color(0xFF00BCD4)),
              SizedBox(width: 8),
              Text(
                'Original Numbers',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Obx(() {
            final text = controller.originalNumbers.join(' ');
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, letterSpacing: 1.2),
              ),
            );
          }),
          const SizedBox(height: 5),
          Row(
            children: const [
              Icon(Icons.keyboard, color: Color(0xFF009688)),
              SizedBox(width: 8),
              Text(
                'Your Typing',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Obx(() {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: RichText(
                text: TextSpan(
                  children: controller.getColoredTypedText(),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold with gradient appbar
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 6,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
        ),
        title: Row(
          children: const [
            Text(
              'Number Practice',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => controller.saveCurrentSessionManual(),
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save Session',
          ),
          IconButton(
            onPressed: () =>
                Get.to(() => NumberHistoryView(controller: controller)),
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'View History',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              _buildTopStats(),
              _buildProgress(),
              _buildNumberCard(),
              _buildInputBox(),
              _buildSessionPreviewCards(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- HISTORY SCREEN ----------------
class NumberHistoryView extends StatelessWidget {
  final NumberPracticeController controller;

  const NumberHistoryView({Key? key, required this.controller})
    : super(key: key);

  /// Create colored comparison text for numbers
  List<TextSpan> _getColoredNumbersComparison(
    String originalNumbers,
    String typedNumbers,
  ) {
    final spans = <TextSpan>[];
    final originalList = originalNumbers.split(' ');
    final typedList = typedNumbers.split(' ');

    for (int i = 0; i < originalList.length; i++) {
      final originalNumber = originalList[i];
      final typedNumber = i < typedList.length ? typedList[i] : '';

      // Add space before number (except first number)
      if (i > 0) {
        spans.add(
          const TextSpan(
            text: ' ',
            style: TextStyle(color: Colors.black),
          ),
        );
      }

      // Compare numbers
      if (typedNumber.isEmpty) {
        // Number not typed yet - show in gray
        spans.add(
          TextSpan(
            text: originalNumber,
            style: const TextStyle(color: Colors.grey),
          ),
        );
      } else {
        // Show typed number with color based on correctness
        final isCorrect = originalNumber == typedNumber;
        spans.add(
          TextSpan(
            text: typedNumber,
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

  Widget _miniStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Text(
            '$title: ',
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
    final cpm = session['cpm'] != null
        ? (session['cpm'] as num).toStringAsFixed(2)
        : '-';

    final original = (session['originalNumbers'] as List?)?.join(' ') ?? '';
    final typed = (session['typedNumbers'] as List?)?.join(' ') ?? '';

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
            _miniStat('CPM', cpm, const Color(0xFF009688)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.list_alt, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      "Original Numbers",
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
                      "Typed Numbers (Red = Incorrect)",
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
                      children: _getColoredNumbersComparison(original, typed),
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
        title: const Text('Practice History'),
        centerTitle: false,
        backgroundColor: const Color(0xFF009688),
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
            child: Text(
              'No saved sessions yet.\nComplete a practice to store sessions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        final dates = controller.history.keys.toList()
          ..sort((a, b) => b.compareTo(a));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: dates.length,
          itemBuilder: (context, idx) {
            final date = dates[idx];
            final sessions = controller.history[date] ?? [];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(
                  date,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${sessions.length} session(s)'),
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

/// ---------------- Extension helper for color darken ----------------
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
