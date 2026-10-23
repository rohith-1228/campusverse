import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_orb.dart';
import '../auth/demo_login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.rocket_launch_rounded,
      title: 'Discover Every Event\nAcross Campus',
      description:
          'From flagship hackathons and developer summits to sports meets and cultural fiestas — explore curated campus happenings in real time.',
      accentColor: AppColors.primary,
    ),
    _OnboardingPageData(
      icon: Icons.qr_code_2_rounded,
      title: 'Seamless Registration\n& Digital Passes',
      description:
          'One-click registration with automated verification. Get an admission pass complete with an authentic QR code for quick gate check-in.',
      accentColor: AppColors.electricBlue,
    ),
    _OnboardingPageData(
      icon: Icons.schedule_rounded,
      title: 'Never Miss a Beat\nWith Live Reminders',
      description:
          'Bookmark must-attend sessions, track schedule changes, and review your event history — all with offline-ready local persistence.',
      accentColor: AppColors.secondary,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DemoLoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -50,
            right: -50,
            child: GradientOrb(
              size: 320,
              colors: [page.accentColor, AppColors.secondary],
            ),
          ),
          const Positioned(
            bottom: -80,
            left: -80,
            child: GradientOrb(
              size: 300,
              colors: [AppColors.primary, AppColors.neonPink],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Skip Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'CampusVerse',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withAlpha((0.7 * 255).round()),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final item = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Big Feature Icon in Glass Pod
                            GlassCard(
                              padding: const EdgeInsets.all(36),
                              borderRadius: 40,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      item.accentColor,
                                      item.accentColor.withAlpha((0.3 * 255).round()),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 38),

                            // Title
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.25,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Description
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.5,
                                color: Colors.white.withAlpha((0.75 * 255).round()),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls: Indicator Dots & Continue Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primaryLight
                                  : Colors.white.withAlpha((0.25 * 255).round()),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      // Continue / Get Started Button
                      ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          backgroundColor: AppColors.primary,
                        ),
                        child: Row(
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
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

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}
