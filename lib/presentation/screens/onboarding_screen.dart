import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'icon': '🚆',
      'tag': 'WELCOME TO',
      'title': 'Railways Science PYQs',
      'desc': 'रेलवे परीक्षा (RRB NTPC, Group D, ALP, Technicians, JE) की सबसे सटीक और प्रभावी तैयारी',
    },
    {
      'icon': '🧬',
      'tag': '11,000+ QUESTIONS',
      'title': 'भौतिक, रसायन व जीव विज्ञान',
      'desc': 'सभी 53 अध्यायों के 100% विस्तृत उत्तर, मुख्य बिंदु और परीक्षा उपयोगी तथ्य',
    },
    {
      'icon': '⚡',
      'tag': 'OFFLINE READY',
      'title': '100% ऑफ़लाइन अभ्यास',
      'desc': 'बिना इंटरनेट के कभी भी, कहीं भी मॉक टेस्ट और पिछले वर्षों के प्रश्न हल करें',
    },
  ];

  void _finishOnboarding() async {
    final box = Hive.box('settingsBox');
    await box.put('onboarding_completed', true);
    await box.put('onboarding_v2_completed', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure Black Utkarsh Theme
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_railway_filled_rounded, color: Color(0xFFFFD700), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'RRB EXAMS 2026',
                          style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Skip
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),

            // Page View Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, idx) {
                  final item = _pages[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Center Graphic / Logo
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF11161D),
                            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: item.containsKey('image')
                                ? Image.asset(
                                    item['image']!,
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => const Icon(
                                      Icons.directions_railway_filled,
                                      size: 70,
                                      color: Color(0xFFFFD700),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      item['icon']!,
                                      style: const TextStyle(fontSize: 64),
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Tagline
                        Text(
                          item['tag']!,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Title
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          item['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & CTA Button
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i ? const Color(0xFFFFD700) : const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Big Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700), // Utkarsh Vivid Gold
                        foregroundColor: Colors.black,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1 ? 'शुरू करें (Get Started)' : 'आगे बढ़ें (Next)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
