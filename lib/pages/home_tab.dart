import 'dart:math' show max;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/lemmy_api_client.dart';

import '../hooks/infinite_scroll.dart';
import '../hooks/memo_future.dart';
import '../hooks/stores.dart';
import '../util/goto.dart';
import '../widgets/bottom_modal.dart';
import '../widgets/infinite_scroll.dart';
import '../widgets/post.dart';
import '../widgets/post_list_options.dart';
import 'add_account.dart';
import 'inbox.dart';

/// First thing users sees when opening the app
/// Shows list of posts from all or just specific instances
class HomeTab extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: needs to be an observer? for accounts changes
    final accStore = useAccountsStore();
    final selectedList = useState(_SelectedList(
        listingType: accStore.hasNoAccount
            ? PostListingType.local
            : PostListingType.subscribed));
    final isc = useInfiniteScrollController();
    final theme = Theme.of(context);
    final instancesIcons = useMemoFuture(() async {
      final map = <String, String>{};
      final instances = accStore.instances.toList(growable: false);
      final sites = await Future.wait(instances
          .map((e) => LemmyApi(e).v1.getSite().catchError((e) => null)));
      for (var i in Iterable.generate(sites.length)) {
        map[instances[i]] = sites[i].site.icon;
      }

      return map;
    });

    handleListChange() async {
      final val = await showModalBottomSheet<_SelectedList>(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          pop(_SelectedList thing) => Navigator.of(context).pop(thing);
          return BottomModal(
            child: Column(
              children: [
                SizedBox(height: 5),
                ListTile(
                  title: Text('EVERYTHING'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity:
                      VisualDensity(vertical: VisualDensity.minimumDensity),
                  leading: SizedBox.shrink(),
                ),
                ListTile(
                  title: Text('Subscribed'),
                  leading: SizedBox(width: 20, height: 20),
                  onTap: () => pop(
                      _SelectedList(listingType: PostListingType.subscribed)),
                ),
                ListTile(
                  title: Text('All'),
                  leading: SizedBox(width: 20, height: 20),
                  onTap: () =>
                      pop(_SelectedList(listingType: PostListingType.local)),
                ),
                for (final instance in accStore.instances) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(),
                  ),
                  ListTile(
                    title: Text(
                      instance.toUpperCase(),
                      style: TextStyle(
                          color:
                              theme.textTheme.bodyText1.color.withOpacity(0.7)),
                    ),
                    onTap: () => goToInstance(context, instance),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    visualDensity:
                        VisualDensity(vertical: VisualDensity.minimumDensity),
                    leading: (instancesIcons.hasData &&
                            instancesIcons.data[instance] != null)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CachedNetworkImage(
                                imageUrl: instancesIcons.data[instance],
                                height: 25,
                                width: 25,
                              ),
                            ),
                          )
                        : SizedBox(width: 30),
                  ),
                  ListTile(
                    title: Text(
                      'Subscribed',
                      style: TextStyle(
                          color: accStore.isAnonymousFor(instance)
                              ? theme.textTheme.bodyText1.color.withOpacity(0.4)
                              : null),
                    ),
                    onTap: accStore.isAnonymousFor(instance)
                        ? () => showCupertinoModalPopup(
                            context: context,
                            builder: (_) =>
                                AddAccountPage(instanceUrl: instance))
                        : () => pop(_SelectedList(
                              listingType: PostListingType.subscribed,
                              instanceUrl: instance,
                            )),
                    leading: SizedBox(width: 20),
                  ),
                  ListTile(
                    title: Text('All'),
                    onTap: () => pop(_SelectedList(
                      listingType: PostListingType.local,
                      instanceUrl: instance,
                    )),
                    leading: SizedBox(width: 20),
                  ),
                ]
              ],
            ),
          );
        },
      );
      if (val != null) {
        selectedList.value = val;
        isc.clear();
      }
    }

    final title = () {
      final first = selectedList.value.listingType == PostListingType.subscribed
          ? 'Subscribed'
          : 'All';
      final last = selectedList.value.instanceUrl == null
          ? ''
          : '@${selectedList.value.instanceUrl}';
      return '$first$last';
    }();

    if (accStore.instances.isEmpty) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text('there needs to be at least one instance')),
          ],
        ),
      );
    }

    return Scaffold(
      // TODO: make appbar autohide when scrolling down
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => goTo(context, (_) => InboxPage()),
          )
        ],
        centerTitle: true,
        title: TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: EdgeInsets.symmetric(horizontal: 15),
            primary: theme.buttonColor,
            textStyle: theme.primaryTextTheme.headline6,
          ),
          onPressed: handleListChange,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.primaryTextTheme.headline6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: theme.primaryTextTheme.headline6.color,
              ),
            ],
          ),
        ),
      ),
      body: InfiniteHomeList(
        controller: isc,
        selectedList: selectedList.value,
      ),
    );
  }
}

