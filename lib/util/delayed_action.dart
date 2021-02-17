import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v2.dart';

import '../hooks/delayed_loading.dart';

rq<T>(T sth) {
  assert(sth != null, 'required argument');
}

Future<void> delayedAction<T>({
  @required BuildContext context,
  @required DelayedLoading del,
  @required String instanceHost,
  @required LemmyApiQuery<T> query,
  Function(T) onSuccess,
  Function(T) onFailure,
  Function(T) cleanup,
}) async {
  rq(del);
  rq(instanceHost);
  rq(query);
  rq(context);

  T val;
  try {
    del.start();
    val = await LemmyApiV2(instanceHost).run<T>(query);
    if (onSuccess != null) onSuccess(val);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    if (onFailure != null) onFailure(val);
  }
  if (cleanup != null) cleanup(val);
  del.cancel();
}
