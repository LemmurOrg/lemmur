import 'dart:math' show max, min;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TitleAfterScroll extends HookWidget {
  final Widget child;
  final int after;
  final int transition;
  final ScrollController scrollController;
  final bool fade;

  const TitleAfterScroll({
    @required this.scrollController,
    @required this.child,
    this.transition = 15,
    this.after = 50,
    this.fade = false,
  });

  @override
  Widget build(BuildContext context) {
    useListenable(scrollController);

    final scroll = scrollController.position.pixels;

    return Opacity(
      opacity: fade
          ? max(0, min(transition, (scroll ?? 0) - after + 20)) / transition
          : 1,
      child: Transform.translate(
        offset: Offset(0, max(0, -scroll + after)),
        child: child,
      ),
    );
  }
}
