import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/buttons/animated_button.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 80,
              color: theme.colorScheme.primary,
            )
            .animate()
            .scale(
              duration: 400.ms,
              curve: Curves.easeOutBack,
            )
            .then()
            .shake(hz: 4, rotation: 0.02),
            
            const SizedBox(height: 24),
            
            Text(
              'Community Coming Soon',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms).slideY(
              begin: 0.2,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOutQuad,
            ),
            
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Connect with other community members, join groups, and stay updated with the latest discussions.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(
              begin: 0.2,
              end: 0,
              duration: 600.ms,
              delay: 200.ms,
              curve: Curves.easeOutQuad,
            ),
            
            const SizedBox(height: 40),
            
            AnimatedGradientButton(
              text: 'Join the Community',
              onPressed: () {
                // Navigate to community sign-up
              },
              gradient: [
                theme.colorScheme.primary,
                theme.colorScheme.tertiary,
              ],
              width: 250,
              borderRadius: BorderRadius.circular(30),
              icon: Icon(
                Icons.group_add,
                color: theme.colorScheme.onPrimary,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(
              begin: 0.2,
              end: 0,
              duration: 600.ms,
              delay: 400.ms,
              curve: Curves.easeOutQuad,
            ),
          ],
        ),
      ),
    );
  }
}