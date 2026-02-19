import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';

import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/pages/register_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/presentation/pages/forgot_password_page.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/services/google_auth_service.dart';
import 'package:mobile_app_frontend/core/services/local_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_app_frontend/services/admob_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final _authService = AuthService();
  final _googleAuthService = GoogleAuthService();

  InputFieldState _emailFieldState = InputFieldState.defaultState;
  InputFieldState _passwordFieldState = InputFieldState.defaultState;

  // AdMob variables
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Delay ad loading to ensure network is ready
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _loadInterstitialAd();
      }
    });
  }

  /// Load interstitial ad in background
  Future<void> _loadInterstitialAd() async {
    _interstitialAd = await AdMobService.loadInterstitialAd(maxRetries: 2);
    if (_interstitialAd != null) {
      setState(() => _isAdLoaded = true);
      print('✅ Login ad loaded and ready');
    } else {
      print('⚠️ Ad failed to load, will skip ad');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  /// Navigate to home page
  void _navigateToHome(String token, int customerId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleDetailsHomePage(
          customerId: customerId,
          token: token,
        ),
      ),
    );
  }

  /// Show ad and navigate to home
  void _showAdAndNavigate(String token, int customerId) {
    if (_isAdLoaded && _interstitialAd != null) {
      // Set up ad callbacks
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('🎬 Interstitial ad displayed');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('❌ Ad closed by user');
          ad.dispose();
          _navigateToHome(token, customerId);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('⚠️ Ad failed to show: $error');
          ad.dispose();
          _navigateToHome(token, customerId);
        },
      );

      // Show the ad
      _interstitialAd!.show();
    } else {
      // No ad loaded, go directly to home
      print('⚠️ No ad available, navigating directly');
      _navigateToHome(token, customerId);
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.loginCustomer(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (result != null) {
      final token = result['token'];
      final customerId = result['customerId'];

      // Save authentication data to local storage
      await LocalStorageService.saveAuthData(
        token: token,
        customerId: customerId,
      );

      print('💾 Authentication data saved after login');

      // Show ad then navigate
      _showAdAndNavigate(token, customerId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid credentials or email not verified')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await _googleAuthService.signInWithGoogle();

      if (result != null) {
        final token = result['token'];
        final customerId = result['customerId'];

        await LocalStorageService.saveAuthData(
          token: token,
          customerId: customerId,
        );

        print('💾 Authentication data saved after Google login');

        // Show ad then navigate
        _showAdAndNavigate(token, customerId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in was cancelled or failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in error: $e')),
      );
    }

    setState(() {
      _isGoogleLoading = false;
    });
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  placeholder: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  state: _emailFieldState,
                  onChanged: (val) {
                    setState(
                        () => _emailFieldState = InputFieldState.defaultState);
                  },
                ),
                const SizedBox(height: 20),
                InputFieldAtom(
                  placeholder: 'Password',
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  state: _passwordFieldState,
                  obscureText: _obscurePassword,
                  showTrailingIcon: true,
                  trailingIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onTrailingIconTap: _togglePasswordVisibility,
                  onChanged: (val) {
                    setState(() =>
                        _passwordFieldState = InputFieldState.defaultState);
                  },
                ),
                const SizedBox(height: 8),
                
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToForgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'By proceeding, you agree to the Terms and Conditions',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Sign in with Email',
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    onTap: _handleLogin,
                  ),
                ),

                const SizedBox(height: 16),

                // Divider with "or"
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white38, thickness: 1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ),
                    Expanded(child: Divider(color: Colors.white38, thickness: 1)),
                  ],
                ),

                const SizedBox(height: 16),

                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Image.asset(
                            'assets/google_logo.png',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.g_mobiledata, color: Colors.white, size: 28);
                            },
                          ),
                    label: Text(
                      _isGoogleLoading ? 'Signing in...' : 'Sign in with Google',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: _navigateToRegister,
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
