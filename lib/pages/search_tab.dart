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
    final searchInputController = useListenable(useTextEditingController());

    final accStore = useAccountsStore();
    // null if there are no added instances
    final instanceHost = useState(
      accStore.instances.firstWhere((_) => true, orElse: () => null),
    );

    if (instanceHost.value == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('You do not have any instances added'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(),
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
              children: [
                Expanded(
                  child: Text('instance:',
                      style: Theme.of(context).textTheme.subtitle1),
                ),
                Expanded(
                  child: SelectInstanceButton(
                    instanceHost: instanceHost.value,
                    onChange: (s) => instanceHost.value = s,
                  ),
                ),
              ],
            ),
            if (searchInputController.text.isNotEmpty)
              ElevatedButton(
                onPressed: () => goTo(
                    context,
                    (c) => SearchResultsPage(
                          instanceHost: instanceHost.value,
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
  final ValueChanged<String> onChange;
  final String instanceHost;
  const SelectInstanceButton(
      {@required this.onChange, @required this.instanceHost})
      : assert(instanceHost != null);

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
                    leading: inst == instanceHost
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
          ),
        );

        if (val != null) {
          onChange?.call(val);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(instanceHost),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
