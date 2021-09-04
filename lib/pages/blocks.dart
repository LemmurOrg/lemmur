import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v3.dart';

import '../hooks/refreshable.dart';
import '../hooks/stores.dart';
import '../util/extensions/api.dart';
import '../util/goto.dart';
import '../widgets/avatar.dart';

class BlocksPage extends HookWidget {
  const BlocksPage();
  @override
  Widget build(BuildContext context) {
    final accStore = useAccountsStore();

    return DefaultTabController(
      length: accStore.loggedInInstances.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blocks'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final instance in accStore.loggedInInstances)
                Tab(
                  child: Text(
                      '${accStore.defaultUsernameFor(instance)!}@$instance'),
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final instance in accStore.loggedInInstances)
              _UserBlocks(
                instanceHost: instance,
                username: accStore.defaultUsernameFor(instance)!,
              )
          ],
        ),
      ),
    );
  }
}

class _UserBlocks extends HookWidget {
  final String instanceHost;
  final String username;

  const _UserBlocks({required this.instanceHost, required this.username});

  @override
  Widget build(BuildContext context) {
    final token = useAccountsStoreSelect(
        (store) => store.defaultUserDataFor(instanceHost)!.jwt);

    final userInfo = useRefreshable(() => LemmyApiV3(instanceHost)
        .run(GetSite(auth: token.raw))
        .then((response) => response.myUser));

    return RefreshIndicator(
        onRefresh: userInfo.refresh,
        child: ListView(
          children: userInfo.snapshot.data == null
              ? const [
                  Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: CircularProgressIndicator()),
                  )
                ]
              : [
                  for (final user in userInfo.snapshot.data!.personBlocks)
                    _BlockPersonTile(user, key: ObjectKey(user)),
                  if (userInfo.snapshot.data!.personBlocks.isEmpty)
                    const ListTile(
                        title: Center(child: Text('No users blocked'))),
                  // TODO: add in the future
                  // ListTile(
                  //   leading: Padding(
                  //     padding: const EdgeInsets.only(left: 16, right: 10),
                  //     child: Icon(Icons.add),
                  //   ),
                  //   title: Text('Block User'),
                  // ),
                  const Divider(),
                  // Text('Communities'),
                  for (final community
                      in userInfo.snapshot.data!.communityBlocks)
                    _BlockCommunityTile(community, key: ObjectKey(community)),

                  if (userInfo.snapshot.data!.communityBlocks.isEmpty)
                    const ListTile(
                        title: Center(child: Text('No communities blocked'))),
                  // ListTile(
                  //   leading: Padding(
                  //     padding: const EdgeInsets.only(left: 16, right: 10),
                  //     child: Icon(Icons.add),
                  //   ),
                  //   title: Text('Block Community'),
                  // ),
                ],
        ));
  }
}

class _BlockPersonTile extends HookWidget {
  final PersonBlockView _pbv;
  const _BlockPersonTile(this._pbv, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final token = useAccountsStoreSelect(
        (store) => store.defaultUserDataFor(_pbv.instanceHost)!.jwt);

    void showSnackBar(String e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
    }

    final blocked = useState(true);
    final pending = useState(false);

    unblock() async {
      if (pending.value) return;
      pending.value = true;
      try {
        await LemmyApiV3(_pbv.instanceHost).run(BlockPerson(
            auth: token.raw, block: false, personId: _pbv.target.id));
        blocked.value = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Person unblocked'), // TODO: add undo
        ));
      } on SocketException {
        showSnackBar('Network error');
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        showSnackBar(e.toString());
      } finally {
        pending.value = false;
      }
    }

    if (!blocked.value) return const SizedBox();

    return ListTile(
      leading: Avatar(url: _pbv.target.avatar),
      title: Text(_pbv.target.preferredName),
      trailing: IconButton(
        icon: const Icon(Icons.cancel),
        tooltip: 'unblock',
        onPressed: unblock,
      ),
      onTap: () {
        goToUser.byId(context, _pbv.instanceHost, _pbv.target.id);
      },
    );
  }
}

class _BlockCommunityTile extends HookWidget {
  final CommunityBlockView _cbv;
  const _BlockCommunityTile(this._cbv, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final token = useAccountsStoreSelect(
        (store) => store.defaultUserDataFor(_cbv.instanceHost)!.jwt);

    void showSnackBar(String e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
    }

    final blocked = useState(true);
    final pending = useState(false);

    unblock() async {
      if (pending.value) return;
      pending.value = true;
      try {
        await LemmyApiV3(_cbv.instanceHost).run(BlockCommunity(
            auth: token.raw, block: false, communityId: _cbv.community.id));
        blocked.value = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Community unblocked'), // TODO: add undo
        ));
      } on SocketException {
        showSnackBar('Network error');
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        showSnackBar(e.toString());
      } finally {
        pending.value = false;
      }
    }

    if (!blocked.value) return const SizedBox();

    return ListTile(
      leading: Avatar(url: _cbv.community.icon),
      title: Text(_cbv.community.originPreferredName),
      trailing: IconButton(
        icon: const Icon(Icons.cancel),
        tooltip: 'unblock',
        onPressed: unblock,
      ),
      onTap: () {
        goToCommunity.byId(context, _cbv.instanceHost, _cbv.community.id);
      },
    );
  }
}
