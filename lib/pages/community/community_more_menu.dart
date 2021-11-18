import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import '../../widgets/bottom_modal.dart';
import '../../widgets/info_table_popup.dart';

class CommunityMoreMenu extends StatelessWidget {
  final CommunityView communityView;

  const CommunityMoreMenu({Key? key, required this.communityView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.open_in_browser),
          title: const Text('Open in browser'),
          onTap: () async => await ul.canLaunch(communityView.community.actorId)
              ? ul.launch(communityView.community.actorId)
              : ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("can't open in browser"))),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Nerd stuff'),
          onTap: () {
            showInfoTablePopup(context: context, table: communityView.toJson());
          },
        ),
      ],
    );
  }

  static void open(BuildContext context, CommunityView communityView) {
    showBottomModal(
      context: context,
      builder: (context) => CommunityMoreMenu(
        communityView: communityView,
      ),
    );
  }
}
