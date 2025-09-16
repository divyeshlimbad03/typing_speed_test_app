import 'package:typing_speed_test_app/import_export_file.dart';

// Simple History View Widget - shows typing test results
class HistoryView extends StatelessWidget {
  final List<TypingTestModel> history;
  final String testType;
  final VoidCallback? onClearHistory;

  const HistoryView({
    Key? key,
    required this.history,
    required this.testType,
    this.onClearHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No history yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Complete some ${testType} tests to see your results here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with clear button
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Test History (${history.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (onClearHistory != null)
                TextButton.icon(
                  onPressed: () => _showClearDialog(context),
                  icon: Icon(Icons.clear_all),
                  label: Text('Clear'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ),
        // History list
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final test = history[index];
              return _buildHistoryItem(context, test, index);
            },
          ),
        ),
      ],
    );
  }

  // Build individual history item
  Widget _buildHistoryItem(
    BuildContext context,
    TypingTestModel test,
    int index,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            // Test number
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Text(
                '${index + 1}',
                style: TextStyle(fontSize: 12, color: Colors.blue[800]),
              ),
            ),
            SizedBox(width: 12),
            // WPM and Accuracy
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${test.wpm.toStringAsFixed(2)} WPM • ${test.accuracy.toStringAsFixed(2)}% Accuracy',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${test.formattedTime} • ${test.dateString}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Score indicator
            _buildScoreIndicator(test.accuracy),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Words',
                      '${test.correctWords}/${test.totalWords}',
                      Colors.green,
                    ),
                    _buildStatItem('Errors', '${test.wrongWords}', Colors.red),
                    _buildStatItem('Time', test.formattedTime, Colors.blue),
                  ],
                ),
                SizedBox(height: 16),
                // Text comparison
                if (test.originalText.isNotEmpty && test.typedText.isNotEmpty)
                  _buildTextComparison(test),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build score indicator (color based on accuracy)
  Widget _buildScoreIndicator(double accuracy) {
    Color color;
    IconData icon;

    if (accuracy >= 95) {
      color = Colors.green;
      icon = Icons.star;
    } else if (accuracy >= 85) {
      color = Colors.orange;
      icon = Icons.trending_up;
    } else {
      color = Colors.red;
      icon = Icons.trending_down;
    }

    return Icon(icon, color: color, size: 24);
  }

  // Build individual stat item
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Build text comparison (original vs typed)
  Widget _buildTextComparison(TypingTestModel test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Comparison:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              SizedBox(height: 4),
              _buildComparisonText(test.originalText, test.typedText, true),
              SizedBox(height: 12),
              Text(
                'Your typing:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              SizedBox(height: 4),
              _buildComparisonText(test.originalText, test.typedText, false),
            ],
          ),
        ),
      ],
    );
  }

  // Build comparison text with error highlighting
  Widget _buildComparisonText(
    String original,
    String typed,
    bool showOriginal,
  ) {
    List<String> originalWords = original.split(' ');
    List<String> typedWords = typed.split(' ');

    List<InlineSpan> spans = [];

    for (int i = 0; i < originalWords.length; i++) {
      if (i > 0) spans.add(TextSpan(text: ' '));

      String originalWord = originalWords[i];
      String typedWord = i < typedWords.length ? typedWords[i] : '';

      bool isCorrect = originalWord.toLowerCase() == typedWord.toLowerCase();
      bool isMissing = typedWord.isEmpty;

      Color textColor;
      FontWeight fontWeight = FontWeight.normal;

      if (showOriginal) {
        // Show original text with error highlighting
        if (isMissing) {
          textColor = Colors.grey[400]!; // Missing words in gray
        } else if (isCorrect) {
          textColor = Colors.green[700]!; // Correct words in green
        } else {
          textColor = Colors.red[700]!; // Wrong words in red
          fontWeight = FontWeight.w600;
        }
        spans.add(
          TextSpan(
            text: originalWord,
            style: TextStyle(color: textColor, fontWeight: fontWeight),
          ),
        );
      } else {
        // Show typed text
        if (isMissing) {
          spans.add(
            TextSpan(
              text: '[missed]',
              style: TextStyle(
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        } else {
          textColor = isCorrect ? Colors.green[700]! : Colors.red[700]!;
          fontWeight = isCorrect ? FontWeight.normal : FontWeight.w600;
          spans.add(
            TextSpan(
              text: typedWord,
              style: TextStyle(color: textColor, fontWeight: fontWeight),
            ),
          );
        }
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: Colors.black87),
        children: spans,
      ),
    );
  }

  // Show clear history confirmation dialog
  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content: Text(
          'Are you sure you want to clear all ${testType} test history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClearHistory?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
