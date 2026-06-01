import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/usage_limit_service.dart';
import '../services/central_config.dart';
import '../l10n/app_localizations.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  int _selectedPlanIndex = 1; // Default to Annual Plan (index 1)
  bool _isCheckingOut = false;
  
  List<Package> _rcPackages = [];
  bool _isLoadingOfferings = true;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Monthly Plan',
      'price': '\$9.99',
      'period_key': 'paywall_per_month',
      'description_key': 'monthly_plan_desc',
      'badge': null,
    },
    {
      'title': 'Annual Plan',
      'price': '\$59.99',
      'period_key': 'paywall_per_year',
      'description_key': 'annual_plan_desc',
      'badge': 'paywall_save_50',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    if (CentralConfig.isRevenueCatMockMode) {
      debugPrint('[Developer Warning] RevenueCat mock mode. Skipping offerings fetch.');
      if (mounted) {
        setState(() {
          _isLoadingOfferings = false;
        });
      }
      return;
    }
    try {
      await CentralConfig.configurePurchases();
      if (await Purchases.isConfigured) {
        final offerings = await Purchases.getOfferings();
        if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
          if (mounted) {
            setState(() {
              _rcPackages = offerings.current!.availablePackages;
              _isLoadingOfferings = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[Developer Warning] Error fetching offerings from RevenueCat: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOfferings = false;
        });
      }
    }
  }

  Future<void> _startCheckout(UsageLimitService limitService) async {
    setState(() {
      _isCheckingOut = true;
    });

    final l10n = AppLocalizations.of(context);

    try {
      Package? packageToPurchase;
      if (_rcPackages.isNotEmpty && _selectedPlanIndex < _rcPackages.length) {
        packageToPurchase = _rcPackages[_selectedPlanIndex];
      }

      if (packageToPurchase != null) {
        // Production-Grade RevenueCat Purchase Flow
        final purchaseParams = PurchaseParams.package(packageToPurchase);
        final purchaseResult = await Purchases.purchase(purchaseParams);
        final customerInfo = purchaseResult.customerInfo;
        
        final isPremiumActive = customerInfo.entitlements.active.isNotEmpty;
        await limitService.setPremium(isPremiumActive);
      } else {
        // Fallback Mock Purchase Flow (allows testing end-to-end sandbox when keys are placeholders)
        debugPrint('[Developer Warning] No live RevenueCat package found. Running in mock purchase mode.');
        await Future.delayed(const Duration(milliseconds: 1200));
        await limitService.setPremium(true);
      }

      if (!mounted) return;

      // Pop paywall first
      Navigator.pop(context);

      // Show beautiful success notification in the returned screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.paywallSuccessTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.paywallFailedMessage.replaceAll('{error}', e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final limitService = Provider.of<UsageLimitService>(context);
    final l10n = AppLocalizations.of(context);

    // Define Features dynamically with localized text
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.hub_outlined,
        'title': l10n.paywallFeat1Title,
        'desc': l10n.paywallFeat1Desc,
      },
      {
        'icon': Icons.document_scanner_outlined,
        'title': l10n.paywallFeat2Title,
        'desc': l10n.paywallFeat2Desc,
      },
      {
        'icon': Icons.school_outlined,
        'title': l10n.paywallFeat3Title,
        'desc': l10n.paywallFeat3Desc,
      },
      {
        'icon': Icons.bolt,
        'title': l10n.paywallFeat4Title,
        'desc': l10n.paywallFeat4Desc,
      },
    ];

    // Build plan details dynamically (RC offerings data vs local fallback)
    final List<Map<String, dynamic>> displayPlans = [];
    if (_rcPackages.isNotEmpty) {
      for (int i = 0; i < _rcPackages.length; i++) {
        final pkg = _rcPackages[i];
        final prod = pkg.storeProduct;
        
        String title = prod.title;
        String desc = prod.description;
        String period = '';
        String? badge;

        if (pkg.packageType == PackageType.monthly) {
          title = l10n.monthlyPlanTitle;
          desc = l10n.monthlyPlanDesc;
          period = l10n.paywallPerMonth;
        } else if (pkg.packageType == PackageType.annual) {
          title = l10n.annualPlanTitle;
          desc = l10n.annualPlanDesc;
          period = l10n.paywallPerYear;
          badge = l10n.paywallSave50;
        } else {
          period = '';
        }

        displayPlans.add({
          'title': title,
          'price': prod.priceString,
          'period': period,
          'description': desc,
          'badge': badge,
        });
      }
    } else {
      // Fallback
      for (final plan in _plans) {
        displayPlans.add({
          'title': plan['title'] == 'Monthly Plan' ? l10n.monthlyPlanTitle : l10n.annualPlanTitle,
          'price': plan['price'],
          'period': plan['period_key'] == 'paywall_per_month' ? l10n.paywallPerMonth : l10n.paywallPerYear,
          'description': plan['description_key'] == 'monthly_plan_desc' ? l10n.monthlyPlanDesc : l10n.annualPlanDesc,
          'badge': plan['badge'] == 'paywall_save_50' ? l10n.paywallSave50 : null,
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paywallUpgradeTitle),
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
                        const Color(0xFF0F172A),
                        const Color(0xFF020617),
                      ]
                    : [
                        const Color(0xFFF1F5F9),
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
                Center(
                  child: Text(
                    l10n.paywallPremiumHeader,
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
                    l10n.paywallPremiumSub,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, color: Colors.cyan, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                l10n.paywallUpTo50,
                                style: const TextStyle(
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

                      ...features.map((feature) {
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

                      if (_isLoadingOfferings)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Platform.isIOS
                                    ? const CupertinoActivityIndicator(color: Colors.cyan, radius: 14)
                                    : const CircularProgressIndicator(color: Colors.cyan),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.paywallLoadingPlans,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          l10n.paywallChoosePlan,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: List.generate(displayPlans.length, (index) {
                            final plan = displayPlans[index];
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
                                    right: index == displayPlans.length - 1 ? 0 : 6,
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
                                                  fontSize: 20,
                                                  color: isSelected ? Colors.cyan : Colors.white,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  plan['period'] as String,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white.withValues(alpha: 0.5),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
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
                                            child: Text(
                                              plan['badge'] as String,
                                              style: const TextStyle(
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

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: _isCheckingOut
                                ? null
                                : () => _startCheckout(limitService),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: _isCheckingOut
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Platform.isIOS
                                        ? const CupertinoActivityIndicator(color: Colors.black, radius: 10)
                                        : const CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.black,
                                          ),
                                  )
                                : Text(
                                    limitService.isPremium
                                        ? l10n.paywallAlreadySubscribed
                                        : l10n.paywallSubscribeButton,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.paywallKeepFree,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
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
                  const Color(0xFF1E1B4B).withValues(alpha: 0.85),
                  const Color(0xFF0F766E).withValues(alpha: 0.75),
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
