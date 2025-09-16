import 'package:typing_speed_test_app/import_export_file.dart';

class SentencePracticeView extends StatefulWidget {
  SentencePracticeView({Key? key}) : super(key: key);

  @override
  State<SentencePracticeView> createState() => _SentencePracticeViewState();
}

class _SentencePracticeViewState extends State<SentencePracticeView>
    with SingleTickerProviderStateMixin {
  final SentencePracticeController c = Get.put(SentencePracticeController());
  late AnimationController _animationController;

  // --- Beautiful color system for sentences (blue/indigo/purple theme) ---
  final Color _bgColor = const Color(0xFFF8FAFC);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _primary = const Color(0xFF3B82F6); // Blue
  final Color _primaryDark = const Color(0xFF1D4ED8); // Dark Blue
  final Color _indigo = const Color(0xFF6366F1); // Indigo
  final Color _indigoDark = const Color(0xFF4F46E5); // Dark Indigo
  final Color _purple = const Color(0xFF8B5CF6); // Purple
  final Color _purpleDark = const Color(0xFF7C3AED); // Dark Purple
  final Color _emerald = const Color(0xFF10B981); // Emerald
  final Color _emeraldDark = const Color(0xFF059669); // Dark Emerald
  final Color _rose = const Color(0xFFF43F5E); // Rose
  final Color _amber = const Color(0xFFF59E0B); // Amber

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

  Widget _buildStatCard(
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(child: valueWidget),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: TextStyle(
                        color: color.withOpacity(0.85),
                        fontSize: 13,
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

  Widget _buildTopStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildStatCard(
            'WPM',
            Obx(
              () => Text(
                c.wpm.value.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _emerald,
                ),
              ),
            ),
            _emerald,
            Icons.speed_outlined,
          ),
          _buildStatCard(
            'CPM',
            Obx(
              () => Text(
                c.cpm.value.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _amber,
                ),
              ),
            ),
            _amber,
            Icons.trending_up_outlined,
          ),
          _buildStatCard(
            'Accuracy',
            Obx(
              () => Text(
                '${c.accuracy.value.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
            ),
            _primary,
            Icons.analytics_outlined,
          ),
          _buildStatCard(
            'Progress',
            Obx(
              () => Text(
                '${c.currentWordIndex.value}/${c.words.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _purple,
                ),
              ),
            ),
            _purple,
            Icons.track_changes_outlined,
          ),
        ],
      ),
    );
  }

  // Helper function to get difficulty info based on word count
  Map<String, dynamic> _getDifficultyInfo(int wordCount) {
    if (wordCount <= 25) {
      return {
        'level': 'Easy',
        'color': _emerald,
        'icon': Icons.sentiment_satisfied_alt,
        'description': 'Perfect for beginners',
      };
    } else {
      return {
        'level': 'Medium',
        'color': _amber,
        'icon': Icons.sentiment_neutral,
        'description': 'Great for practice',
      };
    }
  }

  Widget _buildParagraphCard(Map<String, dynamic> paragraphData, int index) {
    final content = paragraphData['content'] as String;
    final title = paragraphData['title'] as String;
    final wordCount = content.split(RegExp(r'\s+')).length;
    final difficulty = _getDifficultyInfo(wordCount);
    final estimatedTime = (wordCount * 0.3)
        .ceil(); // Rough estimate: 0.3 seconds per word

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => c.startSession(paragraphData),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: difficulty['color'].withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: difficulty['color'].withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and difficulty
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            difficulty['color'],
                            difficulty['color'].withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: difficulty['color'].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        difficulty['icon'],
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : "Paragraph ${index + 1}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            difficulty['description'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Content preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: _textDark.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.format_list_numbered,
                      '$wordCount words',
                      _primary,
                    ),

                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_emerald, _emeraldDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _emerald.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_arrow, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Start Practice",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraphList() {
    return Obx(() {
      if (c.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(_primary),
                            backgroundColor: _primary.withOpacity(0.2),
                          ),
                        ),
                        Icon(Icons.download, color: _primary, size: 24),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Loading Practice Content",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fetching paragraphs for your typing practice...",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      if (c.paragraphList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _rose.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _rose.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline, color: _rose, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No Content Available",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Unable to load practice paragraphs.\nPlease check your internet connection.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => c.fetchParagraphs(),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 16, top: 8),
        itemCount: c.paragraphList.length,
        itemBuilder: (context, index) {
          final paragraphData = c.paragraphList[index];
          return _buildParagraphCard(paragraphData, index);
        },
      );
    });
  }

  Widget _buildTextDisplay() {
    return Obx(() {
      final remainingWords = c.words.sublist(c.currentWordIndex.value);
      final visible = remainingWords
          .take(12)
          .toList(); // Show fewer words for 3 lines
      final currentWord = c.currentWordIndex.value < c.words.length
          ? c.words[c.currentWordIndex.value]
          : '';

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryDark, _indigoDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with current word info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.keyboard, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Word: $currentWord",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Word ${c.currentWordIndex.value + 1} of ${c.words.length}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${((c.currentWordIndex.value / c.words.length) * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Enhanced text display with 3 lines
            Container(
              width: double.infinity,
              height: 120,
              // Fixed height for exactly 3 lines
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: RichText(
                textAlign: TextAlign.left,
                maxLines: 3, // Limit to exactly 3 lines
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    // Current word with styling
                    if (visible.isNotEmpty) ...[
                      ...c.getStyledCurrentWord(),
                      TextSpan(
                        text: ' ',
                        style: TextStyle(
                          backgroundColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                    // Upcoming words
                    TextSpan(
                      text: visible.skip(1).join(' '),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInputField() {
    return Obx(() {
      final currentWord = c.currentWordIndex.value < c.words.length
          ? c.words[c.currentWordIndex.value]
          : '';
      final isCorrect =
          c.userInput.value ==
          currentWord.substring(
            0,
            c.userInput.value.length.clamp(0, currentWord.length),
          );
      final inputColor = c.userInput.value.isEmpty
          ? Colors.white
          : isCorrect
          ? _emerald
          : _rose;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryDark, _indigoDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: inputColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: inputColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Input status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.edit,
                    color: inputColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    c.userInput.value.isEmpty
                        ? "Start typing the word: $currentWord"
                        : isCorrect
                        ? "Correct! Keep typing..."
                        : "Check your spelling",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const Spacer(),
                  if (c.userInput.value.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: inputColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${c.userInput.value.length}/${currentWord.length}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Enhanced input field
            TextField(
              autofocus: true,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: "Type here...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: c.updateInput,
              controller: TextEditingController()
                ..text = c.userInput.value
                ..selection = TextSelection.collapsed(
                  offset: c.userInput.value.length,
                ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(
      () => c.sessionStarted.value
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save, size: 20),
                    label: const Text(
                      'Save Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: _emerald.withOpacity(0.3),
                    ),
                    onPressed: () async {
                      // Calculate current stats and save immediately
                      c.calculateStats();
                      c.prepareLastSessionAndShow();
                      await c.saveCurrentSessionManual();
                      // Navigate to history after saving
                      Get.to(() => SentenceHistoryView(controller: c));
                      // Reset session
                      c.resetSession();
                    },
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  /// Result card shown when sessionCompleted == true
  Widget _buildResultCard() {
    return Obx(() {
      if (!c.sessionCompleted.value) return const SizedBox.shrink();
      final s = c.lastSession;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFF00695C)),
                    const SizedBox(width: 12),
                    const Text(
                      'Session Result',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      s['duration_label'] ?? '-',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard(
                      'WPM',
                      Text(
                        '${s['wpm'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Colors.green,
                      Icons.speed,
                    ),
                    _buildStatCard(
                      'CPM',
                      Text(
                        '${s['cpm'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Colors.orange,
                      Icons.trending_up,
                    ),
                    _buildStatCard(
                      'Accuracy',
                      Text(
                        '${s['accuracy'] ?? '-'}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C),
                        ),
                      ),
                      const Color(0xFF00695C),
                      Icons.percent,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Completed: ${s['completedWords']}/${s['totalWords']}',
                      ),
                    ),
                    Expanded(
                      child: Text('Correct chars: ${s['correctChars']}'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Preview: ${s['preview'] ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // discard and go back to paragraph list
                          c.resetSession();
                        },
                        child: const Text('Discard'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await c.saveCurrentSessionManual();
                          // after saving navigate to history
                          Get.to(() => SentenceHistoryView(controller: c));
                          // then clear the result
                          c.resetSession();
                        },
                        child: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00695C),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            leading: Obx(() {
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    c.sessionStarted.value ? Icons.close : Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                  tooltip: c.sessionStarted.value ? 'End session' : 'Go back',
                  onPressed: () =>
                      c.sessionStarted.value ? c.resetSession() : Get.back(),
                ),
              );
            }),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.edit_note, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  "Sentence Practice",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 22,
                  ),
                  tooltip: "History",
                  onPressed: () {
                    Get.to(() => SentenceHistoryView(controller: c));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (c.sessionStarted.value || c.sessionCompleted.value) {
            c.resetSession();
            return false;
          }
          return true;
        },
        child: Obx(() {
          // If not started and not completed -> show paragraph list
          if (!c.sessionStarted.value && !c.sessionCompleted.value) {
            return _buildParagraphList();
          }

          // If session completed show result card
          if (c.sessionCompleted.value) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildResultCard(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 88),
                      child: Column(children: [const SizedBox(height: 12)]),
                    ),
                  ),
                ],
              ),
            );
          }

          // Otherwise session is running
          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 88),
                    child: Column(
                      children: [
                        _buildTopStats(),
                        _buildTextDisplay(),
                        _buildInputField(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }
}

/// ====================== HISTORY VIEW (kept inside file for convenience) ======================
class SentenceHistoryView extends StatelessWidget {
  final SentencePracticeController controller;

  const SentenceHistoryView({Key? key, required this.controller})
    : super(key: key);

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

    final wpm = (session['wpm'] ?? 0).toString();
    final cpm = (session['cpm'] ?? 0).toString();
    final acc = (session['accuracy'] ?? 0).toString();
    final completed = session['completedWords']?.toString() ?? '-';
    final total = session['totalWords']?.toString() ?? '-';
    final dur = session['duration_label'] ?? '';

    final preview = session['preview']?.toString() ?? '';
    final typed =
        session['typed']?.toString() ?? ''; // <-- store typed text if available
    final original =
        session['original']?.toString() ?? preview; // Get original text

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(timeStr, style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(dur, style: const TextStyle(color: Colors.black54)),
          ],
        ),
        subtitle: Wrap(
          children: [
            _miniStat('WPM', wpm, Colors.green),
            _miniStat('CPM', cpm, Colors.orange),
            _miniStat('Accuracy', '$acc%', Colors.blueGrey),
            _miniStat('Words', '$completed / $total', Colors.teal),
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
                    Icon(Icons.menu_book, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      "Original Sentence",
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
                      "Typed Sentence (Red = Incorrect)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Show colored comparison if we have both original and typed text
                if (typed.isNotEmpty && original.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, height: 1.4),
                      children: controller.getColoredComparisonText(
                        original,
                        typed,
                      ),
                    ),
                  )
                else
                  Text(
                    typed.isNotEmpty ? typed : "—",
                    style: const TextStyle(fontSize: 14),
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
        title: const Text('Sentence History'),
        backgroundColor: const Color(0xFF009688),
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
            child: Text(
              'No history yet.\nSave sessions to see them here.',
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
                                if (confirm == true)
                                  await controller.deleteHistoryForDate(date);
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
