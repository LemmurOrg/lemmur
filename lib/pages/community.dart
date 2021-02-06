import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v2.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import '../hooks/delayed_loading.dart';
import '../hooks/logged_in_action.dart';
import '../hooks/memo_future.dart';
import '../hooks/stores.dart';
import '../util/extensions/api.dart';
import '../util/extensions/spaced.dart';
import '../util/goto.dart';
import '../util/intl.dart';
import '../util/more_icon.dart';
import '../util/text_color.dart';
import '../widgets/bottom_modal.dart';
import '../widgets/fullscreenable_image.dart';
import '../widgets/info_table_popup.dart';
import '../widgets/markdown_text.dart';
import '../widgets/sortable_infinite_list.dart';

/// Displays posts, comments, and general info about the given community
class CommunityPage extends HookWidget {
  final CommunityView _community;
  final String instanceHost;
  final String communityName;
  final int communityId;

  const CommunityPage.fromName({
    @required this.communityName,
    @required this.instanceHost,
  })  : assert(communityName != null),
        assert(instanceHost != null),
        communityId = null,
        _community = null;
  const CommunityPage.fromId({
    @required this.communityId,
    @required this.instanceHost,
  })  : assert(communityId != null),
        assert(instanceHost != null),
        communityName = null,
        _community = null;
  CommunityPage.fromCommunityView(this._community)
      : instanceHost = _community.instanceHost,
        communityId = _community.community.id,
        communityName = _community.community.name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsStore = useAccountsStore();

    final fullCommunitySnap = useMemoFuture(() {
      final token = accountsStore.defaultTokenFor(instanceHost);

      if (communityId != null) {
        return LemmyApiV2(instanceHost).run(GetCommunity(
          id: communityId,
          auth: token?.raw,
        ));
      } else {
        return LemmyApiV2(instanceHost).run(GetCommunity(
          name: communityName,
          auth: token?.raw,
        ));
      }
    });

    final colorOnCard = textColorBasedOnBackground(theme.cardColor);

    final community = () {
      if (fullCommunitySnap.hasData) {
        return fullCommunitySnap.data.communityView;
      } else if (_community != null) {
        return _community;
      } else {
        return null;
      }
    }();

    // FALLBACK

