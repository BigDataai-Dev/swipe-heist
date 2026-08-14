import 'game_progress.dart';
import 'puzzle_level.dart';

class CampaignProgressSummary {
  const CampaignProgressSummary({
    required this.clearedLevels,
    required this.masteredLevels,
    required this.totalStars,
    required this.maxStars,
  });

  final int clearedLevels;
  final int masteredLevels;
  final int totalStars;
  final int maxStars;

  double get completionRate =>
      maxStars == 0 ? 0 : clearedLevels / (maxStars / 3);

  double get masteryRate =>
      clearedLevels == 0 ? 0 : masteredLevels / clearedLevels;

  String get headline {
    if (clearedLevels == 0) return 'First job waiting';
    if (totalStars == maxStars) return 'Perfect crew';
    if (masteryRate >= 0.75) return 'Campaign mastered';
    if (completionRate >= 1) return 'Campaign cleared';
    return 'Heist in progress';
  }

  factory CampaignProgressSummary.from({
    required GameProgress progress,
    required List<PuzzleLevel> levels,
  }) {
    var cleared = 0;
    var mastered = 0;
    var stars = 0;
    for (final level in levels) {
      final best = progress.starsFor(level.id).clamp(0, 3);
      stars += best;
      if (best > 0) cleared += 1;
      if (best == 3) mastered += 1;
    }
    return CampaignProgressSummary(
      clearedLevels: cleared,
      masteredLevels: mastered,
      totalStars: stars,
      maxStars: levels.length * 3,
    );
  }
}
