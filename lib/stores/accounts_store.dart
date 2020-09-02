import 'dart:convert';

import 'package:lemmy_api_client/lemmy_api_client.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'accounts_store.g.dart';

class AccountsStore extends _AccountsStore with _$AccountsStore {}

abstract class _AccountsStore with Store {
  ReactionDisposer _saveReactionDisposer;

  _AccountsStore() {
    // persitently save settings each time they are changed
    _saveReactionDisposer = reaction(
      (_) => [
        users.asObservable(),
        tokens.asObservable(),
        _defaultAccount,
        _defaultAccounts.asObservable(),
      ],
      (_) {
        save();
      },
    );
  }

  void dispose() {
    _saveReactionDisposer();
  }

  void load() async {
    var prefs = await SharedPreferences.getInstance();
    // set saved settings or create defaults
    // TODO: load saved users and tokens
    users = ObservableMap();
    tokens = ObservableMap();
    _defaultAccount = prefs.getString('defaultAccount');
    _defaultAccounts = ObservableMap.of(Map.castFrom(
        jsonDecode(prefs.getString('defaultAccounts') ?? 'null') ?? {}));
  }

  void save() async {
    var prefs = await SharedPreferences.getInstance();
    // TODO: save users and tokens
    await prefs.setString('defaultAccount', _defaultAccount);
    await prefs.setString('defaultAccounts', jsonEncode(_defaultAccounts));
  }

  /// if path to tokens map exists, it exists for users as well
  /// `users['instanceUrl']['username']`
  @observable
  ObservableMap<String, ObservableMap<String, User>> users;

  /// if path to users map exists, it exists for tokens as well
  /// `tokens['instanceUrl']['username']`
  @observable
  ObservableMap<String, ObservableMap<String, Jwt>> tokens;

  /// default account for a given instance
  /// map where keys are instanceUrls and values are usernames
  @observable
  ObservableMap<String, String> _defaultAccounts;

  /// default account for the app
  /// username@instanceUrl
  @observable
  String _defaultAccount;

  @computed
  User get defaultUser {
    var userTag = _defaultAccount.split('@');
    return users[userTag[1]][userTag[0]];
  }

  @computed
  Jwt get defaultToken {
    var userTag = _defaultAccount.split('@');
    return tokens[userTag[1]][userTag[0]];
  }

  User defaultUserFor(String instanceUrl) =>
      Computed(() => users[instanceUrl][_defaultAccounts[instanceUrl]]).value;

  Jwt defaultTokenFor(String instanceUrl) =>
      Computed(() => tokens[instanceUrl][_defaultAccounts[instanceUrl]]).value;

  @action
  void setDefaultAccount(String instanceUrl, String username) {
    _defaultAccount = '$username@$instanceUrl';
  }

  @action
  void setDefaultAccountFor(String instanceUrl, String username) {
    _defaultAccounts[instanceUrl] = username;
  }

  /// adds a new account
  /// if it's the first account ever the account is
  /// set as default for the app
  /// if it's the first account for an instance the account is
  /// set as default for that instance
  @action
  Future<void> addAccount(
    String instanceUrl,
    String usernameOrEmail,
    String password,
  ) async {
    var lemmy = LemmyApi(instanceUrl).v1;

    var token = await lemmy.login(
      usernameOrEmail: usernameOrEmail,
      password: password,
    );
    var userData =
        await lemmy.getSite(auth: token.raw).then((value) => value.myUser);

    if (!users.containsKey(instanceUrl)) {
      if (users.isEmpty) {
        setDefaultAccount(instanceUrl, userData.name);
      }

      users[instanceUrl] = ObservableMap();
      tokens[instanceUrl] = ObservableMap();
      setDefaultAccountFor(instanceUrl, userData.name);
    }

    users[instanceUrl][userData.name] = userData;
    tokens[instanceUrl][userData.name] = token;
  }
}