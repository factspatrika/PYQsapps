import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/caching_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim().isNotEmpty 
        ? _nameController.text.trim() 
        : 'Railway Learner';

    try {
      // Connect to Google Sheets to check profile and purchase
      final result = await CachingService.checkUserPremiumStatus(phone, name: name);
      
      final box = Hive.box(CachingService.settingsBoxName);
      await box.put('is_logged_in', true);
      await box.put('profile_phone', phone);
      await box.put('profile_name', result['name'] ?? name);
      
      final isPremium = result['isPremium'] == true;
      await box.put('is_premium', isPremium);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPremium 
                ? 'Welcome back, Premium User!' 
                : 'Logged in successfully!'),
            backgroundColor: isPremium ? Colors.teal : Colors.blueGrey,
          ),
        );
        Navigator.pop(context);
        widget.onLoginSuccess();
      }
    } catch (e) {
      // Offline/Error fallback: Save locally and notify
      final box = Hive.box(CachingService.settingsBoxName);
      await box.put('is_logged_in', true);
      await box.put('profile_phone', phone);
      await box.put('profile_name', name);
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offline login. Status will sync when online.'),
            backgroundColor: Colors.amber[800],
          ),
        );
        Navigator.pop(context);
        widget.onLoginSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Login / SignUp',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Promo Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFF041626), const Color(0xFF0D253F)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock_person_rounded, color: Color(0xFFFED65B), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Premium Authentication',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unlock lifetime premium questions, mocks & answers with your personal learning profile.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                Text(
                  'Welcome to Railway Prep',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to secure and proceed with your purchase',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name (Optional)',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '98765-XXXXX',
                    prefixIcon: Icon(Icons.phone_iphone_rounded, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter your phone number';
                    if (val.trim().length < 10) return 'Enter a valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Login & Proceed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
