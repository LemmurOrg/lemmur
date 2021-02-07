import 'package:flutter/material.dart';

/// Should be spawned with a [showBottomModal], not routed to.
class BottomModal extends StatelessWidget {
  final Widget child;
  final String title;

  const BottomModal({@required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 0.2,
                ),
              ),
              child: Material(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Padding(
                  padding: title != null
                      ? const EdgeInsets.only(top: 10)
                      : EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 70),
                          child: Text(
                            title,
                            style: theme.textTheme.subtitle2,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const Divider(
                          indent: 20,
                          endIndent: 20,
                        )
                      ],
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function for showing a [BottomModal]
Future<T> showBottomModal<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  String title,
}) =>
    showModalBottomSheet<T>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => BottomModal(
        title: title,
        child: builder(context),
      ),
    );
