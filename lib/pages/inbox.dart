import 'dart:math' show pi;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v2.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

import '../hooks/delayed_loading.dart';
import '../hooks/infinite_scroll.dart';
import '../hooks/stores.dart';
import '../util/delayed_action.dart';
import '../util/extensions/api.dart';
import '../util/extensions/datetime.dart';
import '../util/goto.dart';
import '../util/more_icon.dart';
import '../widgets/bottom_modal.dart';
import '../widgets/comment.dart';
import '../widgets/infinite_scroll.dart';
import '../widgets/info_table_popup.dart';
import '../widgets/markdown_mode_icon.dart';
import '../widgets/markdown_text.dart';
import '../widgets/radio_picker.dart';
import '../widgets/sortable_infinite_list.dart';
import '../widgets/tile_action.dart';
import 'send_message.dart';

class InboxPage extends HookWidget {
  const InboxPage();

  @override
  Widget build(BuildContext context) {
    final accStore = useAccountsStore();
    final selected = useState(_SelectedAccount(
        accStore.defaultInstanceHost, accStore.defaultUsername));
    final theme = Theme.of(context);
    final isc = useInfiniteScrollController();
    final unreadOnly = useState(true);

    if (accStore.hasNoAccount) {
      return Scaffold(
        appBar: AppBar(),
        body: const Text('No accounts added'),
      );
    }

    toggleUnreadOnly() {
      unreadOnly.value = !unreadOnly.value;
      isc.tryClear();
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: RadioPicker<_SelectedAccount>(
            onChanged: (val) {
              selected.value = val;
              isc.tryClear();
            },
            title: 'select account',
            groupValue: selected.value,
            buttonBuilder: (context, displayString, onPressed) => TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 15),
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      displayString,
                      style: theme.appBarTheme.textTheme.headline6,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            values: [
              for (final instance in accStore.loggedInInstances)
                for (final name in accStore.usernamesFor(instance))
                  _SelectedAccount(instance, name)
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(unreadOnly.value ? Icons.mail : Icons.mail_outline),
              onPressed: toggleUnreadOnly,
              tooltip: unreadOnly.value ? 'show all' : 'show only unread',
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Replies'),
              Tab(text: 'Mentions'),
              Tab(text: 'Messages'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SortableInfiniteList<CommentView>(
              controller: isc,
              defaultSort: SortType.new_,
              fetcher: (page, batchSize, sortType) =>
                  LemmyApiV2(selected.value.instance).run(GetReplies(
                auth: accStore
                    .tokenFor(selected.value.instance, selected.value.name)
                    ?.raw,
                sort: sortType,
                limit: batchSize,
                page: page,
                unreadOnly: unreadOnly.value,
              )),
              itemBuilder: (cv) => CommentWidget.fromCommentView(
                cv,
                canBeMarkedAsRead: true,
                hideOnRead: unreadOnly.value,
              ),
            ),
            SortableInfiniteList<UserMentionView>(
              controller: isc,
              defaultSort: SortType.new_,
              fetcher: (page, batchSize, sortType) =>
                  LemmyApiV2(selected.value.instance).run(GetUserMentions(
                auth: accStore
                    .tokenFor(selected.value.instance, selected.value.name)
                    ?.raw,
                sort: sortType,
                limit: batchSize,
                page: page,
                unreadOnly: unreadOnly.value,
              )),
              itemBuilder: (umv) => CommentWidget.fromUserMentionView(
                umv,
                hideOnRead: unreadOnly.value,
              ),
            ),
            InfiniteScroll<PrivateMessageView>(
              controller: isc,
              fetcher: (page, batchSize) =>
                  LemmyApiV2(selected.value.instance).run(
                GetPrivateMessages(
                  auth: accStore
                      .tokenFor(selected.value.instance, selected.value.name)
                      ?.raw,
                  limit: batchSize,
                  page: page,
                  unreadOnly: unreadOnly.value,
                ),
              ),
              itemBuilder: (mv) => PrivateMessageTile(
                msg: mv,
                account: selected.value,
                hideOnRead: unreadOnly.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivateMessageTile extends HookWidget {
  final PrivateMessageView msg;
  final _SelectedAccount account;
  final bool hideOnRead;

  const PrivateMessageTile(
      {@required this.msg, @required this.account, this.hideOnRead = false});
  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context) {
    final accStore = useAccountsStore();
    final theme = Theme.of(context);

    final raw = useState(false);
    final selectable = useState(false);
    final deleted = useState(msg.privateMessage.deleted);
    final deleteDelayed = useDelayedLoading(const Duration(milliseconds: 250));
    final read = useState(msg.privateMessage.read);
    final readDelayed = useDelayedLoading(const Duration(milliseconds: 200));
    final content = useState(msg.privateMessage.content);

    final toMe = _SelectedAccount(
            msg.recipient.originInstanceHost, msg.recipient.name) ==
        account;

    final otherSide = toMe ? msg.creator : msg.recipient;

    void showMoreMenu() {
      showBottomModal(
        context: context,
        builder: (context) {
          pop() => Navigator.of(context).pop();
          return Column(
            children: [
              ListTile(
                title: Text(raw.value ? 'Show fancy' : 'Show raw'),
                leading: markdownModeIcon(fancy: !raw.value),
                onTap: () {
                  raw.value = !raw.value;
                  pop();
                },
              ),
              ListTile(
                title: Text('Make ${selectable.value ? 'un' : ''}selectable'),
                leading: Icon(
                    selectable.value ? Icons.assignment : Icons.content_cut),
                onTap: () {
                  selectable.value = !selectable.value;
                  pop();
                },
              ),
              ListTile(
                title: const Text('Nerd stuff'),
                leading: const Icon(Icons.info_outline),
                onTap: () {
                  pop();
                  showInfoTablePopup(context: context, table: msg.toJson());
                },
              ),
            ],
          );
        },
      );
    }

    handleDelete() => delayedAction<PrivateMessageView>(
          context: context,
          delayedLoading: deleteDelayed,
          instanceHost: account.instance,
          query: DeletePrivateMessage(
            privateMessageId: msg.privateMessage.id,
            auth: accStore.tokenFor(account.instance, account.name)?.raw,
            deleted: !deleted.value,
          ),
          onSuccess: (_) => deleted.value = !deleted.value,
        );

    handleRead() => delayedAction<PrivateMessageView>(
          context: context,
          delayedLoading: readDelayed,
          instanceHost: account.instance,
          query: MarkPrivateMessageAsRead(
            privateMessageId: msg.privateMessage.id,
            auth: accStore.tokenFor(account.instance, account.name)?.raw,
            read: !read.value,
          ),
          // TODO: add notification for notifying parent list
          onSuccess: (_) => read.value = !read.value,
        );

    if (hideOnRead && read.value) {
      return const SizedBox.shrink();
    }

    final body = raw.value
        ? selectable.value
            ? SelectableText(content.value)
            : Text(content.value)
        : MarkdownText(
            content.value,
            instanceHost: msg.instanceHost,
            selectable: selectable.value,
          );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                toMe ? 'from ' : 'to ',
                style: TextStyle(color: theme.textTheme.caption.color),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => goToUser.fromUserSafe(context, otherSide),
                child: Row(
                  children: [
                    if (otherSide.avatar != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: CachedNetworkImage(
                          imageUrl: otherSide.avatar,
                          height: 20,
                          width: 20,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: imageProvider,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    Text(
                      otherSide.originDisplayName,
                      style: TextStyle(color: theme.accentColor),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (msg.privateMessage.updated != null) const Text('🖊  '),
              Text(msg.privateMessage.updated?.fancy ??
                  msg.privateMessage.published.fancy),
              const SizedBox(width: 5),
              Transform(
                transform: Matrix4Transform()
                    .rotateByCenter((toMe ? -1 : 1) * pi / 2,
                        const Size(_iconSize, _iconSize))
                    .flipVertically(
                        origin: const Offset(_iconSize / 2, _iconSize / 2))
                    .matrix4,
                child: const Opacity(
                  opacity: 0.8,
                  child: Icon(Icons.reply, size: _iconSize),
                ),
              )
            ],
          ),
          const SizedBox(height: 5),
          if (msg.privateMessage.deleted)
            const Text('deleted by creator',
                style: TextStyle(fontStyle: FontStyle.italic))
          else
            body,
          Row(children: [
            const Spacer(),
            TileAction(
              icon: moreIcon,
              onPressed: showMoreMenu,
              tooltip: 'more',
            ),
            if (toMe) ...[
              TileAction(
                iconColor: read.value ? theme.accentColor : null,
                icon: Icons.check,
                tooltip: 'mark as read',
                onPressed: handleRead,
                delayedLoading: readDelayed,
              ),
              TileAction(
                icon: Icons.reply,
                tooltip: 'reply',
                onPressed: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (_) => SendMessagePage(
                            instanceHost: account.instance,
                            username: account.name,
                            recipient: otherSide,
                          ));
                },
              )
            ] else ...[
              TileAction(
                icon: Icons.edit,
                tooltip: 'edit',
                onPressed: () async {
                  final pmv = await showCupertinoModalPopup<PrivateMessageView>(
                      context: context,
                      builder: (_) => SendMessagePage.edit(
                            msg,
                            instanceHost: account.instance,
                            username: account.name,
                            content: content.value,
                          ));
                  if (pmv != null) content.value = pmv.privateMessage.content;
                },
              ),
              TileAction(
                delayedLoading: deleteDelayed,
                icon: deleted.value ? Icons.restore : Icons.delete,
                tooltip: 'delete',
                onPressed: handleDelete,
              ),
            ]
          ]),
          const Divider(),
        ],
      ),
    );
  }
}

@immutable
class _SelectedAccount {
  final String instance;
  final String name;

  const _SelectedAccount(this.instance, this.name);

  String toString() => '$name@$instance';

  @override
  bool operator ==(Object other) =>
      other is _SelectedAccount &&
      name == other.name &&
      instance == other.instance;

  @override
  int get hashCode => super.hashCode;
}
