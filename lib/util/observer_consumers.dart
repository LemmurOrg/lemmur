import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

typedef MobxBuilder<T extends Store> = Widget Function(BuildContext, T);

class ObserverBuilder<T extends Store> extends StatelessWidget {
  const ObserverBuilder({
    Key? key,
    this.store,
    required this.builder,
  }) : super(key: key);

  final T? store;
  final MobxBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return builder(
          context,
          store ?? context.read<T>(),
        );
      },
    );
  }
}

class ObserverListener<T extends Store> extends HookWidget {
  const ObserverListener({
    Key? key,
    this.store,
    required this.listener,
    required this.child,
  }) : super(key: key);

  final T? store;
  final MobxBuilder<T> listener;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final disposer = autorun(
        (_) => listener(context, store ?? context.read<T>()),
      );

      return disposer;
    }, []);

    return child;
  }
}

class ObserverConsumer<T extends Store> extends HookWidget {
  const ObserverConsumer({
    Key? key,
    this.store,
    required this.listener,
    required this.builder,
  }) : super(key: key);

  final T? store;
  final MobxBuilder<T> listener;
  final MobxBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final disposer = autorun(
        (_) => listener(context, store ?? context.read<T>()),
      );

      return disposer;
    }, []);

    return ObserverBuilder(store: store, builder: builder);
  }
}
