import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiKeyTourScreen extends StatefulWidget {
  const ApiKeyTourScreen({super.key});

  @override
  State<ApiKeyTourScreen> createState() => _ApiKeyTourScreenState();
}

class _ApiKeyTourScreenState extends State<ApiKeyTourScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expandedServiceIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Get API Keys'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Quick Start'),
            Tab(text: 'All Services'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickStartTab(),
          _buildAllServicesTab(),
        ],
      ),
    );
  }

  Widget _buildQuickStartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'FREE Services (Recommended for Beginners)',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.green.shade700,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start with these - no credit card required!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            title: 'Google Gemini',
            icon: '🔥',
            description: 'Free, fast, and easy to get started',
            steps: [
              '1. Go to Google AI Studio (aistudio.google.com/apikey)',
              '2. Click "Create API key"',
              '3. Select or create a Google Cloud project',
              '4. Copy the generated API key',
              '5. Paste it in MedAI under Gemini API Key',
            ],
            url: 'https://aistudio.google.com/apikey',
            color: Colors.blue,
            benefit: '✅ Completely FREE\n✅ 60 requests/min\n✅ Fast responses',
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            title: 'Groq',
            icon: '⚡',
            description: 'Ultra-fast, generous free tier',
            steps: [
              '1. Visit console.groq.com',
              '2. Sign up with GitHub or Google',
              '3. Go to "API Keys" section',
              '4. Click "Create API Key"',
              '5. Copy and paste into MedAI',
            ],
            url: 'https://console.groq.com',
            color: Colors.purple,
            benefit:
                '✅ FREE with 14,000 requests/min\n✅ Lightning fast\n✅ Great for testing',
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'PREMIUM Services (Paid, but Powerful)',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.orange.shade700,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use these for production or advanced features',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            title: 'Claude (Anthropic)',
            icon: '🧠',
            description: 'Best for medical text analysis',
            steps: [
              '1. Visit console.anthropic.com',
              '2. Sign up or log in',
              '3. Go to "API Keys" section',
              '4. Click "Create Key"',
              '5. Copy and save in MedAI',
            ],
            url: 'https://console.anthropic.com',
            color: Colors.indigo,
            benefit:
                '🎯 Excellent reasoning\n📚 Best for medical\n💪 Most capable',
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            title: 'ChatGPT (OpenAI)',
            icon: '🤖',
            description: 'Industry standard, widely used',
            steps: [
              '1. Visit platform.openai.com',
              '2. Sign up or log in',
              '3. Click "API keys" in sidebar',
              '4. Click "Create new secret key"',
              '5. Save it securely in MedAI',
            ],
            url: 'https://platform.openai.com',
            color: Colors.green,
            benefit: '⭐ Most popular\n💰 Pay-as-you-go\n📈 \$5 free trial',
          ),
        ],
      ),
    );
  }

  Widget _buildAllServicesTab() {
    final services = [
      {
        'name': 'Google Gemini',
        'icon': '🔥',
        'url': 'https://aistudio.google.com/apikey',
        'pricing': 'FREE (60 req/min)',
        'steps': [
          'Visit: aistudio.google.com/apikey',
          'Click: Create API key',
          'Select: Google Cloud project',
          'Copy: Your API key',
          'Paste: In MedAI settings',
        ],
        'tips': [
          'Completely free to start',
          'No credit card needed',
          'Perfect for testing',
          'Excellent response quality',
        ],
        'color': Colors.blue,
      },
      {
        'name': 'Groq',
        'icon': '⚡',
        'url': 'https://console.groq.com',
        'pricing': 'FREE (14,000 req/min)',
        'steps': [
          'Visit: console.groq.com',
          'Sign up with GitHub/Google',
          'Go to: API Keys section',
          'Create: New API key',
          'Paste: In MedAI settings',
        ],
        'tips': [
          'Extremely fast inference',
          'Very generous free tier',
          'Great for development',
          'No credit card required',
        ],
        'color': Colors.purple,
      },
      {
        'name': 'Claude (Anthropic)',
        'icon': '🧠',
        'url': 'https://console.anthropic.com',
        'pricing': 'Paid (Pay-as-you-go)',
        'steps': [
          'Visit: console.anthropic.com',
          'Sign up or log in',
          'Go to: API Keys',
          'Create: New key',
          'Copy: And save securely',
        ],
        'tips': [
          'Best for medical analysis',
          'Strong reasoning ability',
          'High quality responses',
          'Requires credit card',
        ],
        'color': Colors.indigo,
      },
      {
        'name': 'ChatGPT (OpenAI)',
        'icon': '🤖',
        'url': 'https://platform.openai.com',
        'pricing': 'Paid (\$5 trial)',
        'steps': [
          'Visit: platform.openai.com',
          'Sign up or log in',
          'Click: API keys',
          'Create: New secret key',
          'Save: In MedAI securely',
        ],
        'tips': [
          'Industry standard',
          'Most popular API',
          'Free trial credits',
          'Easy to set up',
        ],
        'color': Colors.green,
      },
      {
        'name': 'Mistral',
        'icon': '🚀',
        'url': 'https://console.mistral.ai',
        'pricing': 'Paid (€5 trial)',
        'steps': [
          'Visit: console.mistral.ai',
          'Sign up with email/GitHub',
          'Go to: API keys',
          'Generate: New key',
          'Paste: In MedAI settings',
        ],
        'tips': [
          'Very affordable pricing',
          'EU-based (GDPR compliant)',
          'Fast inference',
          'Free €5 credit',
        ],
        'color': Colors.orange,
      },
      {
        'name': 'HuggingFace',
        'icon': '🤗',
        'url': 'https://huggingface.co',
        'pricing': 'FREE (with limits)',
        'steps': [
          'Visit: huggingface.co',
          'Sign up or log in',
          'Click: Profile → Settings',
          'Go to: Access Tokens',
          'Create: New token',
        ],
        'tips': [
          '1M+ open-source models',
          'Community-driven',
          'Free tier available',
          'Great for research',
        ],
        'color': Colors.yellow.shade700,
      },
      {
        'name': 'OpenRouter',
        'icon': '🔗',
        'url': 'https://openrouter.ai',
        'pricing': 'Paid (Multiple providers)',
        'steps': [
          'Visit: openrouter.ai',
          'Sign up or log in',
          'Go to: Keys section',
          'Create: New key',
          'Paste: In MedAI settings',
        ],
        'tips': [
          'Access 100+ models',
          'Price comparison built-in',
          'Automatic fallback',
          'No subscription needed',
        ],
        'color': Colors.cyan,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final isExpanded = _expandedServiceIndex == index;

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            children: [
              ListTile(
                leading: Text(
                  service['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(service['name'] as String),
                subtitle: Text(service['pricing'] as String),
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
                onTap: () {
                  setState(() {
                    _expandedServiceIndex = isExpanded ? -1 : index;
                  });
                },
              ),
              if (isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Steps Section
                      Text(
                        '📋 Steps to Get API Key:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      ...(service['steps'] as List<String>).asMap().entries.map(
                        (entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: (service['color'] as Color),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tips Section
                      Text(
                        '💡 Tips:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...(service['tips'] as List<String>).map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Visit Button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            _launchUrl(service['url'] as String);
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: Text('Visit ${service['name']}'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String icon,
    required String description,
    required List<String> steps,
    required String url,
    required Color color,
    required String benefit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                benefit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Quick Steps:',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  step,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  _launchUrl(url);
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text('Go to $title'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
