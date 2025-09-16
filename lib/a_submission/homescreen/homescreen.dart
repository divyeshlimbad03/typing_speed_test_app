import 'package:typing_speed_test_app/import_export_file.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

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

  Widget _buildPracticeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animationController.value) * 20),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(24),
                  splashColor: gradientColors.last.withOpacity(0.25),
                  highlightColor: gradientColors.first.withOpacity(0.08),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
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
                          child: Icon(icon, size: 25, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "Start",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 9,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: _textDark),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: iconColor.withOpacity(0.75),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: Drawer(
        elevation: 15,
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryDark, _tealDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: _primaryDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Welcome!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events, color: _amber, size: 14),
                              const SizedBox(width: 8),
                              const Text(
                                "Ready to improve your skills?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDrawerItem(
                      'Keyboard Setup',
                      Icons.keyboard_alt,
                      _tealDark,
                      () {
                        Navigator.of(context).pop();
                        Get.to(() => KeyboardSetupScreen());
                      },
                    ),
                    _buildDrawerItem(
                      'About / Help',
                      Icons.info_outline,
                      _primaryDark,
                      () {
                        Navigator.of(context).pop();
                        Get.to(() => AboutUs());
                      },
                    ),
                    _buildDrawerItem('Feedback', Icons.feedback, _tealDark, () {
                      Navigator.of(context).pop();
                      Get.to(() => FeedbackView());
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 100,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.12),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.28),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.keyboard_alt,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Typing Master",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Improve your typing skills",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.fitness_center_rounded,
                              color: _primaryDark,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Practice Modes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildPracticeCard(
                        icon: Icons.abc,
                        title: 'Character Practice',
                        subtitle: 'Master individual keys and improve accuracy',
                        gradientColors: [_primaryDark, _primary],
                        onTap: () => Get.to(() => CharacterView()),
                      ),
                      _buildPracticeCard(
                        icon: Icons.text_fields_rounded,
                        title: 'Word Practice',
                        subtitle: 'Build speed with common words',
                        gradientColors: [_tealDark, _teal],
                        onTap: () => Get.to(() => WordPracticeView()),
                      ),
                      _buildPracticeCard(
                        icon: Icons.notes_rounded,
                        title: 'Sentence Practice',
                        subtitle: 'Practice full sentences and punctuation',
                        gradientColors: [_indigoDark, _indigo],
                        onTap: () => Get.to(() => SentencePracticeView()),
                      ),
                      _buildPracticeCard(
                        icon: Icons.pin_rounded,
                        title: 'Number Practice',
                        subtitle: 'Improve typing on numeric keypad',
                        gradientColors: [_amberDark, _amber],
                        onTap: () => Get.to(() => NumberPracticeView()),
                      ),
                      _buildPracticeCard(
                        icon: Icons.vertical_align_center,
                        title: 'Moving Word Practice',
                        subtitle: 'Type words as they fall from top to bottom',
                        gradientColors: [
                          const Color(0xFF8B5CF6),
                          const Color(0xFFA78BFA),
                        ],

                        onTap: () => Get.to(() => MovingWordViewScreen()),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
