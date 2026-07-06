import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_storage_service.dart';
import '../services/usage_limit_service.dart';
import '../models/chat_session.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _academicTrack = '';
  late AnimationController _pulseController;
  List<ChatSession> _sessions = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _loadAcademicTrack();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSessions();
  }

  Future<void> _loadAcademicTrack() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _academicTrack = prefs.getString('academic_track') ?? '';
      });
    }
  }

  void _loadSessions() {
    final storage = Provider.of<ChatStorageService>(context, listen: false);
    setState(() {
      _sessions = storage.getAllSessions();
      _isLoaded = true;
    });
  }

  Future<void> _deleteSession(String sessionId) async {
    final storage = Provider.of<ChatStorageService>(context, listen: false);
    await storage.deleteSession(sessionId);
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final limitService = Provider.of<UsageLimitService>(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset(
            'assets/images/tipakademi_icon.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 52,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.appTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: limitService.isPremium
                    ? Colors.amber.withValues(alpha: 0.15)
                    : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: limitService.isPremium ? Colors.amber : cs.outlineVariant,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    limitService.isPremium ? Icons.stars : Icons.healing,
                    size: 10,
                    color: limitService.isPremium ? Colors.amber : cs.primary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    limitService.isPremium ? 'PRO' : 'FREE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: limitService.isPremium ? Colors.amber : cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile').then((_) {
                _loadAcademicTrack();
                _loadSessions();
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: cs.primary.withValues(alpha: 0.1),
                child: ClipOval(
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.account_circle, color: cs.primary, size: 24);
                          },
                        )
                      : Icon(Icons.account_circle, color: cs.primary, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient matching dark-mode glassmorphism
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF0A192F), // Deep Navy
                        const Color(0xFF020617), // Dark slate
                      ]
                    : [
                        const Color(0xFFF1F5F9), // Soft slate
                        Colors.white,
                      ],
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Smart Hub Greeting Panel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dark-mode greeting panel
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF0F1E36),
                                      const Color(0xFF060D1A),
                                    ]
                                  : [
                                      Colors.white,
                                      Colors.grey.shade50,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.welcomeCounselor,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.cyan.shade900,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.clinicalFocusToday,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                              ),
                              if (_academicTrack.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _academicTrack,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Core Action Matrix (Launch New Query, OCR, Medicine, Question Bank)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // New Query Card
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/ask-ai').then((_) => _loadSessions());
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        const Color(0xFF0F766E), // Teal
                                        const Color(0xFF1E1B4B), // Indigo
                                      ]
                                    : [
                                        Colors.teal.shade700,
                                        Colors.indigo.shade800,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withValues(alpha: 0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.cyan.withValues(alpha: 0.2 * _pulseController.value),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.launchNewQuery,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.launchNewQueryDesc,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Split Medicine Program & OCR Scanner Row
                        Row(
                          children: [
                            // Medicine Program Card
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/medicine-programs').then((_) => _loadSessions());
                                },
                                child: Container(
                                  height: 110,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
                                          : [Colors.blue.shade700, Colors.indigo.shade600],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.medication_rounded, color: Colors.white, size: 24),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.medicinePrograms,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Schedules & Reminders',
                                            style: TextStyle(fontSize: 9, color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // OCR Scanner Card
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/ocr').then((_) => _loadSessions());
                                },
                                child: Container(
                                  height: 110,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? [const Color(0xFFD97706), const Color(0xFFEA580C)]
                                          : [Colors.amber.shade700, Colors.orange.shade700],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 24),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.ocrScan,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Prescriptions & Books',
                                            style: TextStyle(fontSize: 9, color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Question Bank Card
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/question-bank').then((_) => _loadSessions());
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [const Color(0xFF4C1D95), const Color(0xFF7C3AED)] // Purple
                                    : [Colors.purple.shade700, Colors.deepPurple.shade600],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.collections_bookmark_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.questionBank,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.questionBankDesc,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Case Investigations Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 12),
                    child: Text(
                      l10n.recentCaseInvestigations,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Recent Case Investigations list
                if (!_isLoaded)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (_sessions.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0A192F).withValues(alpha: 0.4) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.folder_open_rounded, size: 40, color: cs.primary.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noRecentCases,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.activeSessionsDesc,
                              style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final session = _sessions[index];
                          final messagesCount = session.messages.length;
                          final dateStr = '${session.lastInteraction.day}/${session.lastInteraction.month}/${session.lastInteraction.year}';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F1F2E) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.history_edu_rounded, color: Colors.cyan, size: 20),
                                ),
                                title: Text(
                                  session.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  '$dateStr  •  $messagesCount ${l10n.messagesCountLabel}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.withValues(alpha: 0.8), size: 20),
                                      onPressed: () {
                                        _showDeleteConfirm(session.id);
                                      },
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded, color: cs.primary.withValues(alpha: 0.6), size: 14),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/ask-ai',
                                    arguments: session.id,
                                  ).then((_) => _loadSessions());
                                },
                              ),
                            ),
                          );
                        },
                        childCount: _sessions.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(String sessionId) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteCaseTitle),
        content: Text(l10n.deleteCaseConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              await _deleteSession(sessionId);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
