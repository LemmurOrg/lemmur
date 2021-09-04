import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmur/hooks/stores.dart';
import 'package:lemmy_api_client/v3.dart';

class BlockUserTile extends HookWidget {
  final String instanceHost;
  final int personId;
  final bool isBlocked;
  final void Function(bool) onDone;

  const BlockUserTile({
    required this.instanceHost,
    required this.isBlocked,
    required this.personId,
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
        await LemmyApiV3(instanceHost).run(BlockPerson(
          auth: accounts.defaultUserDataFor(instanceHost)!.jwt.raw,
          block: !isBlocked,
          personId: personId,
        ));
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isBlocked ? 'User unblocked' : 'User blocked'),
        ));
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
      title: Text(isBlocked ? 'Unblock user' : 'Block user'),
      onTap: block,
    );
  }
}
