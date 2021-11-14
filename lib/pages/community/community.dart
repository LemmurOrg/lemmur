import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:nested/nested.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import '../../hooks/stores.dart';
import '../../l10n/l10n.dart';
import '../../stores/accounts_store.dart';
import '../../util/async_store_listener.dart';
import '../../util/extensions/api.dart';
import '../../util/icons.dart';
import '../../util/observer_consumers.dart';
import '../../util/share.dart';
import '../../widgets/bottom_modal.dart';
import '../../widgets/failed_to_load.dart';
import '../../widgets/info_table_popup.dart';
import '../../widgets/reveal_after_scroll.dart';
import '../../widgets/sortable_infinite_list.dart';
import '../create_post.dart';
import 'community_about_tab.dart';
import 'community_overview.dart';
import 'community_store.dart';

/// Displays posts, comments, and general info about the given community
class CommunityPage extends HookWidget {
  const CommunityPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsStore = useAccountsStore();
    final scrollController = useScrollController();

    return Nested(
      children: [
        AsyncStoreListener(
            asyncStore: context.read<CommunityStore>().communityState),
        AsyncStoreListener(
            asyncStore: context.read<CommunityStore>().subscribingState),
      ],
      child: ObserverBuilder<CommunityStore>(builder: (context, store) {
        final community = store.communityView;

        // FALLBACK
        if (community == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (store.communityState.errorTerm != null) ...[
                    FailedToLoad(
                      refresh: () => store.refresh(context
                          .read<AccountsStore>()
                          .defaultUserDataFor(store.instanceHost)
                          ?.jwt),
                      message: store.communityState.errorTerm!.tr(context),
                    ),
                  ] else
                    const CircularProgressIndicator.adaptive()
                ],
              ),
            ),
          );
        }

        void _share() => share(community.community.actorId, context: context);

        void _openMoreMenu() {
          showBottomModal(
            context: context,
            builder: (context) => Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.open_in_browser),
                  title: const Text('Open in browser'),
                  onTap: () async =>
                      await ul.canLaunch(community.community.actorId)
                          ? ul.launch(community.community.actorId)
                          : ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("can't open in browser"))),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Nerd stuff'),
                  onTap: () {
                    showInfoTablePopup(
                        context: context, table: community.toJson());
                  },
                ),
              ],
            ),
          );
        }

        return Scaffold(
          floatingActionButton: CreatePostFab(community: community),
          body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              controller: scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
                SliverAppBar(
                  expandedHeight: community.community.icon == null ? 220 : 300,
                  pinned: true,
                  backgroundColor: theme.cardColor,
                  title: RevealAfterScroll(
                    scrollController: scrollController,
                    after: community.community.icon == null ? 110 : 190,
                    fade: true,
                    child: Text(
                      community.community.preferredName,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  actions: [
                    IconButton(icon: Icon(shareIcon), onPressed: _share),
                    IconButton(icon: Icon(moreIcon), onPressed: _openMoreMenu),
                  ],
                  flexibleSpace: const FlexibleSpaceBar(
                    background: CommunityOverview(),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const TabBar(tabs: []).preferredSize,
                    child: Material(
                      color: theme.cardColor,
                      child: TabBar(
                        tabs: [
                          Tab(text: L10n.of(context).posts),
                          Tab(text: L10n.of(context).comments),
                          const Tab(text: 'About'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  InfinitePostList(
                    fetcher: (page, batchSize, sort) =>
                        LemmyApiV3(community.instanceHost).run(GetPosts(
                      type: PostListingType.community,
                      sort: sort,
                      communityId: community.community.id,
                      page: page,
                      limit: batchSize,
                      savedOnly: false,
                    )),
                  ),
                  InfiniteCommentList(
                      fetcher: (page, batchSize, sortType) =>
                          LemmyApiV3(community.instanceHost).run(GetComments(
                            communityId: community.community.id,
                            auth: accountsStore
                                .defaultUserDataFor(community.instanceHost)
                                ?.jwt
                                .raw,
                            type: CommentListingType.community,
                            sort: sortType,
                            limit: batchSize,
                            page: page,
                            savedOnly: false,
                          ))),
                  const CommmunityAboutTab(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  static Jwt? _tryGetJwt(BuildContext context, String instanceHost) {
    return context.read<AccountsStore>().defaultUserDataFor(instanceHost)?.jwt;
  }

  static Route fromNameRoute(String instanceHost, String name) {
    return MaterialPageRoute(
      builder: (context) {
        return Provider(
          create: (context) => CommunityStore.fromName(
              communityName: name, instanceHost: instanceHost)
            ..refresh(_tryGetJwt(context, instanceHost)),
          child: const CommunityPage(),
        );
      },
    );
  }

  static Route fromIdRoute(String instanceHost, int id) {
    return MaterialPageRoute(
      builder: (context) => Provider(
        create: (context) =>
            CommunityStore.fromId(id: id, instanceHost: instanceHost)
              ..refresh(_tryGetJwt(context, instanceHost)),
        child: const CommunityPage(),
      ),
    );
  }

  static Route fromCommunityViewRoute(CommunityView communityView) {
    return MaterialPageRoute(
      builder: (context) => Provider(
        create: (context) => CommunityStore.fromCommunityView(communityView)
          ..refresh(_tryGetJwt(context, communityView.instanceHost)),
        child: const CommunityPage(),
      ),
    );
  }
}
