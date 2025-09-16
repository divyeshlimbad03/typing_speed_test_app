import 'package:typing_speed_test_app/import_export_file.dart';

class KeyboardSetupScreen extends StatelessWidget {
  const KeyboardSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 6,
          title: const Row(
            children: [
              Icon(Icons.keyboard_alt_rounded, size: 26, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Keyboard & OTG Setup",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              title: "Keyboard Setup",
              content:
                  "To use this app, connect a desktop keyboard to your mobile using an OTG cable. If you don't have them, you can purchase them online or offline. Once connected, this app functions like a computer.",
            ),
            Center(
              child: _buildImageCard(
                context,
                "assets/images/keyboard.jpg",
                "Desktop Keyboard",
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: _buildImageCard(
                context,
                "assets/images/otg_cable.webp",
                "OTG Cable",
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoCard(
              context,
              title: "Bluetooth Keyboard Setup",
              content:
                  "1. Turn on Bluetooth on your keyboard.\n"
                  "2. Open Settings > Bluetooth on your mobile.\n"
                  "3. Pair your keyboard from the list.\n"
                  "4. Return to this app and start typing.\n\n"
                  "Note: No OTG cable is required for Bluetooth keyboards.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, String assetPath, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "-: $label :-",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          Image.asset(assetPath, height: 120),
        ],
      ),
    );
  }
}
