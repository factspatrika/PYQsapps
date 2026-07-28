import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/purchase_service.dart';
import '../../data/repositories/caching_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryBg = isDark ? const Color(0xFF000000) : theme.scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF0D1117) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFC4C6CC);
    final titleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : theme.colorScheme.onSurfaceVariant;
    final goldColor = const Color(0xFFFFD700);

    final box = Hive.box(CachingService.settingsBoxName);
    final price = box.get('premium_price_rs', defaultValue: 29) as int;

    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        backgroundColor: primaryBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Secure Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: titleColor)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Header
              Row(
                children: [
                  Icon(Icons.shopping_bag_rounded, color: goldColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ORDER SUMMARY',
                    style: TextStyle(color: goldColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? goldColor.withValues(alpha: 0.4) : borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: isDark ? goldColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))
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
                              Text(
                                '1 Year Premium Access',
                                style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Full access to all 11,000+ Premium PYQs and Mock Tests for 1 year.',
                                style: TextStyle(color: subtitleColor, fontSize: 13.5, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('₹$price', style: TextStyle(color: goldColor, fontSize: 26, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(color: borderColor),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount Payable', style: TextStyle(color: titleColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('₹${price.toStringAsFixed(2)}', style: TextStyle(color: goldColor, fontSize: 26, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Pay Now Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          PurchaseService.buyPremium(context);
                          await Future.delayed(const Duration(seconds: 3));
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                        )
                      : const Icon(Icons.lock_rounded, size: 20),
                  label: Text(
                    _isLoading ? 'Opening Payment Gateway...' : 'Pay ₹$price Now',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.black,
                    elevation: 6,
                    shadowColor: goldColor.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_rounded, color: goldColor, size: 16),
                  const SizedBox(width: 8),
                  Text('100% Secure Payment via Razorpay', style: TextStyle(color: subtitleColor, fontSize: 12.5, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your transaction is encrypted and secured by SSL. We do not store your payment card or banking details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtitleColor, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
