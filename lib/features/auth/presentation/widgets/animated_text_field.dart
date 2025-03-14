import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int animationDelay;

  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.animationDelay = 0,
  }) : super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isFocused 
              ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
              : theme.colorScheme.surfaceVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused 
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(
              widget.prefixIcon,
              color: _isFocused 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          style: theme.textTheme.bodyLarge,
          cursorColor: theme.colorScheme.primary,
        ),
      )
          .animate()
          .fadeIn(duration: 500.ms, delay: widget.animationDelay.ms)
          .slideY(
            begin: 0.3,
            end: 0,
            duration: 500.ms,
            delay: widget.animationDelay.ms,
            curve: Curves.easeOutQuad,
          ),
    );
  }
}