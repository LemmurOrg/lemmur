import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';

import '../../util/async_store.dart';

part 'modlog_page_store.g.dart';

class ModlogPageStore = _ModlogPageStore with _$ModlogPageStore;

abstract class _ModlogPageStore with Store {
  final String instanceHost;
  final int? communityId;

  _ModlogPageStore(this.instanceHost, [this.communityId]);

  @observable
  int page = 1;

  final modlogState = AsyncStore<Modlog>();

  @computed
  bool get hasPreviousPage => page != 1;

  @computed
  bool get hasNextPage =>
      modlogState.asyncState.whenOrNull(
        data: (data, error) =>
            data.removedPosts.length +
                data.lockedPosts.length +
                data.stickiedPosts.length +
                data.removedComments.length +
                data.removedCommunities.length +
                data.bannedFromCommunity.length +
                data.banned.length +
                data.addedToCommunity.length +
                data.transferredToCommunity.length +
                data.added.length !=
            0,
      ) ??
      true;

  @action
  Future<void> fetchPage() async {
    await modlogState.runLemmy(
      instanceHost,
      GetModlog(page: page, communityId: communityId),
    );
  }

  @action
  void previousPage() {
    page--;
    fetchPage();
  }

  @action
  void nextPage() {
    page++;
    fetchPage();
  }
}
