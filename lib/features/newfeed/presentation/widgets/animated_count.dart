import 'package:flutter/material.dart';

class AnimatedCount extends StatelessWidget {
  final int count;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCount({
    super.key,
    required this.count,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: count - 1, end: count),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Text(
          '$value',
          style: style,
        );
      },
    );
  }
}
