import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';

import '../../comment_tree.dart';
import '../../stores/accounts_store.dart';

part 'comment_store.g.dart';

class CommentStore = _CommentStore with _$CommentStore;

abstract class _CommentStore with Store {
  @observable
  CommentView comment;

  final ObservableList<CommentTree> children;

  final int? userMentionId;

  @observable
  bool selectable = false;

  @observable
  bool collapsed = false;

  @observable
  bool showRaw = false;

  @observable
  bool votingLoading = false;

  @observable
  bool deletingLoading = false;

  @observable
  bool savingLoading = false;

  @observable
  bool markingAsReadLoading = false;

  @computed
  bool get isMine =>
      comment.comment.creatorId ==
      _accountsStore.defaultUserDataFor(comment.instanceHost)?.userId;

  @computed
  VoteType get myVote => comment.myVote ?? VoteType.none;

  @computed
  bool get isOP => comment.comment.creatorId == comment.post.creatorId;

  final AccountsStore _accountsStore;

  _CommentStore(
    this._accountsStore, {
    required CommentTree commentTree,
    this.userMentionId,
  })  : comment = commentTree.comment,
        children = commentTree.children.asObservable();

  @action
  void toggleShowRaw() {
    showRaw = !showRaw;
  }

  @action
  void toggleSelectable() {
    selectable = !selectable;
  }

  @action
  void toggleCollapsed() {
    collapsed = !collapsed;
  }

  // TODO: error state
  // TODO: delayed loading
  @action
  Future<void> delete(Jwt token) async {
    try {
      deletingLoading = true;

      final result = await LemmyApiV3(comment.instanceHost).run(
        DeleteComment(
          commentId: comment.comment.id,
          deleted: !comment.comment.deleted,
          auth: token.raw,
        ),
      );

      comment = result.commentView;
    } catch (err) {
      print('catchall error');
    } finally {
      deletingLoading = false;
    }
  }

  // TODO: error state
  // TODO: delayed loading
  @action
  Future<void> save(Jwt token) async {
    try {
      savingLoading = true;

      final result = await LemmyApiV3(comment.instanceHost).run(
        SaveComment(
          commentId: comment.comment.id,
          save: !comment.saved,
          auth: token.raw,
        ),
      );

      comment = result.commentView;
    } catch (err) {
      print('catchall error');
    } finally {
      savingLoading = false;
    }
  }

  // TODO: error state
  // TODO: delayed loading
  @action
  Future<void> markAsRead(Jwt token) async {
    try {
      markingAsReadLoading = true;

      if (userMentionId != null) {
        final result = await LemmyApiV3(comment.instanceHost).run(
          MarkPersonMentionAsRead(
            personMentionId: userMentionId!,
            read: !comment.comment.read,
            auth: token.raw,
          ),
        );

        comment = comment.copyWith(comment: result.comment);
      } else {
        final result = await LemmyApiV3(comment.instanceHost).run(
          MarkCommentAsRead(
            commentId: comment.comment.id,
            read: !comment.comment.read,
            auth: token.raw,
          ),
        );

        comment = result.commentView;
      }
    } catch (err) {
      print('catchall error');
    } finally {
      markingAsReadLoading = false;
    }
  }

  // TODO: error state
  // TODO: delayed loading
  @action
  Future<void> _vote(VoteType voteType, Jwt token) async {
    try {
      votingLoading = true;

      final result = await LemmyApiV3(comment.instanceHost).run(
        CreateCommentLike(
          commentId: comment.comment.id,
          score: voteType,
          auth: token.raw,
        ),
      );

      comment = result.commentView;
    } catch (err) {
      print('catchall error');
    } finally {
      votingLoading = false;
    }
  }

  @action
  Future<void> upVote(Jwt token) async {
    await _vote(
      myVote == VoteType.up ? VoteType.none : VoteType.up,
      token,
    );
  }

  @action
  Future<void> downVote(Jwt token) async {
    await _vote(
      myVote == VoteType.down ? VoteType.none : VoteType.down,
      token,
    );
  }

  @action
  void addReply(CommentView commentView) {
    children.insert(0, CommentTree(commentView));
  }
}
