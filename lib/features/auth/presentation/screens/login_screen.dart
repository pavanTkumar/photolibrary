import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../widgets/animated_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login API call
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
                  const Spacer(flex: 1),
                  
                  // App logo and name
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 80,
                          color: Colors.white,
                        ).animate()
                          .scale(
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Community Photos',
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
                        const SizedBox(height: 8),
                        Text(
                          'Share moments, connect community',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ).animate()
                          .fadeIn(duration: 500.ms, delay: 500.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 500.ms,
                            delay: 500.ms,
                            curve: Curves.easeOutQuad,
                          ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Login form
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
                            Text(
                              'Login',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate()
                              .fadeIn(duration: 500.ms, delay: 700.ms)
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 700.ms,
                                curve: Curves.easeOutQuad,
                              ),
                            
                            const SizedBox(height: 24),
                            
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
                              animationDelay: 800,
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
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              animationDelay: 900,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Navigate to forgot password
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ).animate()
                              .fadeIn(duration: 500.ms, delay: 1000.ms),
                            
                            const SizedBox(height: 24),
                            
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: AnimatedGradientButton(
                                text: 'Login',
                                onPressed: _login,
                                gradient: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primaryContainer,
                                ],
                                isLoading: _isLoading,
                              ),
                            ).animate()
                              .fadeIn(duration: 500.ms, delay: 1100.ms)
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 1100.ms,
                                curve: Curves.easeOutQuad,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 700.ms, delay: 600.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 700.ms,
                      delay: 600.ms,
                      curve: Curves.easeOutQuad,
                    )
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      delay: 600.ms,
                      curve: Curves.easeOutQuad,
                    ),
                  
                  const Spacer(flex: 1),
                  
                  // Sign up link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.goNamed(RouteNames.signup);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          children: [
                            TextSpan(
                              text: "Sign Up",
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
                    .fadeIn(duration: 500.ms, delay: 1200.ms),
                  
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