// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'async_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AsyncState<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T data, String? errorTerm) data,
    required TResult Function() loading,
    required TResult Function(String errorTerm) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncStateInitial<T> value) initial,
    required TResult Function(AsyncStateData<T> value) data,
    required TResult Function(AsyncStateLoading<T> value) loading,
    required TResult Function(AsyncStateError<T> value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AsyncStateCopyWith<T, $Res> {
  factory $AsyncStateCopyWith(
          AsyncState<T> value, $Res Function(AsyncState<T>) then) =
      _$AsyncStateCopyWithImpl<T, $Res>;
}

/// @nodoc
class _$AsyncStateCopyWithImpl<T, $Res>
    implements $AsyncStateCopyWith<T, $Res> {
  _$AsyncStateCopyWithImpl(this._value, this._then);

  final AsyncState<T> _value;
  // ignore: unused_field
  final $Res Function(AsyncState<T>) _then;
}

/// @nodoc
abstract class _$$AsyncStateInitialCopyWith<T, $Res> {
  factory _$$AsyncStateInitialCopyWith(_$AsyncStateInitial<T> value,
          $Res Function(_$AsyncStateInitial<T>) then) =
      __$$AsyncStateInitialCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$AsyncStateInitialCopyWithImpl<T, $Res>
    extends _$AsyncStateCopyWithImpl<T, $Res>
    implements _$$AsyncStateInitialCopyWith<T, $Res> {
  __$$AsyncStateInitialCopyWithImpl(_$AsyncStateInitial<T> _value,
      $Res Function(_$AsyncStateInitial<T>) _then)
      : super(_value, (v) => _then(v as _$AsyncStateInitial<T>));

  @override
  _$AsyncStateInitial<T> get _value => super._value as _$AsyncStateInitial<T>;
}

/// @nodoc

class _$AsyncStateInitial<T> implements AsyncStateInitial<T> {
  const _$AsyncStateInitial();

  @override
  String toString() {
    return 'AsyncState<$T>.initial()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AsyncStateInitial<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T data, String? errorTerm) data,
    required TResult Function() loading,
    required TResult Function(String errorTerm) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncStateInitial<T> value) initial,
    required TResult Function(AsyncStateData<T> value) data,
    required TResult Function(AsyncStateLoading<T> value) loading,
    required TResult Function(AsyncStateError<T> value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class AsyncStateInitial<T> implements AsyncState<T> {
  const factory AsyncStateInitial() = _$AsyncStateInitial<T>;
}

/// @nodoc
abstract class _$$AsyncStateDataCopyWith<T, $Res> {
  factory _$$AsyncStateDataCopyWith(
          _$AsyncStateData<T> value, $Res Function(_$AsyncStateData<T>) then) =
      __$$AsyncStateDataCopyWithImpl<T, $Res>;
  $Res call({T data, String? errorTerm});
}

/// @nodoc
class __$$AsyncStateDataCopyWithImpl<T, $Res>
    extends _$AsyncStateCopyWithImpl<T, $Res>
    implements _$$AsyncStateDataCopyWith<T, $Res> {
  __$$AsyncStateDataCopyWithImpl(
      _$AsyncStateData<T> _value, $Res Function(_$AsyncStateData<T>) _then)
      : super(_value, (v) => _then(v as _$AsyncStateData<T>));

  @override
  _$AsyncStateData<T> get _value => super._value as _$AsyncStateData<T>;

  @override
  $Res call({
    Object? data = freezed,
    Object? errorTerm = freezed,
  }) {
    return _then(_$AsyncStateData<T>(
      data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
      errorTerm == freezed
          ? _value.errorTerm
          : errorTerm // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AsyncStateData<T> implements AsyncStateData<T> {
  const _$AsyncStateData(this.data, [this.errorTerm]);

  @override
  final T data;
  @override
  final String? errorTerm;

  @override
  String toString() {
    return 'AsyncState<$T>.data(data: $data, errorTerm: $errorTerm)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncStateData<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            const DeepCollectionEquality().equals(other.errorTerm, errorTerm));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(data),
      const DeepCollectionEquality().hash(errorTerm));

  @JsonKey(ignore: true)
  @override
  _$$AsyncStateDataCopyWith<T, _$AsyncStateData<T>> get copyWith =>
      __$$AsyncStateDataCopyWithImpl<T, _$AsyncStateData<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T data, String? errorTerm) data,
    required TResult Function() loading,
    required TResult Function(String errorTerm) error,
  }) {
    return data(this.data, errorTerm);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
  }) {
    return data?.call(this.data, errorTerm);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this.data, errorTerm);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncStateInitial<T> value) initial,
    required TResult Function(AsyncStateData<T> value) data,
    required TResult Function(AsyncStateLoading<T> value) loading,
    required TResult Function(AsyncStateError<T> value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class AsyncStateData<T> implements AsyncState<T> {
  const factory AsyncStateData(final T data, [final String? errorTerm]) =
      _$AsyncStateData<T>;

  T get data;
  String? get errorTerm;
  @JsonKey(ignore: true)
  _$$AsyncStateDataCopyWith<T, _$AsyncStateData<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AsyncStateLoadingCopyWith<T, $Res> {
  factory _$$AsyncStateLoadingCopyWith(_$AsyncStateLoading<T> value,
          $Res Function(_$AsyncStateLoading<T>) then) =
      __$$AsyncStateLoadingCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$AsyncStateLoadingCopyWithImpl<T, $Res>
    extends _$AsyncStateCopyWithImpl<T, $Res>
    implements _$$AsyncStateLoadingCopyWith<T, $Res> {
  __$$AsyncStateLoadingCopyWithImpl(_$AsyncStateLoading<T> _value,
      $Res Function(_$AsyncStateLoading<T>) _then)
      : super(_value, (v) => _then(v as _$AsyncStateLoading<T>));

  @override
  _$AsyncStateLoading<T> get _value => super._value as _$AsyncStateLoading<T>;
}

/// @nodoc

class _$AsyncStateLoading<T> implements AsyncStateLoading<T> {
  const _$AsyncStateLoading();

  @override
  String toString() {
    return 'AsyncState<$T>.loading()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AsyncStateLoading<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T data, String? errorTerm) data,
    required TResult Function() loading,
    required TResult Function(String errorTerm) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncStateInitial<T> value) initial,
    required TResult Function(AsyncStateData<T> value) data,
    required TResult Function(AsyncStateLoading<T> value) loading,
    required TResult Function(AsyncStateError<T> value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AsyncStateLoading<T> implements AsyncState<T> {
  const factory AsyncStateLoading() = _$AsyncStateLoading<T>;
}

/// @nodoc
abstract class _$$AsyncStateErrorCopyWith<T, $Res> {
  factory _$$AsyncStateErrorCopyWith(_$AsyncStateError<T> value,
          $Res Function(_$AsyncStateError<T>) then) =
      __$$AsyncStateErrorCopyWithImpl<T, $Res>;
  $Res call({String errorTerm});
}

/// @nodoc
class __$$AsyncStateErrorCopyWithImpl<T, $Res>
    extends _$AsyncStateCopyWithImpl<T, $Res>
    implements _$$AsyncStateErrorCopyWith<T, $Res> {
  __$$AsyncStateErrorCopyWithImpl(
      _$AsyncStateError<T> _value, $Res Function(_$AsyncStateError<T>) _then)
      : super(_value, (v) => _then(v as _$AsyncStateError<T>));

  @override
  _$AsyncStateError<T> get _value => super._value as _$AsyncStateError<T>;

  @override
  $Res call({
    Object? errorTerm = freezed,
  }) {
    return _then(_$AsyncStateError<T>(
      errorTerm == freezed
          ? _value.errorTerm
          : errorTerm // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AsyncStateError<T> implements AsyncStateError<T> {
  const _$AsyncStateError(this.errorTerm);

  @override
  final String errorTerm;

  @override
  String toString() {
    return 'AsyncState<$T>.error(errorTerm: $errorTerm)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncStateError<T> &&
            const DeepCollectionEquality().equals(other.errorTerm, errorTerm));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(errorTerm));

  @JsonKey(ignore: true)
  @override
  _$$AsyncStateErrorCopyWith<T, _$AsyncStateError<T>> get copyWith =>
      __$$AsyncStateErrorCopyWithImpl<T, _$AsyncStateError<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T data, String? errorTerm) data,
    required TResult Function() loading,
    required TResult Function(String errorTerm) error,
  }) {
    return error(errorTerm);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
  }) {
    return error?.call(errorTerm);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T data, String? errorTerm)? data,
    TResult Function()? loading,
    TResult Function(String errorTerm)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(errorTerm);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncStateInitial<T> value) initial,
    required TResult Function(AsyncStateData<T> value) data,
    required TResult Function(AsyncStateLoading<T> value) loading,
    required TResult Function(AsyncStateError<T> value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncStateInitial<T> value)? initial,
    TResult Function(AsyncStateData<T> value)? data,
    TResult Function(AsyncStateLoading<T> value)? loading,
    TResult Function(AsyncStateError<T> value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class AsyncStateError<T> implements AsyncState<T> {
  const factory AsyncStateError(final String errorTerm) = _$AsyncStateError<T>;

  String get errorTerm;
  @JsonKey(ignore: true)
  _$$AsyncStateErrorCopyWith<T, _$AsyncStateError<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
