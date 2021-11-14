import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';

import '../../util/async_store.dart';

part 'community_store.g.dart';

class CommunityStore = _CommunityStore with _$CommunityStore;

abstract class _CommunityStore with Store {
  final String instanceHost;
  final String? communityName;
  final int? id;

  _CommunityStore(this.instanceHost, this.communityName, this.id);
  // ignore: unused_element
  _CommunityStore.fromCommunityView(CommunityView this.communityView)
      : instanceHost = communityView.instanceHost,
        communityName = communityView.community.name,
        id = communityView.community.id;

  // ignore: unused_element
  _CommunityStore.fromName({
    required String this.communityName,
    required this.instanceHost,
  }) : id = null;
  // ignore: unused_element
  _CommunityStore.fromId({required this.id, required this.instanceHost})
      : communityName = null;

  @observable
  CommunityView? communityView;

  @observable
  FullCommunityView? fullCommunityView;

  final communityState = AsyncStore<FullCommunityView>();
  final subscribingState = AsyncStore<CommunityView>();

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
      communityView = val.communityView;
    }
  }

  @action
  Future<void> subscribe(Jwt token) async {
    if (communityView == null) throw UnimplementedError('Unreachable');
    final val = await subscribingState.runLemmy(
      instanceHost,
      FollowCommunity(
        communityId: communityView!.community.id,
        follow: !communityView!.subscribed,
        auth: token.raw,
      ),
    );

    if (val != null) {
      communityView = val;
    }
  }
}
