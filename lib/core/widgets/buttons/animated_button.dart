import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> gradient;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool isLoading;

  const AnimatedGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.gradient,
    this.width = double.infinity,
    this.height = 56.0,
    this.borderRadius,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.gradient.last.withAlpha(102), // 0.4 * 255
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            splashColor: Colors.white.withAlpha(26), // 0.1 * 255
            highlightColor: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? _buildLoader()
                  : _buildButtonContent(),
            ),
          ),
        ),
      )
          .animate(controller: _controller)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(0.95, 0.95),
            duration: 100.ms,
          ),
    );
  }

  Widget _buildButtonContent() {
    // Fix: Use Flexible to prevent overflow
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white,
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? splashColor;
  final double size;
  final EdgeInsets padding;
  final bool isCircular;

  const AnimatedIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.splashColor,
    this.size = 56,
    this.padding = const EdgeInsets.all(8),
    this.isCircular = true,
  }) : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: widget.backgroundColor ?? Colors.transparent,
      shape: widget.isCircular 
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _controller.forward().then((_) => _controller.reverse());
          widget.onPressed();
        },
        customBorder: widget.isCircular 
            ? const CircleBorder() 
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        splashColor: widget.splashColor ?? theme.colorScheme.primary.withAlpha(77), // 0.3 * 255
        highlightColor: theme.colorScheme.primary.withAlpha(26), // 0.1 * 255
        child: Ink(
          width: widget.size,
          height: widget.size,
          child: Padding(
            padding: widget.padding,
            child: Center(
              child: widget.icon
                .animate(controller: _controller)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 100.ms,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1, 1),
                  duration: 100.ms,
                ),
            ),
          ),
        ),
      ),
    );
  }
}