import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/usage_limit_service.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  int _selectedPlanIndex = 1; // Default to Annual Plan (index 1)
  bool _isCheckingOut = false;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Monthly Plan',
      'price': '\$9.99',
      'period': '/ month',
      'description': 'Cancel anytime. Standard access.',
      'badge': null,
    },
    {
      'title': 'Annual Plan',
      'price': '\$59.99',
      'period': '/ year',
      'description': 'Best value: Save 50% (\$4.99/mo)',
      'badge': 'RECOMMENDED',
    },
  ];

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.hub_outlined,
      'title': 'Up to 50 Deep Clinical Knowledge Graph Queries / Day',
      'desc': 'Visual connections between symptoms, diagnoses, and treatments.',
    },
    {
      'icon': Icons.document_scanner_outlined,
      'title': 'Instant Medical Slide & Prescription OCR Decoding',
      'desc': 'Extract text from medical slides, notes, and prescriptions.',
    },
    {
      'icon': Icons.school_outlined,
      'title': 'High-Yield TUS & Board Exam Breakdown Modes',
      'desc': 'Interactive analysis of complex board exam scenarios.',
    },
    {
      'icon': Icons.bolt,
      'title': 'Zero Latency, Priority AI Reasoning Pipeline',
      'desc': 'Bypass rate limits with priority resources.',
    },
  ];

  Future<void> _startMockCheckout(BuildContext context, UsageLimitService limitService) async {
    setState(() {
      _isCheckingOut = true;
    });

    // Simulate network delay for payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isCheckingOut = false;
    });

    // Save premium status
    await limitService.setPremium(true);

    // Show beautiful success dialog
    if (context.mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Premium!',
                style: Theme.of(dialogCtx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account has been upgraded. You now have up to 50 daily clinical queries and advanced medical insights!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx); // Close dialog
                    Navigator.pop(context); // Pop paywall screen
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Querying'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final limitService = Provider.of<UsageLimitService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF0F172A), // Very dark Slate/indigo
                        const Color(0xFF020617), // Deep slate-950 black
                      ]
                    : [
                        const Color(0xFFF1F5F9), // Soft Slate-100
                        Colors.white,
                      ],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                const SizedBox(height: 8),
                // Crown / Star Icon Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.cyan.withValues(alpha: 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.25),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.cyan.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      size: 44,
                      color: Colors.cyan,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Heading
                Center(
                  child: Text(
                    'MedAI Premium',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.cyan.shade900,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Elevate your daily clinical learning capabilities',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Glassmorphic SaaS Subscription Card
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cap Value Proposition
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.cyan.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt, color: Colors.cyan, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'UP TO 50 CLINICAL QUERIES / DAY',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Features List
                      ..._features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  feature['icon'] as IconData,
                                  color: Colors.cyan,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feature['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      feature['desc'] as String,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(color: Colors.white12, height: 24),

                      const Text(
                        'Choose your plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Plans selection
                      Row(
                        children: List.generate(_plans.length, (index) {
                          final plan = _plans[index];
                          final isSelected = _selectedPlanIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPlanIndex = index;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: index == 0 ? 0 : 6,
                                  right: index == _plans.length - 1 ? 0 : 6,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.cyan.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? Colors.cyan : Colors.white12,
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan['title'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          textBaseline: TextBaseline.alphabetic,
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          children: [
                                            Text(
                                              plan['price'] as String,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                                color: isSelected ? Colors.cyan : Colors.white,
                                              ),
                                            ),
                                            Text(
                                              plan['period'] as String,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          plan['description'] as String,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (plan['badge'] != null)
                                      Positioned(
                                        top: -24,
                                        right: -6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.cyan,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'SAVE 50%',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),
                      // Subscribe Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isCheckingOut
                              ? null
                              : () => _startMockCheckout(context, limitService),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: _isCheckingOut
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  limitService.isPremium
                                      ? 'Already Subscribed'
                                      : 'Subscribe to Premium',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Keep using free version',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Developer Tools Panel for testing
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    title: const Row(
                      children: [
                        Icon(Icons.developer_mode, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Developer Options (For Testing Only)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.flash_on, size: 14),
                              label: const Text('Exhaust 5 Queries'),
                              onPressed: () async {
                                await limitService.testForceExhaustQueries();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Free credits forced to 0!')),
                                  );
                                }
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.refresh, size: 14),
                              label: Text(limitService.isPremium ? 'Reset 50 Queries' : 'Reset 5 Queries'),
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                final maxQueries = limitService.isPremium ? 50 : 5;
                                await prefs.setInt('medai_remaining_queries', maxQueries);
                                await limitService.setPremium(limitService.isPremium);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Credits reset to $maxQueries!')),
                                  );
                                }
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.history, size: 14),
                              label: const Text('Simulate >24h elapsed'),
                              onPressed: () async {
                                await limitService.testForcePass24Hours();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Last reset timestamp set to 25 hours ago!')),
                                  );
                                }
                              },
                            ),
                            ActionChip(
                              avatar: Icon(
                                limitService.isPremium ? Icons.star_border : Icons.star,
                                size: 14,
                              ),
                              label: Text(
                                limitService.isPremium ? 'Remove Premium' : 'Enable Premium',
                              ),
                              onPressed: () async {
                                await limitService.setPremium(!limitService.isPremium);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        limitService.isPremium
                                            ? 'Premium mode activated!'
                                            : 'Premium mode deactivated!',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  const GlassmorphicCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1B4B).withValues(alpha: 0.85), // Deep Indigo
                  const Color(0xFF0F766E).withValues(alpha: 0.75), // Teal
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
