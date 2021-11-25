import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';

part 'async_store.freezed.dart';
part 'async_store.g.dart';

/// [AsyncState] but observable with helper methods/getters
class AsyncStore<T> = _AsyncStore<T> with _$AsyncStore<T>;

abstract class _AsyncStore<T> with Store {
  @observable
  AsyncState<T> asyncState = const AsyncState.initial();

  @computed
  bool get isLoading => asyncState is AsyncStateLoading<T>;

  @computed
  String? get errorTerm => asyncState.whenOrNull<String?>(
        error: (errorTerm) => errorTerm,
        data: (data, errorTerm) => errorTerm,
      );

  /// sets data in asyncState
  /// only to be used when asyncState is AsyncStateData
  @action
  void setData(T data) {
    final state = asyncState;
    if (state is! AsyncStateData<T>) {
      throw StateError("this can only be used when there's some data already");
    }
    asyncState = state.copyWith(data: data);
  }

  /// runs some async action and reflects the progress in [asyncState].
  /// If successful, the result is returned, otherwise null is returned.
  /// If this [AsyncStore] is already running some action, it will exit immediately and do nothing
  ///
  /// When [refresh] is true and [asyncState] is [AsyncStateData], then the data state is persisted and
  ///  errors are not fatal but stored in [AsyncStateData]
  @action
  Future<T?> run(AsyncValueGetter<T> callback, {bool refresh = false}) async {
    if (isLoading) return null;

    final data = refresh ? asyncState.mapOrNull(data: (data) => data) : null;

    if (data == null) {
      asyncState = const AsyncState.loading();
    }

    try {
      final result = await callback();

      asyncState = AsyncState.data(result);

      return result;
    } on SocketException {
      // TODO: use an existing l10n key
      if (data != null) {
        asyncState = data.copyWith(errorTerm: 'network_error');
      } else {
        asyncState = const AsyncState.error('network_error');
      }
    } catch (err) {
      if (data != null) {
        asyncState = data.copyWith(errorTerm: err.toString());
      } else {
        asyncState = AsyncState.error(err.toString());
      }
      rethrow;
    }
  }

  /// [run] but specialized for a [LemmyApiQuery].
  /// Will catch [LemmyApiException] and map to its error term.
  @action
  Future<T?> runLemmy(
    String instanceHost,
    LemmyApiQuery<T> query, {
    bool refresh = false,
  }) async {
    try {
      return await run(() => LemmyApiV3(instanceHost).run(query));
    } on LemmyApiException catch (err) {
      final data = refresh ? asyncState.mapOrNull(data: (data) => data) : null;
      if (data != null) {
        asyncState = data.copyWith(errorTerm: err.message);
      } else {
        asyncState = AsyncState.error(err.message);
      }
    }
  }
}

/// State in which an async action can be
@freezed
class AsyncState<T> with _$AsyncState<T> {
  /// async action has not yet begun
  const factory AsyncState.initial() = AsyncStateInitial<T>;

  /// async action completed successfully with [T]
  /// and possibly an error term after a refresh
  const factory AsyncState.data(T data, [String? errorTerm]) =
      AsyncStateData<T>;

  /// async action is running at the moment
  const factory AsyncState.loading() = AsyncStateLoading<T>;

  /// async action failed with a translatable error term
  const factory AsyncState.error(String errorTerm) = AsyncStateError<T>;
}
