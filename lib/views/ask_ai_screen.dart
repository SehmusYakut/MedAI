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
  }

  Future<void> _askAI() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an AI service')),
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

      try {
        final service = _availableServices.firstWhere(
          (s) => s.name == _selectedService,
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
            _selectedService!,
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

  Widget _buildUsageLimitBadge(BuildContext context, UsageLimitService limitService) {
    final cs = Theme.of(context).colorScheme;
    final isPremium = limitService.isPremium;
    final remaining = limitService.getRemainingRights();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isPremium 
            ? const Color(0xFFFFF9C4).withValues(alpha: 0.12)
            : (remaining == 0 ? cs.errorContainer.withValues(alpha: 0.15) : cs.surfaceContainerHighest.withValues(alpha: 0.4)),
        border: isPremium 
            ? const Border(
                bottom: BorderSide(color: Colors.amber, width: 1.5),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.stars_rounded : Icons.medical_services_outlined,
            color: isPremium ? Colors.amber : (remaining == 0 ? cs.error : cs.primary),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isPremium 
                  ? '✨ PRO Tier: $remaining/50 Daily Expert Cases Available' 
                  : '🩺 $remaining/5 Daily Clinical Cases Available',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isPremium 
                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.amber.shade200 : Colors.amber.shade800)
                    : (remaining == 0 ? cs.error : cs.onSurfaceVariant),
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (!isPremium)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => Navigator.pushNamed(context, '/premium-paywall'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Upgrade',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickTemplates() {
    final cs = Theme.of(context).colorScheme;
    final templates = [
      {
        'label': '🔬 Differential Diagnosis',
        'prefix': 'Analyze the differential diagnosis for the following clinical presentation: ',
      },
      {
        'label': '💊 Pharmacology & Side Effects',
        'prefix': 'Break down the mechanism of action, contraindications, and major side effects for: ',
      },
      {
        'label': '📊 Lab Result Interpreter',
        'prefix': 'Interpret these laboratory findings and suggest the next diagnostic steps: ',
      },
      {
        'label': '📚 TUS/Exam High-Yield Logic',
        'prefix': 'Break down the high-yield core medical principles behind this exam scenario: ',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            'Quick Clinical Templates',
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
        title: const Text('Ask AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServices,
            tooltip: 'Refresh AI Services',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUsageLimitBadge(context, limitService),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_availableServices.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedService,
                      decoration: const InputDecoration(
                        labelText: 'Select AI Service',
                      ),
                      items: _availableServices.map((service) {
                        return DropdownMenuItem<String>(
                          value: service.name,
                          child: Text(service.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
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
