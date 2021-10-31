import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extensions/brightness.dart';
import '../communities_tab.dart';
import '../create_post.dart';
import '../home_tab.dart';
import '../profile_tab.dart';
import '../search_tab.dart';

enum AppTab {
  home,
  communities,
  search,
  profile,
}

class MainPage extends HookWidget {
  const MainPage();

  static const tabs = {
    AppTab.home: HomeTab(),
    AppTab.communities: CommunitiesTab(),
    AppTab.search: SearchTab(),
    AppTab.profile: UserProfileTab(),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = useState(AppTab.home);

    useEffect(() {
      Future.microtask(
        () => SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: theme.brightness.reverse,
        )),
      );

      return null;
    }, [theme.scaffoldBackgroundColor]);

    tabButton(AppTab tab) {
      return IconButton(
        icon: Icon(tab.icon),
        color: tab == current.value ? theme.colorScheme.secondary : null,
        onPressed: () => current.value = tab,
      );
    }

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: tabs.keys.toList().indexOf(current.value),
              children: tabs.values.toList(),
            ),
          ),
          const SizedBox(height: kMinInteractiveDimension / 2),
        ],
      ),
      floatingActionButton: const CreatePostFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              tabButton(AppTab.home),
              tabButton(AppTab.communities),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              tabButton(AppTab.search),
              tabButton(AppTab.profile),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AppTab {
  IconData get icon {
    switch (this) {
      case AppTab.home:
        return Icons.home;
      case AppTab.communities:
        return Icons.list;
      case AppTab.search:
        return Icons.search;
      case AppTab.profile:
        return Icons.person;
    }
  }
}
