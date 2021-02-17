import 'package:flutter/material.dart';

import '../hooks/delayed_loading.dart';

class TileAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final DelayedLoading delayedLoading;
  final Color iconColor;

  const TileAction({
    Key key,
    this.delayedLoading,
    this.iconColor,
    @required this.icon,
    @required this.onPressed,
    @required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
        constraints: BoxConstraints.tight(const Size(36, 30)),
        icon: delayedLoading?.loading ?? false
            ? SizedBox.fromSize(
                size: const Size.square(22),
                child: const CircularProgressIndicator())
            : Icon(
                icon,
                color: iconColor ??
                    Theme.of(context).iconTheme.color.withAlpha(190),
              ),
        splashRadius: 25,
        onPressed: delayedLoading?.pending ?? false ? () {} : onPressed,
        iconSize: 25,
        tooltip: tooltip,
        padding: const EdgeInsets.all(0),
      );
}
