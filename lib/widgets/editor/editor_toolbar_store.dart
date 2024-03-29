import 'package:lemmy_api_client/pictrs.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';

import '../../util/async_store.dart';
import '../../util/pictrs.dart';

part 'editor_toolbar_store.g.dart';

class EditorToolbarStore = _EditorToolbarStore with _$EditorToolbarStore;

abstract class _EditorToolbarStore with Store {
  final String instanceHost;

  _EditorToolbarStore(this.instanceHost);

  @observable
  String? url;

  final imageUploadState = AsyncStore<PictrsUploadFile>();

  @computed
  bool get hasUploadedImage => imageUploadState.map(
        loading: () => false,
        error: (_) => false,
        data: (_) => true,
      );

  @action
  Future<String?> uploadImage(String filePath, Jwt token) async {
    final instanceHost = this.instanceHost;

    final upload = await imageUploadState.run(
      () => PictrsApi(instanceHost)
          .upload(
            filePath: filePath,
            auth: token.raw,
          )
          .then((value) => value.files.single),
    );

    if (upload != null) {
      final url = pathToPictrs(instanceHost, upload.file);
      return url;
    }
    return null;
  }

  @action
  void removeImage() {
    final pictrsFile = imageUploadState.map<PictrsUploadFile?>(
      data: (data) => data,
      loading: () => null,
      error: (_) => null,
    );
    if (pictrsFile == null) return;

    PictrsApi(instanceHost).delete(pictrsFile).catchError((_) {});

    imageUploadState.reset();
    url = '';
  }
}
