import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ocr_screen.dart';
import '../models/ai_response.dart';
import '../services/ai_service.dart';
import '../services/usage_limit_service.dart';
import 'widgets/ai_response_card.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  final _scrollController = ScrollController();
  final List<AIResponse> _responses = [];
  bool _isLoading = false;
  String? _selectedService;
  List<AIService> _availableServices = [];
  String _academicTrack = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadServices();
    _loadAcademicTrack();
  }

  Future<void> _loadAcademicTrack() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _academicTrack = prefs.getString('academic_track') ?? '';
      });
    }
  }

  Future<void> _loadServices() async {
    try {
      final services = await AIServiceManager().getServices();
      if (mounted) {
        setState(() {
          _availableServices = services;
          if (services.isNotEmpty) {
            _selectedService = services.first.name;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading AI services: $e');
    }
  }

  Future<void> _askAI() async {
    if (_formKey.currentState!.validate()) {
      if (_availableServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).noAiConfigured),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final limitService = Provider.of<UsageLimitService>(context, listen: false);
      await limitService.checkAndResetDailyLimit();

      if (limitService.getRemainingRights() <= 0) {
        if (!mounted) return;
        Navigator.pushNamed(context, '/premium-paywall');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final prompt = _promptController.text;
      _promptController.clear();

      try {
        final service = _availableServices.firstWhere(
          (s) => s.name == _selectedService,
          orElse: () => _availableServices.first,
        );

        // Customize output depending on the student's clinical level / academic track
        String tailoredPrompt = prompt;
        if (_academicTrack.isNotEmpty) {
          tailoredPrompt += "\n\n[Context: The user is currently in the track/level: '$_academicTrack'. Tailor the explanation depth, high-yield facts, and medical focus to match this academic level.]";
        }

        final responseText = await service.generateResponse(tailoredPrompt);
        await limitService.decrementRight();

        if (mounted) {
          setState(() {
            _responses.add(AIResponse(
              serviceName: service.name,
              response: responseText,
            ));
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _responses.add(AIResponse.error(
              _selectedService ?? 'AI',
              'Error: ${e.toString()}',
            ));
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        // Scroll to the bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  Widget _buildQuickTemplates(AppLocalizations l10n, ColorScheme cs) {
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

    final templates = isTurkish
        ? [
            {
              'label': '🔬 Ayırıcı Tanı',
              'prefix': 'Aşağıdaki klinik tablo için (birincil, ikincil ve elenmesi gereken durumları içerecek şekilde) ayırıcı tanı analizi yap: ',
            },
            {
              'label': '💊 Farmakoloji',
              'prefix': 'Şu ilaç/etken madde için etki mekanizmasını, klinik endikasyonlarını, önemli kontrendikasyonlarını ve kritik ilaç etkileşimlerini açıkla: ',
            },
            {
              'label': '📊 Lab & Görüntüleme',
              'prefix': 'Aşağıdaki laboratuvar değerlerini veya görüntüleme bulgularını yorumla, klinik korelasyon kur ve atılması gereken bir sonraki en iyi tanısal adımı öner: ',
            },
            {
              'label': '📚 TUS Mantığı',
              'prefix': 'Bu klinik vakanın arkasındaki temel TUS/Komite mekanizmalarını ve patofizyolojik mantığı yüksek verimli (high-yield) bir şekilde analiz et: ',
            },
          ]
        : [
            {
              'label': '🔬 Diff Diagnosis',
              'prefix': 'Analyze the differential diagnosis (including primary, secondary, and rule-out conditions) for the following clinical presentation: ',
            },
            {
              'label': '💊 Pharmacology',
              'prefix': 'Break down the mechanism of action, high-yield clinical indications, major contraindications, and critical drug interactions for: ',
            },
            {
              'label': '📊 Lab & Imaging',
              'prefix': 'Interpret the following laboratory values or imaging findings, correlate them clinically, and suggest the next best diagnostic steps: ',
            },
            {
              'label': '📚 Board Logic',
              'prefix': 'Extract and analyze the core, high-yield medical board principles and pathophysiological rationales behind this clinical vignette: ',
            },
          ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final t = templates[index];
          return Padding(
            key: ValueKey('chip_$index'),
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(
                t['label']!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                setState(() {
                  _promptController.text = t['prefix']!;
                });
              },
              backgroundColor: cs.primaryContainer.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: cs.primary.withValues(alpha: 0.2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ColorScheme cs, bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    final doctorName = user?.displayName ?? 'Doctor';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing circular emblem
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.1),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.08 * _pulseController.value),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.healing_outlined,
                      size: 48,
                      color: cs.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              '${l10n.welcomeDoctor}, $doctorName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _academicTrack.isNotEmpty
                  ? '${l10n.currentTrackLabel}$_academicTrack'
                  : l10n.selectTrackInSettings,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1E36) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.startClinicalQuery,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final limitService = Provider.of<UsageLimitService>(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              limitService.isPremium 
                  ? '✨ PRO Tier: ${limitService.getRemainingRights()}/50 Daily Expert Cases' 
                  : '🩺 ${limitService.getRemainingRights()}/5 Daily Clinical Cases Available',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: limitService.isPremium 
                    ? (isDark ? Colors.amber.shade200 : Colors.amber.shade800)
                    : (limitService.getRemainingRights() == 0 ? cs.error : cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.document_scanner_outlined),
          tooltip: l10n.ocrScan,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OCRScreen()),
            ).then((_) => _loadAcademicTrack());
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/profile').then((_) {
                _loadAcademicTrack();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: _responses.isEmpty
                ? _buildEmptyState(l10n, cs, isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _responses.length,
                    itemBuilder: (context, index) {
                      final response = _responses[index];
                      return AIResponseCard(
                        key: ValueKey('${response.timestamp.millisecondsSinceEpoch}_$index'),
                        response: response,
                      );
                    },
                  ),
          ),
          
          // Action chips and Query input
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF060D1A) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  _buildQuickTemplates(l10n, cs),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _promptController,
                              maxLines: 4,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText: l10n.askAnything,
                                labelText: l10n.yourQuestion,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.enterQuestion;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _promptController,
                            builder: (context, value, child) {
                              final hasText = value.text.trim().isNotEmpty;
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasText && !_isLoading
                                      ? cs.primary
                                      : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                                ),
                                child: IconButton(
                                  color: hasText && !_isLoading ? Colors.white : Colors.grey,
                                  onPressed: _isLoading ? null : _askAI,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.send_rounded),
                                ),
                              );
                            },
                          ),
                        ],
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

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}
