import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_and_locale_service.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDone() {
    final settingsService = Provider.of<ThemeAndLocaleService>(context, listen: false);
    settingsService.setSeenOnboarding(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const deepNavy = Color(0xFF060D1A);
    const darkBlue = Color(0xFF0F1E36);
    const electricTeal = Color(0xFF00E5FF);

    final List<Widget> slides = [
      _OnboardingSlide(
        title: l10n.onboardingSlide1Title,
        description: l10n.onboardingSlide1Desc,
        illustration: const _FuturisticEmblemIllustration(),
      ),
      _OnboardingSlide(
        title: l10n.onboardingSlide2Title,
        description: l10n.onboardingSlide2Desc,
        illustration: const _ScannerIllustration(),
      ),
      _OnboardingSlide(
        title: l10n.onboardingSlide3Title,
        description: l10n.onboardingSlide3Desc,
        illustration: const _MedsIllustration(),
      ),
    ];

    return Scaffold(
      backgroundColor: deepNavy,
      body: Stack(
        children: [
          // Background ambient glowing lights
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: electricTeal.withValues(alpha: 0.12),
                    blurRadius: 150,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 160,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Skip button (if not on last page)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: AnimatedOpacity(
                      opacity: _currentPage < slides.length - 1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: _currentPage < slides.length - 1 ? _onDone : null,
                        child: Text(
                          l10n.onboardingSkip,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main PageView content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return slides[index];
                    },
                  ),
                ),

                // Bottom section (Indicator + Navigation Buttons)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Active slide indicator dots
                      Row(
                        children: List.generate(
                          slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? electricTeal : Colors.white30,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      // Next / Get Started button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: electricTeal.withValues(alpha: 0.2),
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
                            onTap: () {
                              if (_currentPage < slides.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                );
                              } else {
                                _onDone();
                              }
                            },
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
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentPage == slides.length - 1
                                        ? l10n.onboardingDone
                                        : l10n.onboardingNext,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentPage == slides.length - 1
                                        ? Icons.rocket_launch_rounded
                                        : Icons.arrow_forward_rounded,
                                    color: electricTeal,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final Widget illustration;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration space
          Expanded(
            child: Center(
              child: illustration,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// A glowing geometric medical cross illustration
class _FuturisticEmblemIllustration extends StatelessWidget {
  const _FuturisticEmblemIllustration();

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0F1E36);
    const electricTeal = Color(0xFF00E5FF);

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: darkBlue,
        border: Border.all(
          color: electricTeal.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: electricTeal.withValues(alpha: 0.25),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(100, 100),
          painter: _EmblemPainter(),
        ),
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const electricTeal = Color(0xFF00E5FF);
    final width = size.width;
    final double r = width / 2;
    final center = Offset(width / 2, size.height / 2);

    // Outer Hexagon
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
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

    // Inner cross representing medical focus
    final crossPaint = Paint()
      ..color = electricTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final double len = r * 0.45;
    canvas.drawLine(Offset(center.dx - len, center.dy), Offset(center.dx + len, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - len), Offset(center.dx, center.dy + len), crossPaint);

    // Glowing core dot
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A premium OCR Prescription Scanner illustration with glowing box and laser line
class _ScannerIllustration extends StatelessWidget {
  const _ScannerIllustration();

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0F1E36);
    const electricTeal = Color(0xFF00E5FF);

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: electricTeal.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: electricTeal.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(110, 110),
          painter: _ScannerPainter(),
        ),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const electricTeal = Color(0xFF00E5FF);

    // Outer document shape
    final docPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final docPath = Path()
      ..moveTo(20, 10)
      ..lineTo(70, 10)
      ..lineTo(90, 30)
      ..lineTo(90, 100)
      ..lineTo(20, 100)
      ..close();
    canvas.drawPath(docPath, docPaint);

    final docStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(docPath, docStroke);

    // Text mock lines inside document
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(35, 30), const Offset(60, 30), linePaint);
    canvas.drawLine(const Offset(35, 45), const Offset(75, 45), linePaint);
    canvas.drawLine(const Offset(35, 60), const Offset(70, 60), linePaint);
    canvas.drawLine(const Offset(35, 75), const Offset(55, 75), linePaint);

    // Scanning target corners
    final cornerPaint = Paint()
      ..color = electricTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Top-Left corner
    canvas.drawPath(Path()..moveTo(10, 25)..lineTo(10, 10)..lineTo(25, 10), cornerPaint);
    // Top-Right corner
    canvas.drawPath(Path()..moveTo(100, 25)..lineTo(100, 10)..lineTo(85, 10), cornerPaint);
    // Bottom-Left corner
    canvas.drawPath(Path()..moveTo(10, 85)..lineTo(10, 100)..lineTo(25, 100), cornerPaint);
    // Bottom-Right corner
    canvas.drawPath(Path()..moveTo(100, 85)..lineTo(100, 100)..lineTo(85, 100), cornerPaint);

    // Laser Line
    final laserPaint = Paint()
      ..color = electricTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..imageFilter = const ColorFilter.mode(electricTeal, BlendMode.srcATop);

    canvas.drawLine(const Offset(5, 50), const Offset(105, 50), laserPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A premium Medicine Programs & Board Exams illustration with orbiting rings
class _MedsIllustration extends StatelessWidget {
  const _MedsIllustration();

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0F1E36);
    const electricTeal = Color(0xFF00E5FF);

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: darkBlue,
        shape: BoxShape.circle,
        border: Border.all(
          color: electricTeal.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: electricTeal.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(100, 100),
          painter: _MedsPainter(),
        ),
      ),
    );
  }
}

class _MedsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const electricTeal = Color(0xFF00E5FF);
    const darkBlue = Color(0xFF0F1E36);
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);

    // Outer Orbiting Rings
    final ringPaint = Paint()
      ..color = electricTeal.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(Rect.fromCenter(center: center, width: 85, height: 35), ringPaint);
    canvas.drawOval(Rect.fromCenter(center: center, width: 35, height: 85), ringPaint);

    // Pill Shape in center
    final pillPaint1 = Paint()
      ..color = electricTeal
      ..style = PaintingStyle.fill;
    final pillPaint2 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw rotated pill
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 4);

    // Left half (Teal)
    final pathLeft = Path()
      ..addArc(Rect.fromLTWH(-28, -12, 24, 24), pi / 2, pi)
      ..lineTo(0, -12)
      ..lineTo(0, 12)
      ..lineTo(-16, 12)
      ..close();
    canvas.drawPath(pathLeft, pillPaint1);

    // Right half (White)
    final pathRight = Path()
      ..addArc(Rect.fromLTWH(4, -12, 24, 24), -pi / 2, pi)
      ..lineTo(0, 12)
      ..lineTo(0, -12)
      ..lineTo(16, -12)
      ..close();
    canvas.drawPath(pathRight, pillPaint2);

    // Separator line
    final sepPaint = Paint()
      ..color = darkBlue.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(0, -12), const Offset(0, 12), sepPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
