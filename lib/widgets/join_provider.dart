import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v2.dart';
import 'package:provider/provider.dart';

import '../hooks/ref.dart';

/// Provides to context a consumable stream with Lemmy events
class JoinProvider extends HookWidget {
  final Create<StreamController<WsEvent>> create;
  final Widget child;

  const JoinProvider({
    @required this.create,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final streamController = useMemoized(() => create(context));

    useEffect(() => streamController.close, []);

    return InheritedProvider<Stream<WsEvent>>(
      create: (context) => streamController.stream.asBroadcastStream(),
      child: child,
    );
  }
}

/// Consumes events emitted by a [JoinProvider] available higher in the widget tree
class JoinConsumer extends HookWidget {
  /// Builds the child based on the [WsEvent].
  /// First time it is called WsEvent will be null
  final Widget Function(BuildContext, WsEvent) builder;

  /// `builder` will be called if this predicate returns true
  /// If null it defaults to always returning true
  final bool Function(WsEvent) where;

  /// Listens to events. Called before `builder`
  final ValueChanged<WsEvent> listen;

  const JoinConsumer({
    @required this.builder,
    this.where,
    this.listen,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    final stream = context.watch<Stream<WsEvent>>();

    final child = useRef<Widget>(null);

    return StreamBuilder<WsEvent>(
      stream: stream,
      builder: (context, wsEventSnap) {
        if (wsEventSnap.hasData) listen?.call(wsEventSnap.data);

        final shouldRebuild = where?.call(wsEventSnap.data) ?? true;

        if (shouldRebuild || child.current == null) {
          child.current = builder(context, wsEventSnap.data);
        }

        return child.current;
      },
    );
  }
}
