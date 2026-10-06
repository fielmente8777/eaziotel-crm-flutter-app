import 'package:eazotel/utils/res/t_breakpoints.dart';
import 'package:eazotel/utils/res/t_responsive.dart';
 import 'package:flutter/material.dart';

/// Parent se milne wali asli width par layout decide karta hai.
/// Side navigation / split view / window resize mein bhi sahi chalta hai.
class TResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, TResponsive r) builder;
  const TResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => builder(context, TResponsive(box.maxWidth)),
    );
  }
}

/// Content ko center karke max width par rokta hai (desktop ke liye)
class TCenteredContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const TCenteredContent({
    super.key,
    required this.child,
    this.maxWidth = TBreakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}