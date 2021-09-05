import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import '../../comment_tree.dart';
import '../../hooks/delayed_loading.dart';
import '../../hooks/logged_in_action.dart';
import '../../hooks/stores.dart';
import '../../l10n/l10n.dart';
import '../../util/delayed_action.dart';
import '../../util/extensions/api.dart';
import '../../util/extensions/cake_day.dart';
import '../../util/extensions/datetime.dart';
import '../../util/goto.dart';
import '../../util/intl.dart';
import '../../util/share.dart';
import '../../util/text_color.dart';
import '../avatar.dart';
import '../bottom_modal.dart';
import '../info_table_popup.dart';
import '../markdown_mode_icon.dart';
import '../markdown_text.dart';
import '../tile_action.dart';
import '../write_comment.dart';
import 'comment_store.dart';

/// A single comment that renders its replies
class CommentWidget extends HookWidget {
  final int depth;
  final CommentTree commentTree;
  final bool detached;
  final bool canBeMarkedAsRead;
  final bool hideOnRead;
  final int? userMentionId;

  static const colors = [
    Colors.pink,
    Colors.green,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
  ];

  const CommentWidget(
    this.commentTree, {
    this.depth = 0,
    this.detached = false,
    this.canBeMarkedAsRead = false,
    this.hideOnRead = false,
    this.userMentionId,
  });

  CommentWidget.fromCommentView(
    CommentView cv, {
    bool canBeMarkedAsRead = false,
    bool hideOnRead = false,
  }) : this(
          CommentTree(cv),
          detached: true,
          canBeMarkedAsRead: canBeMarkedAsRead,
          hideOnRead: hideOnRead,
        );

  CommentWidget.fromPersonMentionView(
    PersonMentionView userMentionView, {
    bool hideOnRead = false,
  }) : this(
          CommentTree(CommentView.fromJson(userMentionView.toJson())),
          hideOnRead: hideOnRead,
          canBeMarkedAsRead: true,
          detached: true,
          userMentionId: userMentionView.personMention.id,
        );

