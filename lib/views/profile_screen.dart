import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_and_locale_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GoogleSignInAccount? _currentUser;
  bool _isSigningIn = false;
  String _selectedTrack = 'Phase 4: Clinical Clerkships';
  SharedPreferences? _prefs;

  final List<String> _tracks = [
    'Phase 1: Basic Sciences',
    'Phase 2: Pre-clinical Studies',
    'Phase 3: Systemic Pathology & Medicine',
    'Phase 4: Clinical Clerkships',
    'Phase 5: Advanced Clerkships',
    'Phase 6: Internship / Family Medicine',
    'TUS Preparation Track',
  ];

  @override
  void initState() {
    super.initState();
    _initPreferences();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
      GoogleSignIn.instance.authenticationEvents.listen((event) {
        if (mounted) {
          setState(() {
            _currentUser = switch (event) {
              GoogleSignInAuthenticationEventSignIn(:final user) => user,
              GoogleSignInAuthenticationEventSignOut() => null,
            };
            _isSigningIn = false;
          });
        }
      });
      // Attempt lightweight authentication
      final user = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      debugPrint('Google Sign-In initialization failed: $e');
    }
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedTrack = _prefs?.getString('academic_track') ?? 'Phase 4: Clinical Clerkships';
      });
    }
  }

  Future<void> _saveTrack(String track) async {
    if (_prefs != null) {
      await _prefs!.setString('academic_track', track);
      if (mounted) {
        setState(() {
          _selectedTrack = track;
        });
      }
    }
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      final user = await GoogleSignIn.instance.authenticate();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isSigningIn = false;
        });
      }
    } catch (error) {
      debugPrint('Google Sign-In failed: $error');
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (error) {
      debugPrint('Google Sign-Out failed: $error');
    }
    if (mounted) {
      setState(() {
        _currentUser = null;
      });
    }
  }

  String get _universityDomain {
    if (_currentUser == null) return '';
    final email = _currentUser!.email;
    final parts = email.split('@');
    if (parts.length > 1) {
      return parts[1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<ThemeAndLocaleService>(context);
    final isTurkish = settings.locale.languageCode == 'tr';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTurkish ? 'Öğrenci Profili' : 'Student Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Google Sign-In Section
          _buildGoogleSignInCard(isTurkish, isDark, cs),
          const SizedBox(height: 20),

          // Academic Track / Medicine Programs Tracker
          _buildAcademicTrackCard(isTurkish, isDark, cs),
          const SizedBox(height: 20),

          // Preferences Card (Theme & Locale)
          _buildPreferencesCard(settings, isTurkish, isDark, cs),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInCard(bool isTurkish, bool isDark, ColorScheme cs) {
    final user = _currentUser;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTurkish ? 'Google Öğrenci Kimliği' : 'Google Student Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            if (user != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    backgroundColor: cs.primaryContainer,
                    child: user.photoUrl == null
                        ? Text(
                            user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: cs.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Student',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        if (_universityDomain.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _universityDomain,
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _handleSignOut,
                  icon: const Icon(Icons.logout),
                  label: Text(isTurkish ? 'Çıkış Yap' : 'Sign Out'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error),
                  ),
                ),
              ),
            ] else ...[
              Text(
                isTurkish
                    ? 'Üniversite kimliğinizi senkronize etmek için okul hesabınızla giriş yapın.'
                    : 'Sign in with your student email to sync your university domain.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isSigningIn ? null : _handleSignIn,
                  icon: _isSigningIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    _isSigningIn
                        ? (isTurkish ? 'Giriş Yapılıyor...' : 'Signing In...')
                        : (isTurkish ? 'Google ile Giriş Yap' : 'Sign in with Google'),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicTrackCard(bool isTurkish, bool isDark, ColorScheme cs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTurkish ? 'Eğitim & TUS Müfredatı' : 'Medicine Curriculums',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTurkish
                  ? 'Hızlı şablonları ve vaka analizlerini optimize etmek için akademik döneminizi seçin.'
                  : 'Select your current track to customize guidelines and high-yield study templates.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTrack,
                  isExpanded: true,
                  items: _tracks.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _saveTrack(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(ThemeAndLocaleService settings, bool isTurkish, bool isDark, ColorScheme cs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTurkish ? 'Kullanıcı Tercihleri' : 'User Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Theme Switcher Tile
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: cs.secondary),
              title: Text(isTurkish ? 'Karanlık Tema' : 'Dark Mode'),
              trailing: Switch(
                value: settings.isDark,
                onChanged: (_) => settings.toggleTheme(),
              ),
            ),
            const Divider(height: 24, thickness: 1),
            // Language Selection Tile
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.language, color: cs.secondary),
              title: Text(isTurkish ? 'Dil Seçimi' : 'Language'),
              trailing: ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                isSelected: <bool>[
                  settings.locale.languageCode == 'en',
                  settings.locale.languageCode == 'tr',
                ],
                onPressed: (int index) {
                  final newLocale = index == 0 ? const Locale('en') : const Locale('tr');
                  settings.setLocale(newLocale);
                },
                constraints: const BoxConstraints(minWidth: 50, minHeight: 36),
                children: const <Widget>[
                  Text('EN', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('TR', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
