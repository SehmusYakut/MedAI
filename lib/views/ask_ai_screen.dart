import 'package:flutter/material.dart';
import '../models/ai_response.dart';
import '../services/ai_service.dart';
import '../services/api_key_service.dart';

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
  late ApiKeyService _apiKeyService;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    _apiKeyService = await ApiKeyService.getInstance();
    final apiKey = _apiKeyService.getApiKey();

    if (apiKey == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please set your API key first'),
            action: SnackBarAction(
              label: 'Set API Key',
              onPressed: _navigateToApiKey,
            ),
          ),
        );
      }
      return;
    }

    final services = await AIServiceManager().getServices();
    setState(() {
      _availableServices = services;
      if (services.isNotEmpty) {
        _selectedService = services.first.name;
      }
    });
  }

  void _navigateToApiKey() {
    Navigator.pushNamed(context, '/api-key');
  }

  Future<void> _askAI() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an AI service')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask AI'),
      ),
      body: Column(
        children: [
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    response.isError
                                        ? Icons.error_outline
                                        : Icons.smart_toy_outlined,
                                    color: response.isError
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    response.serviceName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatTimestamp(response.timestamp),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                response.response,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
