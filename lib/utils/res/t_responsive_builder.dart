import 'package:eazotel/utils/res/t_breakpoints.dart';
import 'package:eazotel/utils/res/t_responsive.dart';
 import 'package:flutter/material.dart';

/// Decides the layout from the real width the parent gives.
/// Works correctly with side navigation / split view / window resize too.
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

/// Centers the content and limits it to a max width (for desktop)
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