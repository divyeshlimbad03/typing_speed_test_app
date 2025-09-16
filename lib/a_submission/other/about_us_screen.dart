import 'package:typing_speed_test_app/import_export_file.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutusState();
}

class _AboutusState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, size: 26, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "About Us",
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/darshanlogo.png'),
            ),
            const SizedBox(height: 20),
            Text(
              'Divyesh Limbad',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Student | Developer | Darshan University',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Our Contributors'),
            _buildInfoCard(context, [
              _infoText(
                context,
                'Developed by',
                'Divyesh Limbad (23010101151)',
              ),
              _infoText(context, 'Mentored by', 'Prof. Mehul Bhundiya'),
              _infoText(context, 'Explored by', 'ASWDC, Darshan University'),
              _infoText(
                context,
                'Eulogized by',
                'Darshan University, Gujarat, INDIA',
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'About ASWDC'),
            _buildTextCard(
              context,
              Icons.info_outline,
              'ASWDC is the Application, Software and Website Development Center at Darshan University. '
              'It’s run by students and staff of the School of Computer Science to bridge the gap between curriculum and industry.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Contact Us'),
            _buildContactCard(context, [
              {'icon': Icons.email, 'text': 'aswdc@darshan.ac.in'},
              {'icon': Icons.phone, 'text': '+91-9727747317'},
              {'icon': Icons.language, 'text': 'www.darshan.ac.in'},
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Follow Us'),
            _buildContactCard(context, [
              {'icon': Icons.share, 'text': 'Share App'},
              {'icon': Icons.apps, 'text': 'More Apps'},
              {'icon': Icons.star, 'text': 'Rate Us'},
              {'icon': Icons.thumb_up, 'text': 'Like us on Facebook'},
              {'icon': Icons.system_update, 'text': 'Check for Update'},
            ]),
            const SizedBox(height: 30),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF512DA8),
          ),
        ),
      ),
    );
  }

  Widget _infoText(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(top: 12),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextCard(BuildContext context, IconData icon, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF512DA8)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(item['icon'], color: const Color(0xFF512DA8)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['text'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Divider(thickness: 1.2),
        const SizedBox(height: 10),
        Text(
          '© 2025 Darshan University',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'All Rights Reserved - Privacy Policy',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Made with ', style: TextStyle(fontSize: 16)),
            Icon(Icons.favorite, color: Colors.red, size: 20),
            Text(' in India', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
