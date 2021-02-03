import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:photo_view/photo_view.dart';

import '../widgets/bottom_modal.dart';

/// View to interact with a media object. Zoom in/out, download, share, etc.
class MediaViewPage extends HookWidget {
  final String url;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  MediaViewPage(this.url);

  @override
  Widget build(BuildContext context) {
    final showButtons = useState(true);
    final isZoomedOut = useState(true);

    final isDragging = useState(false);
    final initialPositionY = useState<double>(0);
    final positionYDelta = useState<double>(0);
    const disposeLimit = 150;

    notImplemented() {
      _key.currentState.showSnackBar(const SnackBar(
          content: Text("this feature hasn't been implemented yet 😰")));
    }

    useEffect(() {
      if (showButtons.value) {
        SystemChrome.setEnabledSystemUIOverlays([
          SystemUiOverlay.bottom,
          SystemUiOverlay.top,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIOverlays([]);
      }
      return null;
    }, [showButtons.value]);

    useEffect(
        () => () => SystemChrome.setEnabledSystemUIOverlays([
              SystemUiOverlay.bottom,
              SystemUiOverlay.top,
            ]),
        []);

    share() {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => BottomModal(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Share link'),
                onTap: () {
                  Navigator.of(context).pop();
                  Share.text('Share image url', url, 'text/plain');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Share file'),
                onTap: () {
                  Navigator.of(context).pop();
                  notImplemented();
                  // TODO: share file
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _key,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.black,
      appBar: showButtons.value
          ? AppBar(
              backgroundColor: Colors.black38,
              shadowColor: Colors.transparent,
              leading: const CloseButton(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'share',
                  onPressed: share,
                ),
                IconButton(
                  icon: const Icon(Icons.file_download),
                  tooltip: 'download',
                  onPressed: notImplemented,
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTapUp: (details) => showButtons.value = !showButtons.value,
        onVerticalDragStart: (details) {
          if (!isZoomedOut.value) return;
          isDragging.value = true;
          initialPositionY.value = details.globalPosition.dy;
        },
        onVerticalDragUpdate: (details) {
          if (!isZoomedOut.value) return;
          // currentPositionY.value = details.globalPosition.dy;
          positionYDelta.value =
              details.globalPosition.dy - initialPositionY.value;
        },
        onVerticalDragEnd: isZoomedOut.value
            ? (details) {
                if (!isZoomedOut.value) return;
                isDragging.value = false;
                if (details.primaryVelocity.abs() > 1000) {
                  Navigator.of(context).pop();
                } else if (positionYDelta.value > disposeLimit ||
                    positionYDelta.value < -disposeLimit) {
                  Navigator.of(context).pop();
                } else {
                  positionYDelta.value = 0;
                }
              }
            : null,
        child: Stack(children: [
          AnimatedPositioned(
            duration: isDragging.value
                ? Duration.zero
                : const Duration(milliseconds: 100),
            top: 0 + positionYDelta.value,
            bottom: 0 - positionYDelta.value,
            left: 0,
            right: 0,
            child: PhotoView(
              scaleStateChangedCallback: (value) {
                isZoomedOut.value = value == PhotoViewScaleState.zoomedOut ||
                    value == PhotoViewScaleState.initial;
              },
              minScale: PhotoViewComputedScale.contained,
              initialScale: PhotoViewComputedScale.contained,
              imageProvider: CachedNetworkImageProvider(url),
              heroAttributes: PhotoViewHeroAttributes(tag: url),
              loadingBuilder: (context, event) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          ),
        ]),
      ),
    );
  }
}
