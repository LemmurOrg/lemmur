import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/unawaited.dart';
import 'accounts_store.dart';

part 'user_settings_store.g.dart';

/// Store caching user settings set with `SaveUserSettings` in the lemmy API
@JsonSerializable()
class UserSettingsStore extends ChangeNotifier {
  static const prefsKey = 'v1:UserSettingsStore';
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
  );

  final AccountsStore _accountsStore;

  /// Map containing lemmy user seetings of specific users.
  /// It is assumed to be always filled with users from [AccountsStore] logged in users
  /// When the `LocalUserSettings.id` field is -1, it means these are not the actual user settings
  /// but just defaults filled in
  /// `userSettings['instanceHost']['username']`
  @protected
  @JsonKey(defaultValue: {})
  Map<String, Map<String, LocalUserSettings>> userSettings;

  UserSettingsStore(this._accountsStore) {
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
  Future<void> _syncChanges() async {
    for (final instanceHost in _accountsStore.loggedInInstances) {
      if (!userSettings.containsKey(instanceHost)) {
        userSettings[instanceHost] = {};
      }

      for (final username in _accountsStore.usernamesFor(instanceHost)) {
        if (userSettings[instanceHost][username] == null) {
          userSettings[instanceHost][username] = defaultUserSettings;
          unawaited(tryRefresh(instanceHost, username));
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
      for (final username in userSettings[instanceHost].keys) {
        if (!_accountsStore.usernamesFor(instanceHost).contains(username)) {
          userSettings[instanceHost].remove(username);
        }
      }
    }

    notifyListeners();
    await save();
  }

  /// tries to refresh user settings, if fails it will silently ignore the error and keep old data
  /// returns a bool to indicate success
  Future<bool> tryRefresh(String instanceHost, String username) async {
    try {
      final userData = await LemmyApiV3(instanceHost)
          .run(
            GetSite(auth: _accountsStore.tokenFor(instanceHost, username).raw),
          )
          .then((value) => value.myUser);

      userSettings[instanceHost][username] = userData.localUser;

      notifyListeners();
      await save();
    } on SocketException {
      return false;
    }

    return true;
  }

  LocalUserSettings userSettingsFor(String instanceHost, String username) =>
      userSettings[instanceHost][username];

  static Future<UserSettingsStore> load() async {
    final prefs = await _prefs;

    return _$UserSettingsStoreFromJson(
      jsonDecode(prefs.getString(prefsKey) ?? '{}') as Map<String, dynamic>,
    );
  }

  Future<void> save() async {
    final prefs = await _prefs;

    await prefs.setString(
        prefsKey, jsonEncode(_$UserSettingsStoreToJson(this)));
  }
}
