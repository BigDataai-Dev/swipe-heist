import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  GameProgress({required this.unlockedLevelIndex, Map<String, int>? bestStars})
      : bestStars = Map<String, int>.from(bestStars ?? const {});

  int unlockedLevelIndex;
  final Map<String, int> bestStars;

  int starsFor(String levelId) => bestStars[levelId] ?? 0;

  void recordCompletion({
    required String levelId,
    required int levelIndex,
    required int stars,
  }) {
    final currentBest = starsFor(levelId);
    if (stars > currentBest) bestStars[levelId] = stars;
    if (levelIndex + 1 > unlockedLevelIndex) {
      unlockedLevelIndex = levelIndex + 1;
    }
  }
}

class GameProgressStore {
  static const _unlockedKey = 'campaign.unlocked_level_index';
  static const _starsPrefix = 'campaign.stars.';

  Future<GameProgress> load(List<String> levelIds) async {
    final prefs = await SharedPreferences.getInstance();
    final bestStars = <String, int>{};
    for (final id in levelIds) {
      bestStars[id] = prefs.getInt('$_starsPrefix$id') ?? 0;
    }
    return GameProgress(
      unlockedLevelIndex: prefs.getInt(_unlockedKey) ?? 0,
      bestStars: bestStars,
    );
  }

  Future<void> save(GameProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unlockedKey, progress.unlockedLevelIndex);
    for (final entry in progress.bestStars.entries) {
      await prefs.setInt('$_starsPrefix${entry.key}', entry.value);
    }
  }
}
