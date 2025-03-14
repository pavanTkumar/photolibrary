import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../widgets/animated_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the terms and conditions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      // Simulate signup API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to main screen
        context.goNamed(RouteNames.main);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App logo and name
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 60,
                          color: Colors.white,
                        ).animate()
                          .scale(
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Create Account',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate()
                          .fadeIn(duration: 500.ms, delay: 300.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 500.ms,
                            delay: 300.ms,
                            curve: Curves.easeOutQuad,
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Signup form
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name field
                            AnimatedTextField(
                              controller: _nameController,
                              hintText: 'Full Name',
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              animationDelay: 500,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Email field
                            AnimatedTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              animationDelay: 600,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Password field
                            AnimatedTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              animationDelay: 700,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Confirm password field
                            AnimatedTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              animationDelay: 800,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Terms and conditions checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: theme.colorScheme.primary,
                                ),
                                Expanded(
                                  child: Text(
                                    'I agree to the Terms and Conditions and Privacy Policy',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(duration: 500.ms, delay: 900.ms),
                            
                            const SizedBox(height: 24),
                            
                            // Signup button
                            SizedBox(
                              width: double.infinity,
                              child: AnimatedGradientButton(
                                text: 'Sign Up',
                                onPressed: _signup,
                                gradient: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primaryContainer,
                                ],
                                isLoading: _isLoading,
                              ),
                            ).animate()
                              .fadeIn(duration: 500.ms, delay: 1000.ms)
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 1000.ms,
                                curve: Curves.easeOutQuad,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 700.ms, delay: 400.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 700.ms,
                      delay: 400.ms,
                      curve: Curves.easeOutQuad,
                    ),
                  
                  const Spacer(),
                  
                  // Login link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.goNamed(RouteNames.login);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms, delay: 1100.ms),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}