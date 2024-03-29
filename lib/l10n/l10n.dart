import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:timeago/timeago.dart';

export 'gen/l10n.dart';
export 'l10n_api.dart';
export 'l10n_from_string.dart';

class LocaleConverter implements JsonConverter<Locale, String?> {
  const LocaleConverter();

  @override
  Locale fromJson(String? json) {
    if (json == null) return const Locale('en');

    final lang = json.split('-');

    return Locale(lang[0], lang.length > 1 ? lang[1] : null);
  }

  @override
  String? toJson(Locale locale) => locale.toLanguageTag();
}

const _languageNames = {
  'ca': 'Català',
  'ar': 'عربي',
  'en': 'English',
  'el': 'Ελληνικά',
  'eu': 'Euskara',
  'eo': 'Esperanto',
  'es': 'Español',
  'da': 'Dansk',
  'de': 'Deutsch',
  'ga': 'Gaeilge',
  'gl': 'Galego',
  'hr': 'hrvatski',
  'hu': 'Magyar Nyelv',
  'ka': 'ქართული ენა',
  'ko': '한국어',
  'km': 'ភាសាខ្មែរ',
  'hi': 'मानक हिन्दी',
  'fa': 'فارسی',
  'ja': '日本語',
  'oc': 'Occitan',
  'pl': 'Polski',
  'pt': 'Português',
  'pt-BR': 'Português Brasileiro',
  'zh': '中文',
  'fi': 'Suomi',
  'fr': 'Français',
  'sv': 'Svenska',
  'sq': 'Shqip',
  'sr-Latn': 'srpski',
  'th': 'ภาษาไทย',
  'tr': 'Türkçe',
  'uk': 'Українська Mова',
  'ru': 'Русский',
  'nl': 'Nederlands',
  'it': 'Italiano',
  'sr': 'Српски',
  'zh-Hant': '繁體中文',
  'nb': 'Norwegian',
  'nb-NO': 'Norwegian Bokmål',
  'bg': 'български',
  'cs': 'čeština',
  'cy': 'Cymraeg',
  'id': 'Bahasa Indonesia',
  'ml': 'മലയാളം',
  'sk': 'slovenčina',
  'vi': 'Tiếng Việt',
  'bn': 'বাংলা',
  'mnc': 'Manchu',
};

extension LanguageName on Locale {
  /// returns the name of the language in the given language
  String get languageName => _languageNames[toLanguageTag()] ?? toLanguageTag();
}

extension TimeagoTime on DateTime {
  /// returns `this` time as a relative, human-readable string. In short format
  String timeagoShort(BuildContext context) => format(
        this,
        locale: '${Localizations.localeOf(context).toLanguageTag()}_short',
      );

  /// returns `this` time as a relative, human-readable string
  String timeago(BuildContext context) =>
      format(this, locale: Localizations.localeOf(context).toLanguageTag());
}

extension NumberFormatExtensions on num {
  /// returns `this` as a formatted compact number
  String compact(BuildContext context) => NumberFormat.compact(
        locale: Localizations.localeOf(context).toLanguageTag(),
      ).format(this);
}
