import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'tutorial_progress.dart';

class TutorialStore {
  static const _key = 'swipe_heist_tutorial_progress_v1';

  Future<TutorialProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return TutorialProgress();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return TutorialProgress();
      return TutorialProgress.fromJson(Map<String, Object?>.from(decoded));
    } catch (_) {
      return TutorialProgress();
    }
  }

  Future<void> save(TutorialProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(progress.toJson()));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
