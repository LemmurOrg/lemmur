import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../hooks/logged_in_action.dart';
import '../../l10n/l10n.dart';
import '../../util/observer_consumers.dart';
import 'community_store.dart';

class CommunityFollowButton extends HookWidget {
  const CommunityFollowButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final loggedInAction =
        useLoggedInAction(context.read<CommunityStore>().instanceHost);

    return ObserverBuilder<CommunityStore>(builder: (context, store) {
      final communityView = store.communityView;

      if (communityView == null) return const SizedBox();

      return ElevatedButtonTheme(
        data: ElevatedButtonThemeData(
          style: theme.elevatedButtonTheme.style?.copyWith(
            shape: MaterialStateProperty.all(const StadiumBorder()),
            textStyle: MaterialStateProperty.all(theme.textTheme.subtitle1),
          ),
        ),
        child: Center(
          child: SizedBox(
            height: 27,
            width: 160,
            child: store.subscribingState.isLoading
                ? const ElevatedButton(
                    onPressed: null,
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: loggedInAction(store.subscribingState.isLoading
                        ? (_) {}
                        : store.subscribe),
                    icon: communityView.subscribed
                        ? const Icon(Icons.remove, size: 18)
                        : const Icon(Icons.add, size: 18),
                    label: Text(communityView.subscribed
                        ? L10n.of(context).unsubscribe
                        : L10n.of(context).subscribe),
                  ),
          ),
        ),
      );
    });
  }
}