  _showCommentInfo(BuildContext context) {
    final com = commentTree.comment;
    showInfoTablePopup(context: context, table: {
      ...com.toJson(),
      '% of upvotes':
          '${100 * (com.counts.upvotes / (com.counts.upvotes + com.counts.downvotes))}%',
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final commentStore = useMemoized(() {
      return CommentStore(commentTree, context.read());
    }, [commentTree]);

    final showScores =
        useConfigStoreSelect((configStore) => configStore.showScores);

    final isRead = useState(commentTree.comment.comment.read);

    final loggedInAction = useLoggedInAction(commentTree.comment.instanceHost);

    final comment = commentTree.comment;

    if (hideOnRead && isRead.value) {
      return const SizedBox();
    }

    handleDelete(Jwt token) {
      Navigator.of(context).pop();
      commentStore.delete(token);
    }

    handleEdit() async {
      final editedComment = await showCupertinoModalPopup<CommentView>(
        context: context,
        builder: (_) => WriteComment.edit(
          comment: comment.comment,
          post: comment.post,
        ),
      );

      if (editedComment != null) {
        commentStore.comment = editedComment;
        Navigator.of(context).pop();
      }
    }

    void _openMoreMenu(BuildContext context) {
      pop() => Navigator.of(context).pop();

      final com = commentTree.comment;
      showBottomModal(
        context: context,
        builder: (context) => Observer(
          builder: (context) => Column(
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open in browser'),
                onTap: () async => await ul.canLaunch(com.comment.link)
                    ? ul.launch(com.comment.link)
                    : ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("can't open in browser"))),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share url'),
                onTap: () => share(com.comment.link, context: context),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share text'),
                onTap: () => share(com.comment.content, context: context),
              ),
              Observer(
                builder: (context) => ListTile(
                  leading: Icon(
                    commentStore.selectable
                        ? Icons.assignment
                        : Icons.content_cut,
                  ),
                  title: Text(
                      'Make text ${commentStore.selectable ? 'un' : ''}selectable'),
                  onTap: () {
                    commentStore.toggleSelectable();
                    pop();
                  },
                ),
              ),
              ListTile(
                leading: markdownModeIcon(fancy: !commentStore.showRaw),
                title:
                    Text('Show ${commentStore.showRaw ? 'fancy' : 'raw'} text'),
                onTap: () {
                  commentStore.toggleShowRaw();
                  pop();
                },
              ),
              if (commentStore.isMine)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: handleEdit,
                ),
              if (commentStore.isMine)
                Observer(
                  builder: (context) => ListTile(
                    leading: Icon(
                      commentStore.comment.comment.deleted
                          ? Icons.restore
                          : Icons.delete,
                    ),
                    title: Text(
                      commentStore.comment.comment.deleted
                          ? 'Restore'
                          : 'Delete',
                    ),
                    onTap: loggedInAction(handleDelete),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Nerd stuff'),
                onTap: () => _showCommentInfo(context),
              ),
            ],
          ),
        ),
      );
    }

    reply() async {
      final newComment = await showCupertinoModalPopup<CommentView>(
        context: context,
        builder: (_) => WriteComment.toComment(
            comment: comment.comment, post: comment.post),
      );
      if (newComment != null) {
        commentStore.addReply(newComment);
      }
    }

    final body = Observer(
      builder: (context) {
        if (commentStore.comment.comment.deleted) {
          return Flexible(
            child: Text(
              L10n.of(context)!.deleted_by_creator,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        } else if (comment.comment.removed) {
          return const Flexible(
            child: Text(
              'comment deleted by moderator',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        } else if (commentStore.collapsed) {
          return Flexible(
            child: Opacity(
              opacity: 0.3,
              child: Text(
                commentTree.comment.comment.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        // TODO: bug, the text is selectable even when disabled after following
        //       these steps:
        //       make selectable > show raw > show fancy > make unselectable
        return Flexible(
          child: commentStore.showRaw
              ? commentStore.selectable
                  ? SelectableText(commentTree.comment.comment.content)
                  : Text(commentTree.comment.comment.content)
              : MarkdownText(
                  commentTree.comment.comment.content,
                  instanceHost: commentTree.comment.instanceHost,
                  selectable: commentStore.selectable,
                ),
        );
      },
    );

    final actions = Observer(
      builder: (context) => commentStore.collapsed
          ? const SizedBox()
          : Row(
              children: [
                if (commentStore.selectable &&
                    !commentStore.comment.comment.deleted &&
                    !comment.comment.removed)
                  TileAction(
                    icon: Icons.content_copy,
                    tooltip: 'copy',
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: commentTree.comment.comment.content,
                        ),
                      ).then(
                        (_) => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('comment copied to clipboard'),
                          ),
                        ),
                      );
                    },
                  ),
                const Spacer(),
                if (canBeMarkedAsRead)
                  _MarkAsRead(
                    commentTree.comment,
                    onChanged: (val) => isRead.value = val,
                    userMentionId: userMentionId,
                  ),
                if (detached)
                  TileAction(
                    icon: Icons.link,
                    onPressed: () => goToPost(
                        context, comment.instanceHost, comment.post.id),
                    tooltip: 'go to post',
                  ),
                TileAction(
                  icon: Icons.more_horiz,
                  onPressed: () => _openMoreMenu(context),
                  delayedLoading: DelayedLoading(
                    loading: commentStore.deletingLoading,
                    start: () {},
                    cancel: () {},
                    pending: false,
                  ),
                  tooltip: L10n.of(context)!.more,
                ),
                _SaveComment(commentTree.comment),
                if (!commentStore.comment.comment.deleted &&
                    !comment.comment.removed &&
                    !comment.post.locked)
                  TileAction(
                    icon: Icons.reply,
                    onPressed: loggedInAction((_) => reply()),
                    tooltip: L10n.of(context)!.reply,
                  ),
                TileAction(
                  icon: Icons.arrow_upward,
                  iconColor: commentStore.myVote == VoteType.up
                      ? theme.accentColor
                      : null,
                  onPressed: loggedInAction(commentStore.upVote),
                  tooltip: 'upvote',
                ),
                TileAction(
                  icon: Icons.arrow_downward,
                  iconColor:
                      commentStore.myVote == VoteType.down ? Colors.red : null,
                  onPressed: loggedInAction(commentStore.downVote),
                  tooltip: 'downvote',
                ),
              ],
            ),
    );

    return Observer(
      builder: (context) => InkWell(
        onLongPress:
            commentStore.selectable ? null : commentStore.toggleCollapsed,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.only(left: depth > 1 ? (depth - 1) * 5.0 : 0),
              decoration: BoxDecoration(
                  border: Border(
                      left: depth > 0
                          ? BorderSide(
                              color: colors[depth % colors.length], width: 5)
                          : BorderSide.none,
                      top: const BorderSide(width: 0.2))),
              child: Column(
                children: [
                  Row(children: [
                    if (comment.creator.avatar != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: InkWell(
                          onTap: () =>
                              goToUser.fromPersonSafe(context, comment.creator),
                          child: Avatar(
                            url: comment.creator.avatar,
                            radius: 10,
                            noBlank: true,
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: () =>
                          goToUser.fromPersonSafe(context, comment.creator),
                      child: Text(comment.creator.originPreferredName,
                          style: TextStyle(
                            color: theme.accentColor,
                          )),
                    ),
                    if (comment.creator.isCakeDay) const Text(' 🍰'),
                    if (commentStore.isOP) _CommentTag('OP', theme.accentColor),
                    if (comment.creator.admin)
                      _CommentTag(
                        L10n.of(context)!.admin.toUpperCase(),
                        theme.accentColor,
                      ),
                    if (comment.creator.banned)
                      const _CommentTag('BANNED', Colors.red),
                    if (comment.creatorBannedFromCommunity)
                      const _CommentTag('BANNED FROM COMMUNITY', Colors.red),
                    const Spacer(),
                    if (commentStore.collapsed &&
                        commentTree.children.isNotEmpty) ...[
                      _CommentTag('+${commentTree.children.length}',
                          Theme.of(context).accentColor),
                      const SizedBox(width: 7),
                    ],
                    InkWell(
                      onTap: () => _showCommentInfo(context),
                      child: Row(
                        children: [
                          if (commentStore.votingLoading)
                            SizedBox.fromSize(
                              size: const Size.square(16),
                              child: const CircularProgressIndicator(),
                            )
                          else if (showScores)
                            Text(
                              compactNumber(commentStore.comment.counts.score),
                            ),
                          if (showScores)
                            const Text(' · ')
                          else
                            const SizedBox(width: 4),
                          Text(comment.comment.published.fancy),
                        ],
                      ),
                    )
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [body]),
                  const SizedBox(height: 5),
                  actions,
                ],
              ),
            ),
            if (!commentStore.collapsed)
              for (final c in commentStore.children)
                CommentWidget(c, depth: depth + 1),
          ],
        ),
      ),
    );
  }
}

class _MarkAsRead extends HookWidget {
  final CommentView commentView;
  final ValueChanged<bool>? onChanged;
  final int? userMentionId;

  const _MarkAsRead(
    this.commentView, {
    required this.onChanged,
    required this.userMentionId,
  });

  @override
  Widget build(BuildContext context) {
    final comment = commentView.comment;
    final instanceHost = commentView.instanceHost;
    final loggedInAction = useLoggedInAction(instanceHost);

    final isRead = useState(comment.read);
    final delayedRead = useDelayedLoading();

    Future<void> handleMarkAsSeen(Jwt token) => delayedAction<FullCommentView>(
          context: context,
          delayedLoading: delayedRead,
          instanceHost: instanceHost,
          query: MarkCommentAsRead(
            commentId: comment.id,
            read: !isRead.value,
            auth: token.raw,
          ),
          onSuccess: (val) {
            isRead.value = val.commentView.comment.read;
            onChanged?.call(isRead.value);
          },
        );

    Future<void> handleMarkMentionAsSeen(Jwt token) =>
        delayedAction<PersonMentionView>(
          context: context,
          delayedLoading: delayedRead,
          instanceHost: instanceHost,
          query: MarkPersonMentionAsRead(
            personMentionId: userMentionId!,
            read: !isRead.value,
            auth: token.raw,
          ),
          onSuccess: (val) {
            isRead.value = val.personMention.read;
            onChanged?.call(isRead.value);
          },
        );

    return TileAction(
      icon: Icons.check,
      delayedLoading: delayedRead,
      onPressed: userMentionId != null
          ? loggedInAction(handleMarkMentionAsSeen)
          : loggedInAction(handleMarkAsSeen),
      iconColor: isRead.value ? Theme.of(context).accentColor : null,
      tooltip: isRead.value
          ? L10n.of(context)!.mark_as_unread
          : L10n.of(context)!.mark_as_read,
    );
  }
}

class _SaveComment extends HookWidget {
  final CommentView comment;

  const _SaveComment(this.comment);

  @override
  Widget build(BuildContext context) {
    final loggedInAction = useLoggedInAction(comment.instanceHost);
    final isSaved = useState(comment.saved);
    final delayed = useDelayedLoading();

    handleSave(Jwt token) => delayedAction<FullCommentView>(
          context: context,
          delayedLoading: delayed,
          instanceHost: comment.instanceHost,
          query: SaveComment(
            commentId: comment.comment.id,
            save: !isSaved.value,
            auth: token.raw,
          ),
          onSuccess: (res) => isSaved.value = res.commentView.saved,
        );

    return TileAction(
      delayedLoading: delayed,
      icon: isSaved.value ? Icons.bookmark : Icons.bookmark_border,
      onPressed: loggedInAction(delayed.pending ? (_) {} : handleSave),
      tooltip: '${isSaved.value ? 'unsave' : 'save'} comment',
    );
  }
}

class _CommentTag extends StatelessWidget {
  final String text;
  final Color bgColor;

  const _CommentTag(this.text, this.bgColor);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: bgColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Text(text,
              style: TextStyle(
                color: textColorBasedOnBackground(bgColor),
                fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! - 5,
                fontWeight: FontWeight.w800,
              )),
        ),
      );
}
