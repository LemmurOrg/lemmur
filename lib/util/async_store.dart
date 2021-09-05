import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';

part 'async_store.freezed.dart';
part 'async_store.g.dart';

class AsyncStore<T> = _AsyncStore<T> with _$AsyncStore<T>;

abstract class _AsyncStore<T> with Store {
  @observable
  AsyncState<T> asyncState = const AsyncState.initial();

  @computed
  bool get isLoading => asyncState is AsyncStateLoading;

  @computed
  String? get errorTerm => asyncState.maybeWhen(
        error: (errorTerm) => errorTerm,
        orElse: () => null,
      );

  @action
  Future<T?> run(AsyncValueGetter<T> callback) async {
    asyncState = const AsyncState.loading();

    try {
      final res = await callback();

      asyncState = AsyncState.data(res);

      return res;
    } on SocketException {
      asyncState = const AsyncState.error('no internet');
    } catch (err) {
      asyncState = AsyncState.error(err.toString());
      rethrow;
    }
  }

  @action
  Future<T?> runLemmy(String instanceHost, LemmyApiQuery<T> query) async {
    try {
      return await run(() => LemmyApiV3(instanceHost).run(query));
    } on LemmyApiException catch (err) {
      asyncState = AsyncState.error(err.message);
    }
  }
}

@freezed
class AsyncState<T> with _$AsyncState {
  const factory AsyncState.initial() = AsyncStateInitial;
  const factory AsyncState.data(T data) = AsyncStateData;
  const factory AsyncState.loading() = AsyncStateLoading;
  const factory AsyncState.error(String errorTerm) = AsyncStateError;
}
