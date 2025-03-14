import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool automaticallyImplyLeading;
  
  const AnimatedAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.bottom,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);
  
  @override
  State<AnimatedAppBar> createState() => _AnimatedAppBarState();
  
  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

class _AnimatedAppBarState extends State<AnimatedAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title)
        .animate(controller: _controller)
        .fade(duration: 300.ms)
        .slideY(begin: -0.2, end: 0, duration: 300.ms, curve: Curves.easeOut),
      centerTitle: widget.centerTitle,
      actions: widget.actions != null
        ? widget.actions!.mapIndexed((index, action) {
            return action
              .animate(controller: _controller)
              .fade(duration: 300.ms, delay: (50 * index).ms)
              .slideY(
                begin: -0.2,
                end: 0,
                duration: 300.ms,
                delay: (50 * index).ms,
                curve: Curves.easeOut,
              );
          }).toList()
        : null,
      leading: widget.leading != null
        ? widget.leading!
            .animate(controller: _controller)
            .fade(duration: 300.ms)
            .slideY(begin: -0.2, end: 0, duration: 300.ms, curve: Curves.easeOut)
        : null,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      elevation: widget.elevation,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      bottom: widget.bottom,
    );
  }
}

// Extension to help with animations on lists of widgets
extension ListAnimateExtension<T> on List<T> {
  List<R> mapIndexed<R>(R Function(int index, T item) convert) {
    List<R> result = [];
    for (int i = 0; i < length; i++) {
      result.add(convert(i, this[i]));
    }
    return result;
  }
}