// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lemmy_settings_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LemmySettingsStore _$LemmySettingsStoreFromJson(Map<String, dynamic> json) {
  return LemmySettingsStore()
    ..userSettings = (json['userSettings'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(
              k,
              (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    k, LocalUserSettings.fromJson(e as Map<String, dynamic>)),
              )),
        ) ??
        {};
}

Map<String, dynamic> _$LemmySettingsStoreToJson(LemmySettingsStore instance) =>
    <String, dynamic>{
      'userSettings': instance.userSettings,
    };