    if (community == null) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: theme.iconTheme,
          brightness: theme.brightness,
          backgroundColor: theme.cardColor,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (fullCommunitySnap.hasError) ...[
                const Icon(Icons.error),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('ERROR: ${fullCommunitySnap.error}'),
                )
              ] else
                const CircularProgressIndicator(semanticsLabel: 'loading')
            ],
          ),
        ),
      );
    }

    // FUNCTIONS
    void _share() =>
        Share.text('Share instance', community.community.actorId, 'text/plain');

    void _openMoreMenu() {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => BottomModal(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open in browser'),
                onTap: () async => await ul
                        .canLaunch(community.community.actorId)
                    ? ul.launch(community.community.actorId)
                    : Scaffold.of(context).showSnackBar(
                        const SnackBar(content: Text("can't open in browser"))),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Nerd stuff'),
                onTap: () {
                  showInfoTablePopup(context, {
                    'id': community.community.id,
                    'actorId': community.community.actorId,
                    'created by': '@${community.creator.name}',
                    'published': community.community.published,
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
            // TODO: change top section to be more flexible
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.cardColor,
              brightness: theme.brightness,
              iconTheme: theme.iconTheme,
              title: Text('!${community.community.name}',
                  style: TextStyle(color: colorOnCard)),
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: _share),
                IconButton(icon: Icon(moreIcon), onPressed: _openMoreMenu),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _CommunityOverview(
                  community: community,
                  instanceHost: instanceHost,
                  onlineUsers: fullCommunitySnap.data?.online,
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: theme.textTheme.bodyText1.color,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Comments'),
                    Tab(text: 'About'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ],
          body: TabBarView(
            children: [
              InfinitePostList(
                fetcher: (page, batchSize, sort) =>
                    LemmyApiV2(community.instanceHost).run(GetPosts(
                  type: PostListingType.community,
                  sort: sort,
                  communityId: community.community.id,
                  page: page,
                  limit: batchSize,
                )),
              ),
              InfiniteCommentList(
                  fetcher: (page, batchSize, sortType) =>
                      LemmyApiV2(community.instanceHost).run(GetComments(
                        communityId: community.community.id,
                        auth: accountsStore
                            .defaultTokenFor(community.instanceHost)
                            ?.raw,
                        type: CommentListingType.community,
                        sort: sortType,
                        limit: batchSize,
                        page: page,
                      ))),
              _AboutTab(
                community: community,
                moderators: fullCommunitySnap.data?.moderators,
                onlineUsers: fullCommunitySnap.data?.online,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityOverview extends StatelessWidget {
  final CommunityView community;
  final String instanceHost;
  final int onlineUsers;

  const _CommunityOverview({
    @required this.community,
    @required this.instanceHost,
    @required this.onlineUsers,
  })  : assert(instanceHost != null),
        assert(goToInstance != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadow = BoxShadow(color: theme.canvasColor, blurRadius: 5);

    final icon = community.community.icon != null
        ? Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.7), blurRadius: 3)
                    ]),
              ),
              SizedBox(
                width: 83,
                height: 83,
                child: FullscreenableImage(
                  url: community.community.icon,
                  child: CachedNetworkImage(
                    imageUrl: community.community.icon,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const Icon(Icons.warning),
                  ),
                ),
              ),
            ],
          )
        : null;

    return Stack(children: [
      if (community.community.banner != null)
        FullscreenableImage(
          url: community.community.banner,
          child: CachedNetworkImage(
            imageUrl: community.community.banner,
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 45),
          child: Column(children: [
            if (community.community.icon != null) icon,
            // NAME
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: RichText(
                  overflow: TextOverflow.ellipsis, // TODO: fix overflowing
                  text: TextSpan(
                    style:
                        theme.textTheme.subtitle1.copyWith(shadows: [shadow]),
                    children: [
                      const TextSpan(
                          text: '!',
                          style: TextStyle(fontWeight: FontWeight.w200)),
                      TextSpan(
                          text: community.community.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const TextSpan(
                          text: '@',
                          style: TextStyle(fontWeight: FontWeight.w200)),
                      TextSpan(
                        text: community.community.originInstanceHost,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => goToInstance(
                              context, community.community.originInstanceHost),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // TITLE/MOTTO
            Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
              child: Text(
                community.community.title,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.w300, shadows: [shadow]),
              ),
            )),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Stack(
                children: [
                  // INFO ICONS
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(Icons.people, size: 20),
                        ),
                        Text(compactNumber(community.counts.subscribers)),
                        const Spacer(
                          flex: 4,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(Icons.record_voice_over, size: 20),
                        ),
                        Text(onlineUsers == null
                            ? 'xx'
                            : compactNumber(onlineUsers)),
                        const Spacer(),
                      ],
                    ),
                  ),
                  _FollowButton(community),
                ],
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  const _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(color: theme.cardColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _AboutTab extends StatelessWidget {
  final CommunityView community;
  final List<CommunityModeratorView> moderators;
  final int onlineUsers;

  const _AboutTab({
    Key key,
    @required this.community,
    @required this.moderators,
    @required this.onlineUsers,
  }) : super(key: key);

  void goToModlog() {
    print('GO TO MODLOG');
  }

  void goToCategories() {
    print('GO TO CATEGORIES');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(top: 20),
      children: [
        if (community.community.description != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: MarkdownText(community.community.description,
                instanceHost: community.instanceHost),
          ),
          const _Divider(),
        ],
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              Chip(label: Text('${onlineUsers ?? 'X'} users online')),
              Chip(
                  label: Text(
                      '${community.counts.subscribers} subscriber${pluralS(community.counts.subscribers)}')),
              Chip(
                  label: Text(
                      '${community.counts.posts} post${pluralS(community.counts.posts)}')),
              Chip(
                  label: Text(
                      '${community.counts.comments} comment${pluralS(community.counts.comments)}')),
            ].spaced(8),
          ),
        ),
        const _Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: OutlinedButton(
            onPressed: goToCategories,
            child: Text(community.category.name),
          ),
        ),
        const _Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: OutlinedButton(
            onPressed: goToModlog,
            child: const Text('Modlog'),
          ),
        ),
        const _Divider(),
        if (moderators != null && moderators.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Mods:', style: theme.textTheme.subtitle2),
          ),
          for (final mod in moderators)
            // TODO: add user picture, maybe make it into reusable component
            ListTile(
              title: Text(
                  mod.moderator.preferredUsername ?? '@${mod.moderator.name}'),
              onTap: () =>
                  goToUser.byId(context, mod.instanceHost, mod.moderator.id),
            ),
        ]
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Divider(),
      );
}

class _FollowButton extends HookWidget {
  final CommunityView community;

  const _FollowButton(this.community);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSubbed = useState(community.subscribed ?? false);
    final delayed = useDelayedLoading();
    final loggedInAction = useLoggedInAction(community.instanceHost);

    subscribe(Jwt token) async {
      delayed.start();
      try {
        await LemmyApiV2(community.instanceHost).run(FollowCommunity(
            communityId: community.community.id,
            follow: !isSubbed.value,
            auth: token.raw));
        isSubbed.value = !isSubbed.value;
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning),
              const SizedBox(width: 10),
              Text("couldn't ${isSubbed.value ? 'un' : ''}sub :<"),
            ],
          ),
        ));
      }

      delayed.cancel();
    }

    return ElevatedButtonTheme(
      data: ElevatedButtonThemeData(
        style: theme.elevatedButtonTheme.style.copyWith(
          shape: MaterialStateProperty.all(const StadiumBorder()),
          textStyle: MaterialStateProperty.all(theme.textTheme.subtitle1),
        ),
      ),
      child: Center(
        child: SizedBox(
          height: 27,
          width: 160,
          child: delayed.loading
              ? const ElevatedButton(
                  onPressed: null,
                  child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed:
                      loggedInAction(delayed.pending ? (_) {} : subscribe),
                  icon: isSubbed.value
                      ? const Icon(Icons.remove, size: 18)
                      : const Icon(Icons.add, size: 18),
                  label: Text('${isSubbed.value ? 'un' : ''}subscribe'),
                ),
        ),
      ),
    );
  }
}
