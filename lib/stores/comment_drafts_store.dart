import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

class CommentDraftStore {
  static const _boxKey = 'comment_drafts';
  static late LazyBox<String> _box;

  static Future<void> open() async {
    _box = await Hive.openLazyBox<String>(_boxKey);
  }

  static Future<void> close() async {
    await _box.compact();
    await _box.close();
  }

  static Future<void> compact() async {
    await _box.compact();
  }

  static String? keyAt(int index) => _box.keyAt(index);

  static ValueListenable<LazyBox<String>> allDraftsListenable() =>
      _box.listenable();

  static Future<String?> loadDraft(String apId) => _box.get(apId);

  static Future<void> saveDraft(String apId, String text) =>
      _box.put(apId, text);

  static Future<void> removeDraft(String apId) => _box.delete(apId);

  static Future<void> removeAllDrafts() async {
    await _box.deleteFromDisk();
    await open();
  }
}
