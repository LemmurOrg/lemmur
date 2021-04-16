import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'accounts_store.dart';

part 'lemmy_settings_store.g.dart';

/// Store caching user settings set with `SaveUserSettings` in the lemmy API
@JsonSerializable()
class LemmySettingsStore extends ChangeNotifier {
  static const prefsKey = 'v5:UserSettingsStore';
  static final _prefs = SharedPreferences.getInstance();
  static final defaultUserSettings = LocalUserSettings(
    id: -1,
    personId: -1,
    showNsfw: false,
    theme: 'browser',
    defaultSortType: SortType.active,
    defaultListingType: PostListingType.all,
    lang: 'en',
    showAvatars: true,
    sendNotificationsToEmail: false,
  )..instanceHost = '';

  @JsonKey(ignore: true)
  late final AccountsStore _accountsStore;

  /// Map containing lemmy user settings of specific users.
  /// It is assumed to be always filled with users from [AccountsStore] logged in users
  /// When the `LocalUserSettings.id` field is -1, it means these are not the actual user settings
  /// but just defaults filled in
  /// `userSettings['instanceHost']['username']`
  @protected
  @JsonKey(defaultValue: {})
  late Map<String, Map<String, LocalUserSettings>> userSettings;

  void init() {
    _accountsStore.addListener(_syncChanges);

    _syncChanges();

    // TODO: decide whether we want to refresh all settings upon app restart
    // initial try refresh on all accounts
    // for (final instanceHost in _accountsStore.loggedInInstances) {
    //   for (final username in _accountsStore.usernamesFor(instanceHost)) {
    //     tryRefresh(instanceHost, username);
    //   }
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _accountsStore.removeListener(_syncChanges);
  }

  /// filling all fields of userSettings with some default settings
  /// It will also do a [tryRefresh] on accounts that have a new default assigned
  /// it will also remove all accounts that are no longer in the AccountsStore
  void _syncChanges() {
    for (final instanceHost in _accountsStore.loggedInInstances) {
      if (!userSettings.containsKey(instanceHost)) {
        userSettings[instanceHost] = {};
      }

      for (final username in _accountsStore.usernamesFor(instanceHost)) {
        if (userSettings[instanceHost]![username] == null) {
          userSettings[instanceHost]![username] = defaultUserSettings;
          tryRefresh(instanceHost, username);
        }
      }
    }

    // remove old instances
    userSettings.keys
        .where((e) => !_accountsStore.loggedInInstances.contains(e))
        .toList()
        .forEach(userSettings.remove);

    // remove old accounts
    for (final instanceHost in _accountsStore.loggedInInstances) {
      for (final username in userSettings[instanceHost]!.keys) {
        if (!_accountsStore.usernamesFor(instanceHost).contains(username)) {
          userSettings[instanceHost]!.remove(username);
        }
      }
    }

    notifyListeners();
    save();
  }

  /// tries to refresh user settings, if fails it will silently ignore the error and keep old data
  /// returns a bool to indicate success
  Future<bool> tryRefresh(String instanceHost, String username) async {
    final userData = _accountsStore.userDataFor(instanceHost, username);
    if (userData == null) throw ArgumentError('This user is not logged in');

    try {
      final myUser = await LemmyApiV3(instanceHost)
          .run(GetSite(auth: userData.jwt.raw))
          .then((value) => value.myUser!);

      userSettings[instanceHost]![username] = myUser.localUser;

      notifyListeners();
      await save();
    } on SocketException {
      return false;
    }

    return true;
  }

  LocalUserSettings? userSettingsFor(String instanceHost, String username) =>
      userSettings[instanceHost]?[username];

  static Future<LemmySettingsStore> load(AccountsStore accountsStore) async {
    final prefs = await _prefs;

    final a = _$LemmySettingsStoreFromJson(
      jsonDecode(prefs.getString(prefsKey) ?? '{}') as Map<String, dynamic>,
    )
      .._accountsStore = accountsStore
      ..init();
    return a;
  }

  Future<void> save() async {
    final prefs = await _prefs;
    final a = _$LemmySettingsStoreToJson(this);
    final b = jsonEncode(a);

    await prefs.setString(prefsKey, b);
  }
}