/// Infinite list of posts
class InfiniteHomeList extends HookWidget {
  final Function onStyleChange;
  final InfiniteScrollController controller;
  final _SelectedList selectedList;
  InfiniteHomeList({
    @required this.selectedList,
    this.onStyleChange,
    this.controller,
  }) : assert(selectedList != null);

  @override
  Widget build(BuildContext context) {
    final accStore = useAccountsStore();

    final sort = useState(SortType.active);

    void changeSorting(SortType newSort) {
      sort.value = newSort;
      controller.clear();
    }

    /// fetches post from many instances at once and combines them into a single
    /// list
    ///
    /// Process of combining them works sort of like zip function in python
    Future<List<PostView>> generalFetcher(
      int page,
      int limit,
      SortType sort,
      PostListingType listingType,
    ) async {
      assert(
          listingType != PostListingType.community, 'only subscribed or all');

      final instances = () {
        if (listingType == PostListingType.local) {
          return accStore.instances;
        } else {
          return accStore.loggedInInstances;
        }
      }();

      final futures =
          instances.map((instanceUrl) => LemmyApi(instanceUrl).v1.getPosts(
                type: listingType,
                sort: sort,
                page: page,
                limit: limit,
                auth: accStore.defaultTokenFor(instanceUrl)?.raw,
              ));
      final posts = await Future.wait(futures);
      final newPosts = <PostView>[];
      for (final i
          in Iterable.generate(posts.map((e) => e.length).reduce(max))) {
        for (final el in posts) {
          if (el.elementAt(i) != null) {
            newPosts.add(el[i]);
          }
        }
      }
      return newPosts;
    }

    Future<List<PostView>> Function(int, int) fetcherFromInstance(
            String instanceUrl, PostListingType listingType, SortType sort) =>
        (page, batchSize) => LemmyApi(instanceUrl).v1.getPosts(
              type: listingType,
              sort: sort,
              page: page,
              limit: batchSize,
              auth: accStore.defaultTokenFor(instanceUrl)?.raw,
            );

    return InfiniteScroll<PostView>(
      prepend: Column(
        children: [
          PostListOptions(
            onChange: changeSorting,
            defaultSort: SortType.active,
            styleButton: onStyleChange != null,
          ),
        ],
      ),
      builder: (post) => Column(
        children: [
          Post(post),
          SizedBox(height: 20),
        ],
      ),
      padding: EdgeInsets.zero,
      fetchMore: selectedList.instanceUrl == null
          ? (page, limit) =>
              generalFetcher(page, limit, sort.value, selectedList.listingType)
          : fetcherFromInstance(
              selectedList.instanceUrl,
              selectedList.listingType,
              sort.value,
            ),
      controller: controller,
      batchSize: 20,
    );
  }
}

class _SelectedList {
  final String instanceUrl;
  final PostListingType listingType;
  _SelectedList({
    @required this.listingType,
    this.instanceUrl,
  });

  String toString() =>
      'SelectedList({instanceUrl: $instanceUrl, listingType: $listingType})';
}
