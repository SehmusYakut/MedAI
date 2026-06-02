import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_and_locale_service.dart';
import '../services/usage_limit_service.dart';
import '../services/central_config.dart';
import '../l10n/app_localizations.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTrack = 'Phase 4-6: Clinical Clerkships';
  SharedPreferences? _prefs;
  bool _isSaving = false;

  final List<Map<String, String>> _tracks = [
    {
      'key': 'Phase 1-3: Basic Sciences',
      'label_en': 'Phase 1-3: Basic Sciences',
      'label_tr': 'Dönem 1-3: Temel Bilimler',
    },
    {
      'key': 'Phase 4-6: Clinical Clerkships',
      'label_en': 'Phase 4-6: Clinical Clerkships',
      'label_tr': 'Dönem 4-6: Klinik Stajlar',
    },
    {
      'key': 'TUS Preparation Track',
      'label_en': 'TUS Preparation Track',
      'label_tr': 'TUS Hazırlık Programı',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedTrack = _prefs?.getString('academic_track') ?? 'Phase 4-6: Clinical Clerkships';
      });
    }
  }

  Future<void> _saveTrack(String trackKey) async {
    if (_prefs != null) {
      setState(() {
        _isSaving = true;
      });
      await _prefs!.setString('academic_track', trackKey);
      if (mounted) {
        setState(() {
          _selectedTrack = trackKey;
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<ThemeAndLocaleService>(context);
    final l10n = AppLocalizations.of(context);
    final isTurkish = settings.locale.languageCode == 'tr';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileSettingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // User profile card
          if (user != null) _buildUserProfileCard(user, cs, isDark, isTurkish, l10n),
          const SizedBox(height: 20),

          // Subscription Status Card
          _buildSubscriptionCard(context, cs, isDark, isTurkish, l10n),
          const SizedBox(height: 20),

          // Medicine Programs Academic Track Checklist
          _buildAcademicTrackCard(cs, isDark, isTurkish, l10n),
          const SizedBox(height: 20),

          // Preferences (Theme & Locale)
          _buildPreferencesCard(settings, cs, isDark, isTurkish, l10n),
          const SizedBox(height: 20),

          // Advanced Legacy Tools (demoted OCR scanner)
          _buildLegacyToolsCard(cs, isDark, isTurkish, l10n),
          const SizedBox(height: 32),

          // Log Out Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _handleSignOut(context),
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                l10n.signOutAccount,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(User user, ColorScheme cs, bool isDark, bool isTurkish, AppLocalizations l10n) {
    final String emailDomain = user.email != null && user.email!.contains('@')
        ? user.email!.split('@')[1]
        : '';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.3),
                  width: 2.5,
                ),
              ),
              child: CircleAvatar(
                radius: 36,
                backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                backgroundColor: cs.primaryContainer,
                child: user.photoURL == null
                    ? Text(
                        user.displayName?.substring(0, 1).toUpperCase() ?? 'D',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? l10n.medicalProfessional,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (emailDomain.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emailDomain,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: cs.onSecondaryContainer,
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
    );
  }

  Widget _buildAcademicTrackCard(ColorScheme cs, bool isDark, bool isTurkish, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.clinicalLevel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.clinicalLevelDesc,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ..._tracks.map((track) {
              final isSelected = _selectedTrack == track['key'];
              final label = isTurkish ? track['label_tr']! : track['label_en']!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: InkWell(
                  onTap: _isSaving ? null : () => _saveTrack(track['key']!),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? cs.primary
                            : (isDark ? Colors.white10 : Colors.grey.shade200),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected ? cs.primary : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? cs.primary : cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(ThemeAndLocaleService settings, ColorScheme cs, bool isDark, bool isTurkish, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appPreferences,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            // Theme Mode
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: cs.secondary, size: 20),
              ),
              title: Text(l10n.themeModeLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: Switch(
                value: settings.isDark,
                activeThumbColor: cs.primary,
                onChanged: (_) => settings.toggleTheme(),
              ),
            ),
            const Divider(height: 16),
            // Language Selection
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.language_rounded, color: cs.secondary, size: 20),
              ),
              title: Text(l10n.language, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(2),
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  isSelected: <bool>[
                    settings.locale.languageCode == 'en',
                    settings.locale.languageCode == 'tr',
                  ],
                  onPressed: (int index) {
                    final newLocale = index == 0 ? const Locale('en') : const Locale('tr');
                    settings.setLocale(newLocale);
                  },
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 32),
                  fillColor: cs.primary,
                  selectedColor: Colors.white,
                  color: cs.onSurface.withValues(alpha: 0.6),
                  borderWidth: 0,
                  children: const <Widget>[
                    Text('EN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    Text('TR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyToolsCard(ColorScheme cs, bool isDark, bool isTurkish, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.advancedLegacyTools,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/ocr');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.document_scanner_outlined, color: Colors.orange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.ocrScan,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.ocrScannerDesc,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/question-bank');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.collections_bookmark_outlined, color: Colors.purple, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.questionBank,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.questionBankDesc,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, ColorScheme cs, bool isDark, bool isTurkish, AppLocalizations l10n) {
    final limitService = Provider.of<UsageLimitService>(context);
    final isPremium = limitService.isPremium;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isPremium
              ? (isDark ? Colors.cyan.withValues(alpha: 0.5) : Colors.cyan.shade300)
              : (isDark ? Colors.white10 : Colors.grey.shade200),
          width: isPremium ? 2.0 : 1.5,
        ),
      ),
      child: Container(
        decoration: isPremium
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.cyan.withValues(alpha: 0.15),
                          cs.primaryContainer.withValues(alpha: 0.1),
                        ]
                      : [
                          Colors.cyan.shade50,
                          Colors.blue.shade50,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? Colors.cyan.withValues(alpha: 0.2)
                        : cs.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPremium ? Icons.stars_rounded : Icons.star_border_rounded,
                    color: isPremium ? Colors.cyan : cs.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium
                            ? (isTurkish ? "MedAI Pro Üyeliği Aktif" : "MedAI Pro Active")
                            : (isTurkish ? "MedAI Ücretsiz Sürüm" : "MedAI Free Tier"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPremium ? (isDark ? Colors.white : Colors.cyan.shade900) : cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPremium
                            ? (isTurkish ? "PRO Üye: 50 Günlük Limit" : "PRO Member: 50 Daily Limit")
                            : (isTurkish ? "Ücretsiz Üye: 5 Günlük Limit" : "Free Member: 5 Daily Limit"),
                        style: TextStyle(
                          fontSize: 12,
                          color: isPremium ? (isDark ? Colors.cyan.shade300 : Colors.cyan.shade700) : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isPremium
                  ? (isTurkish
                      ? "Günlük 50 klinik vaka hakkı, öncelikli sunucular, vaka görselleştirme ve tıbbi OCR çözme."
                      : "Enjoy 50 daily clinical queries, priority servers, diagnostic insight graphs, and prescription OCR.")
                  : (isTurkish
                      ? "Günlük 5 klinik vaka hakkıyla sınırlı erişim. Tüm özellikleri açmak için Pro'ya yükseltin."
                      : "Limited to 5 daily clinical cases. Upgrade to unlock the full clinical potential of MedAI."),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: isPremium
                  ? ElevatedButton.icon(
                      onPressed: () => _openCustomerCenter(),
                      icon: const Icon(Icons.settings_suggest_rounded, size: 18),
                      label: Text(
                        isTurkish ? "Aboneliği Yönet" : "Manage Subscription",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.cyan.withValues(alpha: 0.2) : Colors.cyan.shade100,
                        foregroundColor: isDark ? Colors.cyan : Colors.cyan.shade900,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark ? Colors.cyan.withValues(alpha: 0.3) : Colors.cyan.shade300,
                          ),
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/premium-paywall');
                      },
                      icon: const Icon(Icons.bolt, size: 18),
                      label: Text(
                        isTurkish ? "MedAI Pro'ya Yükselt" : "Upgrade to MedAI Pro",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCustomerCenter() async {
    final limitService = Provider.of<UsageLimitService>(context, listen: false);
    if (CentralConfig.isRevenueCatMockMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Customer Center is not available in mock mode. You are currently a Premium member via local mock."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      await RevenueCatUI.presentCustomerCenter();
      // Sync entitlement status after returning from Customer Center (user might have canceled)
      await limitService.syncSubscriptionStatus();
    } catch (e) {
      debugPrint('[Developer Warning] Failed to present Customer Center: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error opening Customer Center: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
