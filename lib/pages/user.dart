import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v2.dart';

import '../hooks/logged_in_action.dart';
import '../widgets/user_profile.dart';
import 'send_message.dart';

/// Page showing posts, comments, and general info about a user.
class UserPage extends HookWidget {
  final int userId;
  final String instanceHost;
  final Future<FullUserView> _userDetails;

  UserPage({@required this.userId, @required this.instanceHost})
      : assert(userId != null),
        assert(instanceHost != null),
        _userDetails = LemmyApiV2(instanceHost).run(GetUserDetails(
            userId: userId, savedOnly: true, sort: SortType.active));

  UserPage.fromName({@required this.instanceHost, @required String username})
      : assert(instanceHost != null),
        assert(username != null),
        userId = null,
        _userDetails = LemmyApiV2(instanceHost).run(GetUserDetails(
            username: username, savedOnly: true, sort: SortType.active));

  @override
  Widget build(BuildContext context) {
    final userDetailsSnap = useFuture(_userDetails);
    final loggedInAction = useLoggedInAction(instanceHost);

    final body = () {
      if (userDetailsSnap.hasData) {
        return UserProfile.fromFullUserView(userDetailsSnap.data);
      } else if (userDetailsSnap.hasError) {
        return const Center(child: Text('Could not find that user.'));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          if (userDetailsSnap.hasData) ...[
            IconButton(
              icon: const Icon(Icons.email),
              onPressed: loggedInAction((token) => showCupertinoModalPopup(
                  context: context,
                  builder: (_) => SendMessagePage(
                        instanceHost: instanceHost,
                        token: token,
                        recipient: userDetailsSnap.data.userView.user,
                      ))),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.text('Share user',
                  userDetailsSnap.data.userView.user.actorId, 'text/plain'),
            ),
          ]
        ],
      ),
      body: body,
    );
  }
}
