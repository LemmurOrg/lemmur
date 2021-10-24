import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';

part 'config_store.g.dart';

/// Store managing user-level configuration such as theme or language
@JsonSerializable()
@LocaleConverter()
class ConfigStore extends _ConfigStore with _$ConfigStore {
  static Future<ConfigStore> load() async {
    final prefs = await _ConfigStore._sharedPrefs;

    return _$ConfigStoreFromJson(
      jsonDecode(prefs.getString(_ConfigStore._prefsKey) ?? '{}')
          as Map<String, dynamic>,
    );
  }
}

abstract class _ConfigStore with Store {
  static const _prefsKey = 'v1:ConfigStore';
  static final _sharedPrefs = SharedPreferences.getInstance();

  late final ReactionDisposer _saveDisposer;

  _ConfigStore() {
    _saveDisposer = reaction(
      (_) => [
        theme,
        amoledDarkMode,
        locale,
        showAvatars,
        showScores,
        defaultSortType,
        defaultListingType,
      ],
      (_) => save(),
    );
  }

  @observable
  @JsonKey(defaultValue: ThemeMode.system)
  ThemeMode theme = ThemeMode.system;

  @observable
  @JsonKey(defaultValue: false)
  bool amoledDarkMode = false;

  // default value is set in the `LocaleConverter.fromJson`
  @observable
  Locale locale = const Locale('en');

  @observable
  @JsonKey(defaultValue: true)
  bool showAvatars = true;

  @observable
  @JsonKey(defaultValue: true)
  bool showScores = true;

  // default is set in fromJson
  @observable
  @JsonKey(fromJson: _sortTypeFromJson)
  SortType defaultSortType = SortType.hot;

  // default is set in fromJson
  @observable
  @JsonKey(fromJson: _postListingTypeFromJson)
  PostListingType defaultListingType = PostListingType.all;

  /// Copies over settings from lemmy to [ConfigStore]
  @action
  void copyLemmyUserSettings(LocalUserSettings localUserSettings) {
    // themes from lemmy-ui that are dark mode
    const darkModeLemmyUiThemes = {
      'solar',
      'cyborg',
      'darkly',
      'vaporwave-dark',
      'i386',
    };

    showAvatars = localUserSettings.showAvatars;
    theme = () {
      if (localUserSettings.theme == 'browser') return ThemeMode.system;

      if (darkModeLemmyUiThemes.contains(localUserSettings.theme)) {
        return ThemeMode.dark;
      }

      return ThemeMode.light;
    }();

    if (L10n.supportedLocales.contains(Locale(localUserSettings.lang))) {
      locale = Locale(localUserSettings.lang);
    }

    showScores = localUserSettings.showScores;
    defaultSortType = localUserSettings.defaultSortType;
    defaultListingType = localUserSettings.defaultListingType;
  }

  /// Fetches [LocalUserSettings] and imports them with [.copyLemmyUserSettings]
  Future<void> importLemmyUserSettings(Jwt token) async {
    final site =
        await LemmyApiV3(token.payload.iss).run(GetSite(auth: token.raw));
    copyLemmyUserSettings(site.myUser!.localUserView.localUser);
  }

  Future<void> save() async {
    final prefs = await _sharedPrefs;

    await prefs.setString(
      _prefsKey,
      jsonEncode(_$ConfigStoreToJson(this as ConfigStore)),
    );
  }

  void dispose() {
    _saveDisposer();
  }
}

SortType _sortTypeFromJson(String? json) =>
    json != null ? SortType.fromJson(json) : SortType.hot;
PostListingType _postListingTypeFromJson(String? json) =>
    json != null ? PostListingType.fromJson(json) : PostListingType.all;
