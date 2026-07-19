import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/caching_service.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class PremiumPlansScreen extends StatelessWidget {
  const PremiumPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2B3B), // primary-container
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Elevate Your Preparation',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get exclusive access to comprehensive study materials designed to help you ace your competitive exams with Vidya Saathi.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Why Go Premium
              const Text(
                'Why Go Premium?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              ),
              const SizedBox(height: 16),
              
              // Bento Grid for Features
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildFeatureCard(
                      icon: Icons.history_edu,
                      iconColor: AppTheme.secondaryColor,
                      iconBg: const Color(0xFFFED65B), // secondary-container
                      title: 'Unlock All 10,000+ PYQs',
                      subtitle: 'सभी PYQs अनलॉक करें',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallFeatureCard(
                      icon: Icons.quiz,
                      iconColor: const Color(0xFFD3E4FA), // primary-fixed
                      iconBg: const Color(0xFF1A2B3B), // primary-container
                      title: 'Premium Mock Tests',
                      subtitle: 'प्रीमियम मॉक टेस्ट',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSmallFeatureCard(
                      icon: Icons.lightbulb,
                      iconColor: const Color(0xFFE1E3E4), // tertiary-fixed
                      iconBg: const Color(0xFF272A2B), // tertiary-container
                      title: 'Detailed Explanations',
                      subtitle: 'विस्तृत व्याख्या',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Pricing Cards
              const Text(
                'Choose Your Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              ),
              const SizedBox(height: 16),
              
              // Single Premium Plan
              _buildPlanCard(
                context,
                title: 'Lifetime Premium Access',
                price: '₹29',
                period: 'one-time',
                features: ['Unlock All 10,000+ PYQs', 'Premium Mock Tests', 'Detailed Explanations'],
                isPopular: true,
                buttonText: 'Unlock Premium',
              ),
              
              const SizedBox(height: 32),
              
              // Payment Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToCheckout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Continue to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text('Secured with 256-bit SSL encryption', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required Color iconColor, required Color iconBg, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CC)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallFeatureCard({required IconData icon, required Color iconColor, required Color iconBg, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CC)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, {required String title, required String price, required String period, required List<String> features, required bool isPopular, required String buttonText}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPopular ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPopular ? Colors.transparent : const Color(0xFFC4C6CC)),
        boxShadow: isPopular ? [BoxShadow(color: AppTheme.secondaryColor.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)] : [],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isPopular)
            Positioned(
              top: -36,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFED65B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('MOST POPULAR', style: TextStyle(color: Color(0xFF745C00), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isPopular ? Colors.white : AppTheme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price, style: TextStyle(color: isPopular ? const Color(0xFFFFE088) : AppTheme.primaryColor, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text(period, style: TextStyle(color: isPopular ? const Color(0xFFD8E3FA) : AppTheme.subtitleColor, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 24),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: isPopular ? const Color(0xFFFFE088) : AppTheme.secondaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text(f, style: TextStyle(color: isPopular ? Colors.white : AppTheme.textColor, fontSize: 16)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _navigateToCheckout(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isPopular ? const Color(0xFFFED65B) : Colors.transparent,
                    foregroundColor: isPopular ? const Color(0xFF745C00) : AppTheme.primaryColor,
                    side: BorderSide(color: isPopular ? Colors.transparent : AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    final box = Hive.box(CachingService.settingsBoxName);
    final isLoggedIn = box.get('is_logged_in', defaultValue: false) as bool;

    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CheckoutScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onLoginSuccess: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
          ),
        ),
      );
    }
  }
}
