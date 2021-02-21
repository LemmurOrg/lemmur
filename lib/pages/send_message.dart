import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v2.dart';

import '../hooks/stores.dart';
import '../util/extensions/api.dart';
import '../widgets/markdown_text.dart';

class SendMessagePage extends HookWidget {
  final String username;
  final String instanceHost;

  final UserSafe recipient;

  /// if it's non null then this page is used for edit
  final PrivateMessage privateMessage;
  final String content;
  final Jwt token;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  SendMessagePage({
    this.username,
    @required this.instanceHost,
    @required this.recipient,
    this.token,
    this.privateMessage,
    this.content,
  })  : assert(username != null || token != null, 'argument required'),
        assert(instanceHost != null, 'argument required'),
        assert(recipient != null, 'argument required');

  SendMessagePage.edit(
    PrivateMessageView pmv, {
    this.instanceHost,
    this.username,
    this.content,
    this.token,
  })  : privateMessage = pmv.privateMessage,
        recipient = pmv.recipient;

  @override
  Widget build(BuildContext context) {
    final accStore = useAccountsStore();
    final showFancy = useState(false);
    final bodyController =
        useTextEditingController(text: content ?? privateMessage?.content);
    final loading = useState(false);

    final isEdit = privateMessage != null;

    final submit = isEdit ? 'save' : 'send';
    final title = isEdit ? 'Edit message' : 'Send message';

    handleSubmit() async {
      if (isEdit) {
        loading.value = true;
        try {
          final msg = await LemmyApiV2(instanceHost).run(EditPrivateMessage(
            auth: token?.raw ?? accStore.tokenFor(instanceHost, username).raw,
            privateMessageId: privateMessage.id,
            content: bodyController.text,
          ));
          Navigator.of(context).pop(msg);

          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
        }
        loading.value = false;
      } else {
        loading.value = true;
        try {
          await LemmyApiV2(instanceHost).run(CreatePrivateMessage(
            auth: token?.raw ?? accStore.tokenFor(instanceHost, username)?.raw,
            content: bodyController.text,
            recipientId: recipient.id,
          ));
          Navigator.of(context).pop();
          // TODO: maybe send notification so that infinite list
          //       containing this widget adds new message?
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
        } finally {
          loading.value = false;
        }
      }
    }

    final body = IndexedStack(
      index: showFancy.value ? 1 : 0,
      children: [
        TextField(
          controller: bodyController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 5,
          autofocus: true,
          // decoration: const InputDecoration(labelText: 'Body'),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: MarkdownText(
            bodyController.text,
            instanceHost: instanceHost,
          ),
        ),
      ],
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        leading: const CloseButton(),
        actions: [
          IconButton(
            icon: showFancy.value
                ? const Icon(Icons.build)
                : Transform.rotate(
                    angle: pi / 2,
                    child: const Icon(Icons.brush),
                  ),
            onPressed: () => showFancy.value = !showFancy.value,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text('to ${recipient.displayName}'),
            const SizedBox(height: 16),
            body,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: loading.value ? () {} : handleSubmit,
                  child: loading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator())
                      : Text(submit),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
