import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';
import '../../data/repositories/purchase_service.dart';
import '../../data/repositories/caching_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    PurchaseService.init(context);
  }

  @override
  void dispose() {
    PurchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(CachingService.settingsBoxName);
    final price = box.get('premium_price_rs', defaultValue: 29) as int;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Secure Checkout'),
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
              // Order Summary Section
              Row(
                children: [
                  const Icon(Icons.shopping_bag, color: Color(0xFF1A2B3B), size: 20), // primary-container
                  const SizedBox(width: 8),
                  Text('ORDER SUMMARY', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC4C6CC)), // outline-variant
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF1A2B3B).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lifetime Premium Access', style: TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Full access to all Premium PYQs and Mock Tests.', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14)),
                            ],
                          ),
                        ),
                        Text('₹$price', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFC4C6CC)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('₹${price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Pay Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    PurchaseService.buyPremium(context);
                  },
                  icon: const Icon(Icons.lock, size: 20),
                  label: const Text('Pay Now', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, color: AppTheme.subtitleColor, size: 16),
                  SizedBox(width: 8),
                  Text('100% Secure Payment', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Your transaction is encrypted and secured by SSL. We do not store your credit card details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF74777D), fontSize: 14), // outline
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
