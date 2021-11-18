import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';

import '../../util/async_store.dart';

part 'community_store.g.dart';

class CommunityStore = _CommunityStore with _$CommunityStore;

abstract class _CommunityStore with Store {
  final String instanceHost;
  final String? communityName;
  final int? id;

  // ignore: unused_element
  _CommunityStore.fromName({
    required String this.communityName,
    required this.instanceHost,
  }) : id = null;
  // ignore: unused_element
  _CommunityStore.fromId({required this.id, required this.instanceHost})
      : communityName = null;

  @observable
  FullCommunityView? fullCommunityView;

  final communityState = AsyncStore<FullCommunityView>();
  final subscribingState = AsyncStore<CommunityView>();
  final blockingState = AsyncStore<BlockedCommunity>();

  @action
  Future<void> refresh(Jwt? token) async {
    final val = await communityState.runLemmy(
      instanceHost,
      GetCommunity(
        auth: token?.raw,
        id: id,
        name: communityName,
      ),
    );

    if (val != null) {
      fullCommunityView = val;
    }
  }

  Future<void> block(Jwt token) async {
    final communityView = fullCommunityView?.communityView;

    if (communityView == null) {
      throw StateError('FullCommunityView should be not null at this point');
    }

    final val = await blockingState.runLemmy(
      instanceHost,
      BlockCommunity(
        communityId: communityView.community.id,
        block: !communityView.blocked,
        auth: token.raw,
      ),
    );

    if (val != null) {
      fullCommunityView =
          fullCommunityView!.copyWith(communityView: val.communityView);
    }
  }

  @action
  Future<void> subscribe(Jwt token) async {
    final communityView = fullCommunityView?.communityView;

    if (communityView == null) {
      throw StateError('FullCommunityView should be not null at this point');
    }
    final val = await subscribingState.runLemmy(
      instanceHost,
      FollowCommunity(
        communityId: communityView.community.id,
        follow: !communityView.subscribed,
        auth: token.raw,
      ),
    );

    if (val != null) {
      fullCommunityView = fullCommunityView!.copyWith(communityView: val);
    }
  }
}
