import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

import '../../util/extensions/api.dart';
import '../../util/goto.dart';
import '../../util/intl.dart';
import '../../util/observer_consumers.dart';
import '../../widgets/avatar.dart';
import '../../widgets/cached_network_image.dart';
import '../../widgets/fullscreenable_image.dart';
import 'community_follow_button.dart';
import 'community_store.dart';

class CommunityOverview extends StatelessWidget {
  final CommunityView community;
  const CommunityOverview(this.community);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadow = BoxShadow(color: theme.canvasColor, blurRadius: 5);

    return ObserverBuilder<CommunityStore>(
      builder: (context, store) {
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
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  FullscreenableImage(
                    url: community.community.icon!,
                    child: Material(
                      color: Colors.transparent,
                      child: Avatar(
                        url: community.community.icon,
                        radius: 83 / 2,
                        alwaysShow: true,
                      ),
                    ),
                  ),
                ],
              )
            : null;

        return Stack(
          children: [
            if (community.community.banner != null)
              FullscreenableImage(
                url: community.community.banner!,
                child: CachedNetworkImage(
                  imageUrl: community.community.banner!,
                  errorBuilder: (_, ___) => const SizedBox.shrink(),
                ),
              ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 45),
                  if (icon != null) icon,
                  const SizedBox(height: 10),
                  // NAME
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: theme.textTheme.subtitle1
                          ?.copyWith(shadows: [shadow]),
                      children: [
                        const TextSpan(
                          text: '!',
                          style: TextStyle(fontWeight: FontWeight.w200),
                        ),
                        TextSpan(
                          text: community.community.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(
                          text: '@',
                          style: TextStyle(fontWeight: FontWeight.w200),
                        ),
                        TextSpan(
                          text: community.community.originInstanceHost,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => goToInstance(
                                  context,
                                  community.community.originInstanceHost,
                                ),
                        ),
                      ],
                    ),
                  ),
                  // TITLE/MOTTO
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      community.community.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        shadows: [shadow],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // INFO ICONS
                      Row(
                        children: [
                          const Spacer(),
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 3),
                          Text(compactNumber(community.counts.subscribers)),
                          const Spacer(flex: 4),
                          const Icon(Icons.record_voice_over, size: 20),
                          const SizedBox(width: 3),
                          Text(store.fullCommunityView == null
                              ? 'xx'
                              : compactNumber(store.fullCommunityView!.online)),
                          const Spacer(),
                        ],
                      ),
                      const CommunityFollowButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
