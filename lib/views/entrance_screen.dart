import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';

class EntranceScreen extends StatefulWidget {
  const EntranceScreen({super.key});

  @override
  State<EntranceScreen> createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 3.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      // 1. Sign out of Google to ensure the account selection sheet always prompts (fixes transitions issues)
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Google Sign-out before sign-in ignored: $e');
      }

      // 2. Trigger Google Sign-In authenticate
      final googleUser = await GoogleSignIn.instance.authenticate();
      
      // 3. Obtain authentication details synchronously (it is not a Future in v7)
      final googleAuth = googleUser.authentication;

      // 4. Retrieve access token via authorizeScopes explicitly for scopes
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
      final accessToken = clientAuth.accessToken;

      // 5. Construct credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      // 6. Sign in to Firebase Auth.
      // Once signed in, authStateChanges() fires, triggering AuthGate to route to HomeScreen.
      await FirebaseAuth.instance.signInWithCredential(credential);

    } catch (e) {
      debugPrint('Google Sign-In Exception: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.signInFailed}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const deepNavy = Color(0xFF060D1A);
    const darkBlue = Color(0xFF0F1E36);
    const electricTeal = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: deepNavy,
      body: Stack(
        children: [
          // Background ambient lights
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: electricTeal.withValues(alpha: 0.12),
                    blurRadius: 150,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 160,
                    spreadRadius: 90,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Geometric Brand Emblem
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: darkBlue,
                                border: Border.all(
                                  color: electricTeal.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: electricTeal.withValues(alpha: 0.15),
                                    blurRadius: _glowAnimation.value,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: _FuturisticMedicalLogo(size: 80),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // App Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Motivational Sub-header
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          l10n.yourClinicalCoPilot,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.75),
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    
                    const Spacer(),

                    // Google Sign-In Action
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isAuthenticating
                          ? const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(electricTeal),
                                ),
                                SizedBox(height: 16),
                              ],
                            )
                          : Container(
                              width: double.infinity,
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: electricTeal.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Theme(
                                data: ThemeData(
                                  splashColor: electricTeal.withValues(alpha: 0.1),
                                  highlightColor: electricTeal.withValues(alpha: 0.05),
                                ),
                                child: InkWell(
                                  onTap: _handleGoogleSignIn,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: darkBlue,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: electricTeal.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomPaint(
                                          size: const Size(22, 22),
                                          painter: _GoogleVectorPainter(),
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          l10n.continueWithGoogle,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuturisticMedicalLogo extends StatelessWidget {
  final double size;
  const _FuturisticMedicalLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MedicalLogoPainter(),
    );
  }
}

class _MedicalLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const electricTeal = Color(0xFF00E5FF);
    final width = size.width;
    final height = size.height;

    // Outer Hexagon
    final hexPath = Path();
    final double r = width / 2;
    final center = Offset(width / 2, height / 2);
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * 3.14159 / 180;
      final x = center.dx + r * 0.9 * cos(angle);
      final y = center.dy + r * 0.9 * sin(angle);
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();

    final hexPaint = Paint()
      ..color = electricTeal.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(hexPath, hexPaint);

    final hexStroke = Paint()
      ..color = electricTeal.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(hexPath, hexStroke);

    // Dynamic inner cross representing medical focus
    final crossPaint = Paint()
      ..color = electricTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Draw Cross
    final double len = r * 0.45;
    canvas.drawLine(Offset(center.dx - len, center.dy), Offset(center.dx + len, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - len), Offset(center.dx, center.dy + len), crossPaint);

    // Glowing core dot
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoogleVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Offset center = Offset(r, r);

    // Google 'G' geometry
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Red sector
    paint.color = const Color(0xFFEA4335);
    final pathRed = Path()
      ..moveTo(r, r)
      ..lineTo(r - 0.7 * r, r - 0.7 * r)
      ..arcTo(Rect.fromCircle(center: center, radius: r), -2.35, 1.57, false)
      ..lineTo(r, r);
    canvas.drawPath(pathRed, paint);

    // Yellow sector
    paint.color = const Color(0xFFFBBC05);
    final pathYellow = Path()
      ..moveTo(r, r)
      ..lineTo(r - 0.7 * r, r - 0.7 * r)
      ..arcTo(Rect.fromCircle(center: center, radius: r), -2.35, -1.57, false)
      ..lineTo(r, r);
    canvas.drawPath(pathYellow, paint);

    // Green sector
    paint.color = const Color(0xFF34A853);
    final pathGreen = Path()
      ..moveTo(r, r)
      ..lineTo(r + 0.7 * r, r + 0.7 * r)
      ..arcTo(Rect.fromCircle(center: center, radius: r), 0.78, 1.57, false)
      ..lineTo(r, r);
    canvas.drawPath(pathGreen, paint);

    // Blue sector (with the bar)
    paint.color = const Color(0xFF4285F4);
    final pathBlue = Path()
      ..moveTo(r, r)
      ..lineTo(r + 0.7 * r, r + 0.7 * r)
      ..arcTo(Rect.fromCircle(center: center, radius: r), 0.78, -1.57, false)
      ..lineTo(r, r);
    canvas.drawPath(pathBlue, paint);

    // Inner cutout to make it a 'G'
    final cutoutPaint = Paint()
      ..color = const Color(0xFF0F1E36) // Matches background color of the button
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 0.45, cutoutPaint);

    // The horizontal blue bar of the 'G'
    paint.color = const Color(0xFF4285F4);
    final barRect = Rect.fromLTRB(r, r - r * 0.2, r + r * 0.9, r + r * 0.2);
    canvas.drawRect(barRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
