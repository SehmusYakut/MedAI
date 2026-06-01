import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';
import '../models/ai_response.dart';
import '../services/ai_service.dart';
import '../services/usage_limit_service.dart';
import '../services/chat_storage_service.dart';
import 'widgets/ai_response_card.dart';

class AskAIScreen extends StatefulWidget {
  final String? sessionId;
  const AskAIScreen({super.key, this.sessionId});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends State<AskAIScreen> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  final _scrollController = ScrollController();
  
  String? _sessionId;
  ChatSession? _session;
  bool _isInitialized = false;

  bool _isLoading = false;
  String? _selectedService;
  List<AIService> _availableServices = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _sessionId = args;
      } else {
        _sessionId = widget.sessionId;
      }
      _loadOrCreateSession();
      _isInitialized = true;
      // Scroll to bottom after layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animate: false);
      });
    }
  }

  void _loadOrCreateSession() {
    final storage = Provider.of<ChatStorageService>(context, listen: false);
    if (_sessionId != null) {
      final sessions = storage.getAllSessions();
      final index = sessions.indexWhere((s) => s.id == _sessionId);
      if (index != -1) {
        _session = sessions[index];
      }
    }
    
    if (_session == null) {
      final newId = const Uuid().v4();
      _sessionId = newId;
      _session = ChatSession(
        id: newId,
        title: 'New Clinical Case...',
        lastInteraction: DateTime.now(),
        messages: [],
      );
      storage.saveSession(_session!);
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

      final storage = Provider.of<ChatStorageService>(context, listen: false);
      final prompt = _promptController.text.trim();
      _promptController.clear();

      setState(() {
        _isLoading = true;
      });

      // Save user message
      final userMsg = ChatMessage(sender: 'user', text: prompt);
      await storage.saveMessage(_sessionId!, userMsg);

      // Reload local session state
      setState(() {
        final sessions = storage.getAllSessions();
        _session = sessions.firstWhere((s) => s.id == _sessionId);
      });

      _scrollToBottom();

      try {
        final service = _availableServices.firstWhere(
          (s) => s.name == _selectedService,
          orElse: () => _availableServices.first,
        );

        final response = await service.generateResponse(prompt);

        await limitService.decrementRight();

        // Save AI response message
        final aiMsg = ChatMessage(sender: service.name, text: response);
        await storage.saveMessage(_sessionId!, aiMsg);
      } catch (e) {
        // Save error message
        final errorMsg = ChatMessage(
          sender: _selectedService ?? 'AI',
          text: 'Error: ${e.toString()}',
          isError: true,
        );
        await storage.saveMessage(_sessionId!, errorMsg);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            final sessions = storage.getAllSessions();
            _session = sessions.firstWhere((s) => s.id == _sessionId);
          });
          _scrollToBottom();
        }
      }
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _session?.title);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Rename Session'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter session title...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && _sessionId != null) {
                final storage = Provider.of<ChatStorageService>(context, listen: false);
                await storage.renameSession(_sessionId!, newTitle);
                setState(() {
                  _session = _session?.copyWith(title: newTitle);
                });
                if (mounted) Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text('This action cannot be undone. Are you sure you want to delete this case investigation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              if (_sessionId != null) {
                final storage = Provider.of<ChatStorageService>(context, listen: false);
                await storage.deleteSession(_sessionId!);
                if (mounted) {
                  Navigator.pop(dialogCtx); // Close dialog
                  Navigator.pop(context); // Pop back to HomeScreen
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final messages = _session?.messages ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _session?.title ?? 'MedAI Chat',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              limitService.isPremium 
                  ? '✨ PRO Tier: ${limitService.getRemainingRights()}/50 Daily Expert Cases' 
                  : '🩺 ${limitService.getRemainingRights()}/5 Daily Clinical Cases Available',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: limitService.isPremium 
                    ? (isDark ? Colors.amber.shade200 : Colors.amber.shade800)
                    : (limitService.getRemainingRights() == 0 ? cs.error : cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameDialog();
              } else if (value == 'delete') {
                _showDeleteConfirmDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Rename Session'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Text('Delete Session', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: cs.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No responses yet. Ask a question to get started!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      if (msg.sender == 'user') {
                        return _UserMessageBubble(message: msg, isDark: isDark, cs: cs);
                      } else {
                        return AIResponseCard(
                          key: ValueKey('${msg.timestamp.millisecondsSinceEpoch}_$index'),
                          response: AIResponse(
                            serviceName: msg.sender,
                            response: msg.text,
                            isError: msg.isError,
                            timestamp: msg.timestamp,
                          ),
                        );
                      }
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF060D1A) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 8),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildQuickTemplates(),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                hintText: 'Ask anything...',
                                labelText: 'Your Question',
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
                                  return 'Please enter your question';
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
    super.dispose();
  }
}

class _UserMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  final ColorScheme cs;

  const _UserMessageBubble({
    required this.message,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : cs.primaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(2),
          ),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isDark ? Colors.white : cs.onPrimaryContainer,
            fontSize: 14.5,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
