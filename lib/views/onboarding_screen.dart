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
        illustration: const _TipAkademiLogoIllustration(
          shape: BoxShape.circle,
          glowColor: Color(0xFF00E5FF),
        ),
      ),
      _OnboardingSlide(
        title: l10n.onboardingSlide2Title,
        description: l10n.onboardingSlide2Desc,
        illustration: const _TipAkademiLogoIllustration(
          shape: BoxShape.rectangle,
          glowColor: Color(0xFF3B82F6),
          borderRadius: 24,
        ),
      ),
      _OnboardingSlide(
        title: l10n.onboardingSlide3Title,
        description: l10n.onboardingSlide3Desc,
        illustration: const _TipAkademiLogoIllustration(
          shape: BoxShape.circle,
          glowColor: Color(0xFF8B5CF6),
        ),
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

/// Official TıpAkademi icon-only logo in a glowing branded container.
/// Used on all onboarding slides for consistent branding.
class _TipAkademiLogoIllustration extends StatelessWidget {
  final BoxShape shape;
  final Color glowColor;
  final double borderRadius;

  const _TipAkademiLogoIllustration({
    required this.shape,
    required this.glowColor,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0A1628);

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: shape,
        color: darkBlue,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
        border: Border.all(
          color: glowColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.30),
            blurRadius: 30,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.12),
            blurRadius: 60,
            spreadRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius - 2)
            : BorderRadius.circular(90),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Image.asset(
            'assets/images/tipakademi_icon.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
