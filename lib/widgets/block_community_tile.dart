import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v3.dart';

import '../hooks/stores.dart';

class BlockCommunityTile extends HookWidget {
  final String instanceHost;
  final int communityId;
  final bool isBlocked;
  final void Function(bool) onDone;

  const BlockCommunityTile({
    required this.instanceHost,
    required this.isBlocked,
    required this.communityId,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final accounts = useAccountsStore();
    final isPending = useState(false);

    Future<void> block() async {
      if (isPending.value == true) return;
      isPending.value = true;
      try {
        await LemmyApiV3(instanceHost).run(BlockCommunity(
          auth: accounts.defaultUserDataFor(instanceHost)!.jwt.raw,
          block: !isBlocked,
          communityId: communityId,
        ));
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(isBlocked ? 'Community unblocked' : 'Community blocked'),
        ));
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      } finally {
        onDone(!isBlocked);
        isPending.value = false;
      }
    }

    if (accounts.isAnonymousFor(instanceHost)) return const SizedBox();

    return ListTile(
      leading: isPending.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            )
          : const Icon(Icons.block),
      title: Text(isBlocked ? 'Unblock community' : 'Block community'),
      onTap: block,
    );
  }
}
