import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'ref.dart';

class Debounce {
  final bool loading;
  final void Function() bounce;

  call() {
    bounce();
  }

  const Debounce({
    @required this.loading,
    @required this.bounce,
  });
}

/// When loading is [.start()]ed, it goes into a pending state
/// and loading is triggered after [delayDuration].
/// Everything can be reset with [.cancel()]
Debounce useDebounce(
  Future<Null> Function() onDebounce, [
  Duration delayDuration = const Duration(milliseconds: 500),
]) {
  final loading = useState(false);
  final timerHandle = useRef<Timer>(null);

  cancel() {
    timerHandle.current?.cancel();
    loading.value = false;
  }

  start() {
    timerHandle.current = Timer(delayDuration, () async {
      loading.value = true;
      await onDebounce();
      cancel();
    });
  }

  return Debounce(
      loading: loading.value,
      bounce: () {
        cancel();
        start();
      });
}