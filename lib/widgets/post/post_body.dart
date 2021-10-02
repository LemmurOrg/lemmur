import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/observer_consumers.dart';
import '../markdown_text.dart';
import 'post_status.dart';
import 'post_store.dart';

class PostBody extends StatelessWidget {
  const PostBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullPost = context.read<IsFullPost>();

    return ObserverBuilder<PostStore>(builder: (context, store) {
      if (store.postView.post.body == null) return const SizedBox();

      if (fullPost) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: MarkdownText(
            store.postView.post.body!,
            instanceHost: store.postView.instanceHost,
            selectable: true,
          ),
        );
      } else {
        return LayoutBuilder(
          builder: (context, constraints) {
            final span = TextSpan(
              text: store.postView.post.body,
            );
            final tp = TextPainter(
              text: span,
              maxLines: 10,
              textDirection: Directionality.of(context),
            )..layout(maxWidth: constraints.maxWidth - 20);

            if (tp.didExceedMaxLines) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: tp.height),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.8,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: MarkdownText(store.postView.post.body!,
                                instanceHost: store.postView.instanceHost)),
                      ),
                    ),
                    Container(
                      height: tp.preferredLineHeight * 2.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.cardColor.withAlpha(0),
                            theme.cardColor,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                  padding: const EdgeInsets.all(10),
                  child: MarkdownText(store.postView.post.body!,
                      instanceHost: store.postView.instanceHost));
            }
          },
        );
      }
    });
  }
}