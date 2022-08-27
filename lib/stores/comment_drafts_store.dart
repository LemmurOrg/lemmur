import 'package:hive/hive.dart';

class CommentDraftStore {
  static const _boxKey = 'comment_drafts';

  static Future<String?> loadDraft(String apId) async {
    final box = await Hive.openBox<String>(_boxKey);
    final text = box.get(apId);
    await box.close();
    return text;
  }

  static Future<void> saveDraft(String apId, String text) async {
    final box = await Hive.openBox<String>(_boxKey);
    await box.put(apId, text);
    await box.close();
  }

  static Future<void> removeDraft(String apId) async {
    final box = await Hive.openBox<String>(_boxKey);
    await box.delete(apId);
    await box.close();
  }
}
