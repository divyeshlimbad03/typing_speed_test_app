import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/typing_test_model.dart';
import 'history_view.dart';

class MovingWordHistoryScreen extends StatefulWidget {
  const MovingWordHistoryScreen({super.key});

  @override
  State<MovingWordHistoryScreen> createState() =>
      _MovingWordHistoryScreenState();
}

class _MovingWordHistoryScreenState extends State<MovingWordHistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<TypingTestModel> _history = [];
  bool _isLoading = true;
  static const String _testType = 'moving_word_vertical';

  // Color scheme for Moving Word history
  final Color _primary = const Color(0xFF8B5CF6);
  final Color _primaryDark = const Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _dbHelper.getTypingHistory(_testType);
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    try {
      await _dbHelper.clearHistory(_testType);
      await _loadHistory(); // Reload to show empty state

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
            'Are you sure you want to clear all Moving Word typing history? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearHistory();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moving Word History'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header section with stats
                  if (_history.isNotEmpty) _buildHeaderStats(),

                  // History content
                  Expanded(
                    child: HistoryView(
                      history: _history,
                      testType: 'Moving Word (Vertical)',
                      onClearHistory: _showClearDialog,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderStats() {
    // Simple basic stats - only Best WPM and Average Accuracy
    double avgAccuracy = _history.isEmpty
        ? 0.0
        : _history.map((e) => e.accuracy).reduce((a, b) => a + b) /
              _history.length;

    double bestWpm = _history.isEmpty
        ? 0.0
        : _history.map((e) => e.wpm).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: _primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Basic Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Simple stats - only Best WPM and Average Accuracy
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Best WPM',
                  bestWpm.toStringAsFixed(1),
                  Icons.speed,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  'Average Accuracy',
                  '${avgAccuracy.toStringAsFixed(1)}%',
                  Icons.adjust,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
