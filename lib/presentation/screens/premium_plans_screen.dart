import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/caching_service.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class PremiumPlansScreen extends StatelessWidget {
  const PremiumPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryBg = isDark ? const Color(0xFF000000) : theme.scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF0D1117) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFC4C6CC);
    final titleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : theme.colorScheme.onSurfaceVariant;
    final goldColor = const Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        backgroundColor: primaryBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upgrade to Premium',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: titleColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF161B22), const Color(0xFF090D12)]
                        : [const Color(0xFF1A2B3B), const Color(0xFF0D1824)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? goldColor.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? goldColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: goldColor, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Elevate Your Preparation',
                          style: TextStyle(color: goldColor, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get 1 Year unlimited access to 11,000+ Railway Science PYQs, topicwise tests, and authentic Hindi explanations.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Why Go Premium
              Text(
                'Why Go Premium?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
              ),
              const SizedBox(height: 16),
              
              // Bento Grid Features
              _buildFeatureCard(
                cardBg: cardBg,
                borderColor: borderColor,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                icon: Icons.history_edu_rounded,
                iconColor: goldColor,
                iconBg: goldColor.withValues(alpha: 0.15),
                title: 'Unlock All 11,000+ PYQs',
                subtitle: 'फिजिक्स, केमिस्ट्री व बायोलॉज़ी के सभी सवाल अनलॉक करें',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallFeatureCard(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      icon: Icons.quiz_rounded,
                      iconColor: goldColor,
                      iconBg: goldColor.withValues(alpha: 0.15),
                      title: 'Premium Mock Tests',
                      subtitle: 'सभी 53 अध्यायों के मॉक टेस्ट',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSmallFeatureCard(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      icon: Icons.lightbulb_rounded,
                      iconColor: goldColor,
                      iconBg: goldColor.withValues(alpha: 0.15),
                      title: 'Detailed Explanations',
                      subtitle: '100% विस्तृत हिंदी व्याख्याएँ',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Pricing Section Header
              Text(
                'Choose Your Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
              ),
              const SizedBox(height: 16),
              
              // Single Premium Plan Card
              _buildPlanCard(
                context,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                goldColor: goldColor,
                title: '1 Year Premium Access',
                price: '₹29',
                period: '/ 1 year access',
                features: [
                  'Unlock All 11,000+ Topicwise PYQs',
                  'All 53 Physics, Chem & Bio Topics',
                  'Detailed Step-by-Step Explanations',
                  '100% Offline Practice Supported',
                ],
                buttonText: 'Unlock Premium Now',
              ),
              
              const SizedBox(height: 32),
              
              // Big Payment CTA Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _navigateToCheckout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.black,
                    elevation: 6,
                    shadowColor: goldColor.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continue to Secure Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: subtitleColor),
                    const SizedBox(width: 6),
                    Text('Secured via Razorpay 256-bit SSL Encryption', style: TextStyle(color: subtitleColor, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: titleColor, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallFeatureCard({
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: subtitleColor, fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color goldColor,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required String buttonText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor, width: 2),
        boxShadow: [
          BoxShadow(color: goldColor.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: goldColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('BEST VALUE', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: TextStyle(color: goldColor, fontSize: 36, fontWeight: FontWeight.w900)),
              const SizedBox(width: 6),
              Text(period, style: TextStyle(color: subtitleColor, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: goldColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(f, style: TextStyle(color: titleColor, fontSize: 14.5, fontWeight: FontWeight.w500))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _navigateToCheckout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
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
