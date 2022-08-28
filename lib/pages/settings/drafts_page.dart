import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';

import '../../stores/comment_drafts_store.dart';

class DraftsPage extends HookWidget {
  const DraftsPage._();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Drafts'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(child: Text('Comments')),
                Tab(child: Text('Posts')),
              ],
            ),
          ),
          body: const TabBarView(children: [
            _CommentsTab(),
            _PostsTab(),
          ])),
    );
  }

  static Route route() => MaterialPageRoute(
        builder: (context) => const DraftsPage._(),
      );
}

class _CommentsTab extends HookWidget {
  const _CommentsTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LazyBox<String>>(
      valueListenable: CommentDraftStore.allDraftsListenable(),
      builder: (context, box, widget) {
        if (box.isEmpty) {
          return const Center(child: Text('no drafts yet'));
        }

        Future<void> removeAllDrafts() async {
          final removeAll = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text(
                            'Do you want to remove ALL comment drafts?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            child: const Text('Yes'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('No'),
                          ),
                        ],
                      )) ??
              false;
          if (removeAll) {
            await CommentDraftStore.removeAllDrafts();
          }
        }

        return ListView.builder(
          itemCount: box.length + 1,
          itemBuilder: (context, index) {
            if (index == box.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: removeAllDrafts,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: const Text('Remove all drafts'),
                ),
              );
            }
            return _CommentDraftTile(CommentDraftStore.keyAt(index)!);
          },
        );
      },
    );
  }
}

class _CommentDraftTile extends HookWidget {
  final String databaseKey;

  const _CommentDraftTile(this.databaseKey);

  @override
  Widget build(BuildContext context) {
    final body = useState<String?>(null);
    useEffect(() {
      CommentDraftStore.loadDraft(databaseKey)
          .then((value) => body.value = value);
      return null;
    });

    return ListTile(
      key: ValueKey(key),
      title: body.value == null
          ? const CircularProgressIndicator.adaptive()
          : Text(body.value!),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          CommentDraftStore.removeDraft(databaseKey);
        },
      ),
      subtitle: Text(databaseKey),
    );
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('TBD'));
  }
}
