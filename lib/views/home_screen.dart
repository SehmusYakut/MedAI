import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ocr_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isLoadingSession = true;
  String _academicTrack = '';
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    // 500ms lightweight simulated check to display the skeleton loader
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _academicTrack = prefs.getString('academic_track') ?? '';
        _isLoadingSession = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _GeometricVectorLogo(size: 28),
            const SizedBox(width: 8),
            Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile Settings',
          ),
        ],
      ),
      body: _isLoadingSession
          ? _buildSkeletonLoader()
          : FadeTransition(
              opacity: const AlwaysStoppedAnimation(1.0),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Welcome Header
                  _buildWelcomeHeader(isDark),
                  const SizedBox(height: 24),

                  // Dashboard Cards Section
                  _buildDashboardSection(context, l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFE0F2FE), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Doctor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0369A1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _academicTrack.isNotEmpty
                ? 'Current Track: $_academicTrack'
                : 'Select your curriculum track in settings',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF0284C7),
              fontWeight: _academicTrack.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clinical Command Center',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildNavCard(
          context: context,
          icon: Icons.chat_bubble_outline_rounded,
          title: '💬 AskAI Clinical Chat',
          description: 'Consult complex symptoms, drug structures, and board queries directly with gemini-2.5-flash-lite.',
          color: cs.primary,
          onTap: () => Navigator.pushNamed(context, '/ask-ai'),
        ),
        const SizedBox(height: 16),
        _buildNavCard(
          context: context,
          icon: Icons.document_scanner_outlined,
          title: '📸 OCR Case Scanner',
          description: 'Instantly decode patient cases, prescription notes, and exam diagrams with integrated ML recognition.',
          color: cs.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OCRScreen()),
          ),
        ),
        const SizedBox(height: 16),
        _buildNavCard(
          context: context,
          icon: Icons.school_outlined,
          title: '👤 Student Profile & Curriculums',
          description: 'Sync your university domain, choose board study tracks (TUS, USMLE), and toggle interface preferences.',
          color: Colors.teal,
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        final opacity = 0.3 + (_fadeController.value * 0.4);
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(height: 32),
                // Title skeleton
                Container(
                  height: 16,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                // Card skeletons
                ...List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GeometricVectorLogo extends StatelessWidget {
  final double size;
  const _GeometricVectorLogo({this.size = 64});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomPaint(
      size: Size(size, size),
      painter: _GeometricLogoPainter(
        color1: cs.primary,
        color2: cs.secondary,
      ),
    );
  }
}

class _GeometricLogoPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  _GeometricLogoPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;
    
    final paint2 = Paint()
      ..color = color2.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(size.width * 0.5, 0);
    path1.lineTo(size.width, size.height * 0.25);
    path1.lineTo(size.width, size.height * 0.75);
    path1.lineTo(size.width * 0.5, size.height);
    path1.close();

    final path2 = Path();
    path2.moveTo(size.width * 0.5, 0);
    path2.lineTo(0, size.height * 0.25);
    path2.lineTo(0, size.height * 0.75);
    path2.lineTo(size.width * 0.5, size.height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);

    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.15, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
