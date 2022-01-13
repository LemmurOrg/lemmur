import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import '../../l10n/l10n.dart';
import '../../widgets/bottom_modal.dart';
import '../../widgets/info_table_popup.dart';

class InstanceMoreMenu extends HookWidget {
  final FullSiteView site;

  const InstanceMoreMenu({Key? key, required this.site}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final instanceUrl = 'https://${site.instanceHost}';

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.open_in_browser),
          title: Text(L10n.of(context).open_in_browser),
          onTap: () async {
            if (await ul.canLaunch(instanceUrl)) {
              await ul.launch(instanceUrl);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(L10n.of(context).cannot_open_in_browser),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(L10n.of(context).nerd_stuff),
          onTap: () {
            showInfoTablePopup(context: context, table: site.toJson());
          },
        ),
      ],
    );
  }

  static void open(BuildContext context, FullSiteView site) {
    showBottomModal(
      context: context,
      builder: (context) => InstanceMoreMenu(site: site),
    );
  }
}
