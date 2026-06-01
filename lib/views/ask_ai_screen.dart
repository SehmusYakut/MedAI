import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_response.dart';
import '../services/ai_service.dart';
import '../services/usage_limit_service.dart';
import 'widgets/ai_response_card.dart';

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends State<AskAIScreen> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  final _scrollController = ScrollController();
  final List<AIResponse> _responses = [];
  bool _isLoading = false;
  String? _selectedService;
  List<AIService> _availableServices = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = await AIServiceManager().getServices();

      if (mounted) {
        setState(() {
          _availableServices = services;
          if (services.isNotEmpty) {
            _selectedService = services.first.name;
          } else {
            _selectedService = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableServices = [];
          _selectedService = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Configuration Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _askAI() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedService == null) {
        if (_availableServices.isNotEmpty) {
          _selectedService = _availableServices.first.name;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No AI service available')),
          );
          return;
        }
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

      try {
        final service = _availableServices.firstWhere(
          (s) => s.name == _selectedService,
          orElse: () => _availableServices.first,
        );

        final response = await service.generateResponse(_promptController.text);

        await limitService.decrementRight();

        setState(() {
          _responses.add(AIResponse(
            serviceName: service.name,
            response: response,
          ));
          _promptController.clear();
        });
      } catch (e) {
        setState(() {
          _responses.add(AIResponse.error(
            _selectedService ?? 'AI',
            'Error: ${e.toString()}',
          ));
        });
      } finally {
        setState(() {
          _isLoading = false;
        });

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



  Widget _buildQuickTemplates() {
    final cs = Theme.of(context).colorScheme;
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

    final templates = isTurkish
        ? [
            {
              'label': '🔬 Ayırıcı Tanı',
              'prefix': 'Aşağıdaki klinik tablo için (birincil, ikincil ve elenmesi gereken durumları içerecek şekilde) ayırıcı tanı analizi yap: ',
            },
            {
              'label': '💊 Farmakoloji ve Etkileşim',
              'prefix': 'Şu ilaç/etken madde için etki mekanizmasını, klinik endikasyonlarını, önemli kontrendikasyonlarını ve kritik ilaç etkileşimlerini açıkla: ',
            },
            {
              'label': '📊 Laboratuvar ve Görüntüleme',
              'prefix': 'Aşağıdaki laboratuvar değerlerini veya görüntüleme bulgularını yorumla, klinik korelasyon kur ve atılması gereken bir sonraki en iyi tanısal adımı öner: ',
            },
            {
              'label': '📚 TUS ve Komite Soru Mantığı',
              'prefix': 'Bu klinik vakanın arkasındaki temel TUS/Komite mekanizmalarını ve patofizyolojik mantığı yüksek verimli (high-yield) bir şekilde analiz et: ',
            },
          ]
        : [
            {
              'label': '🔬 Differential Diagnosis',
              'prefix': 'Analyze the differential diagnosis (including primary, secondary, and rule-out conditions) for the following clinical presentation: ',
            },
            {
              'label': '💊 Pharmacology & Interactions',
              'prefix': 'Break down the mechanism of action, high-yield clinical indications, major contraindications, and critical drug interactions for: ',
            },
            {
              'label': '📊 Lab & Imaging Interpreter',
              'prefix': 'Interpret the following laboratory values or imaging findings, correlate them clinically, and suggest the next best diagnostic steps: ',
            },
            {
              'label': '📚 TUS & Board Exam Logic',
              'prefix': 'Extract and analyze the core, high-yield medical board principles and pathophysiological rationales behind this clinical vignette: ',
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            isTurkish ? 'Hızlı Klinik Şablonlar' : 'Quick Clinical Templates',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: cs.primary.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final t = templates[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: Text(
                    t['label']!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  onPressed: () {
                    setState(() {
                      _promptController.text = t['prefix']!;
                    });
                  },
                  backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                    color: cs.outline.withValues(alpha: 0.15),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final limitService = Provider.of<UsageLimitService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'MedAI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              limitService.isPremium 
                  ? '✨ PRO Tier: ${limitService.getRemainingRights()}/50 Daily Expert Cases' 
                  : '🩺 ${limitService.getRemainingRights()}/5 Daily Clinical Cases Available',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: limitService.isPremium 
                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.amber.shade200 : Colors.amber.shade800)
                    : (limitService.getRemainingRights() == 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        actions: [
          if (!limitService.isPremium)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                icon: const Icon(Icons.bolt, size: 16),
                label: const Text('PRO', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pushNamed(context, '/premium-paywall'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildQuickTemplates(),
                  TextFormField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      labelText: 'Your Question',
                      hintText: 'Ask anything...',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your question';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
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
                        : const Icon(Icons.send),
                    label: Text(_isLoading ? 'Processing...' : 'Ask AI'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _responses.isEmpty
                ? Center(
                    child: Text(
                      'No responses yet. Ask a question to get started!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
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
        ],
      ),
    );
  }


  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
