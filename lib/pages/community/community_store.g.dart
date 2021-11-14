// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CommunityStore on _CommunityStore, Store {
  final _$communityViewAtom = Atom(name: '_CommunityStore.communityView');

  @override
  CommunityView? get communityView {
    _$communityViewAtom.reportRead();
    return super.communityView;
  }

  @override
  set communityView(CommunityView? value) {
    _$communityViewAtom.reportWrite(value, super.communityView, () {
      super.communityView = value;
    });
  }

  final _$fullCommunityViewAtom =
      Atom(name: '_CommunityStore.fullCommunityView');

  @override
  FullCommunityView? get fullCommunityView {
    _$fullCommunityViewAtom.reportRead();
    return super.fullCommunityView;
  }

  @override
  set fullCommunityView(FullCommunityView? value) {
    _$fullCommunityViewAtom.reportWrite(value, super.fullCommunityView, () {
      super.fullCommunityView = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_CommunityStore.refresh');

  @override
  Future<void> refresh(Jwt? token) {
    return _$refreshAsyncAction.run(() => super.refresh(token));
  }

  final _$subscribeAsyncAction = AsyncAction('_CommunityStore.subscribe');

  @override
  Future<void> subscribe(Jwt token) {
    return _$subscribeAsyncAction.run(() => super.subscribe(token));
  }

  @override
  String toString() {
    return '''
communityView: ${communityView},
fullCommunityView: ${fullCommunityView}
    ''';
  }
}
