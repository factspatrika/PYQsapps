import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'caching_service.dart';

class PurchaseService {
  static late Razorpay _razorpay;

  // Initialize Razorpay
  static void init(BuildContext context) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) => _handlePaymentSuccess(response, context));
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) => _handlePaymentError(response, context));
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) => _handleExternalWallet(response, context));
  }

  // Handle successful payment
  static void _handlePaymentSuccess(PaymentSuccessResponse response, BuildContext context) async {
    await completePremiumActivation(response.paymentId ?? '', context);
  }

  // Handle failed payment
  static void _handlePaymentError(PaymentFailureResponse response, BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}')),
      );
    }
  }

  // Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response, BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
      );
    }
  }

  // Complete premium activation: update sheets and set local status
  static Future<void> completePremiumActivation(String paymentId, BuildContext context) async {
    final box = Hive.box(CachingService.settingsBoxName);
    final phone = box.get('profile_phone', defaultValue: '') as String;
    
    // 1. Sync success payment status to Google Sheets database
    if (phone.isNotEmpty) {
      await CachingService.updateUserPremiumStatus(phone, true, paymentId: paymentId);
    }
    
    // 2. Unlock locally
    await unlockPremium();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Premium Unlocked Successfully! Payment ID: $paymentId')),
      );
      Navigator.pop(context); // Close CheckoutScreen and go back
    }
  }

  // Trigger Razorpay Checkout
  static void buyPremium(BuildContext context) {
    final box = Hive.box(CachingService.settingsBoxName);
    final contactPhone = box.get('profile_phone', defaultValue: '') as String;
    final contactName = box.get('profile_name', defaultValue: 'Railway Learner') as String;

    final razorpayKey = box.get('razorpay_key', defaultValue: 'rzp_test_mock_key') as String;
    final premiumPriceRs = box.get('premium_price_rs', defaultValue: 29) as int;

    // Developer Test Bypass
    if (razorpayKey == 'rzp_test_mock_key' || razorpayKey.trim().isEmpty) {
      _showDemoPaymentDialog(context);
      return;
    }

    var options = {
      'key': razorpayKey,
      'amount': premiumPriceRs * 100, // Amount in paise (e.g. 29 * 100 = 2900 paise = ₹29)
      'name': 'Vidya Saathi',
      'description': 'Lifetime Premium Access',
      'prefill': {
        'contact': contactPhone.isNotEmpty ? contactPhone : '9876543210',
        'email': 'student@vidyasaathi.com',
        'name': contactName
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error launching Razorpay: $e');
    }
  }

  static void _showDemoPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.bug_report_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Demo Payment Mode',
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
            ],
          ),
          content: const Text(
            'A dummy/mock Razorpay Key is detected. Would you like to simulate a successful payment transaction to test your Google Sheets & premium unlock?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                final mockId = 'pay_mock_tx_${DateTime.now().millisecondsSinceEpoch}';
                completePremiumActivation(mockId, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Simulate Success', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Clean up resources
  static void dispose() {
    _razorpay.clear();
  }

  // --- Hive Logic ---
  static bool get isPremiumUser {
    final box = Hive.box(CachingService.settingsBoxName);
    return box.get('is_premium', defaultValue: false) as bool;
  }

  static Future<void> unlockPremium() async {
    final box = Hive.box(CachingService.settingsBoxName);
    await box.put('is_premium', true);
  }
}
