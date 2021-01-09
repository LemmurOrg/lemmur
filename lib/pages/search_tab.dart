import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../hooks/stores.dart';
import '../util/goto.dart';
import '../widgets/bottom_modal.dart';
import 'search_results.dart';

class SearchTab extends HookWidget {
  const SearchTab();

  @override
  Widget build(BuildContext context) {
    final searchInputController = useTextEditingController();

    final accStore = useAccountsStore();
    final instance = useState(accStore.instances.first);
    useValueListenable(searchInputController);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTapDown: (_) => primaryFocus.unfocus(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            TextField(
              controller: searchInputController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                fillColor: Colors.grey,
                isDense: true,
                // border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: 'search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text('instance:',
                      style: Theme.of(context).textTheme.subtitle1),
                ),
                Expanded(
                  child: SelectInstanceButton(
                    instance: instance.value,
                    onChange: (s) => instance.value = s,
                  ),
                ),
              ],
            ),
            if (searchInputController.text.isNotEmpty)
              ElevatedButton(
                onPressed: () => goTo(
                    context,
                    (c) => SearchResultsPage(
                          instance: instance.value,
                          query: searchInputController.text,
                        )),
                child: const Text('search'),
              )
          ],
        ),
      ),
    );
  }
}

class SelectInstanceButton extends HookWidget {
  final void Function(String) onChange;
  final String instance;
  const SelectInstanceButton(
      {@required this.onChange, @required this.instance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accStore = useAccountsStore();
    return OutlinedButton(
      onPressed: () async {
        final val = await showModalBottomSheet<String>(
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            context: context,
            builder: (context) => BottomModal(
                  child: Column(
                    children: [
                      for (final inst in accStore.instances)
                        ListTile(
                          leading: inst == instance
                              ? Icon(
                                  Icons.radio_button_on,
                                  color: theme.accentColor,
                                )
                              : const Icon(Icons.radio_button_off),
                          title: Text(inst),
                          onTap: () => Navigator.of(context).pop(inst),
                        )
                    ],
                  ),
                ));
        if (val != null) {
          onChange?.call(val);
        }
      },
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        primary: theme.textTheme.bodyText1.color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(instance),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}