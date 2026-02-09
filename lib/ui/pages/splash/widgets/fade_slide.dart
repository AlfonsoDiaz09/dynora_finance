import 'package:flutter/material.dart';

class FadeSlide extends StatelessWidget {
  final Widget child;
  final int delay;

  const FadeSlide({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 20.0, end: 0.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - (value / 20),
          child: Transform.translate(
            offset: Offset(0, value),
            child: child,
          ),
        );
      },
    );
  }
}
