import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/campaign_progress_summary.dart';
import 'package:swipe_heist/src/game_progress.dart';
import 'package:swipe_heist/src/puzzle_level.dart';

void main() {
  test('summarizes cleared and mastered campaign levels', () {
    final progress = GameProgress(
      unlockedLevelIndex: 2,
      bestStars: {
        demoLevels[0].id: 3,
        demoLevels[1].id: 2,
      },
    );

    final summary = CampaignProgressSummary.from(
      progress: progress,
      levels: demoLevels,
    );

    expect(summary.clearedLevels, 2);
    expect(summary.masteredLevels, 1);
    expect(summary.totalStars, 5);
    expect(summary.maxStars, demoLevels.length * 3);
    expect(summary.headline, 'Heist in progress');
  });

  test('recognizes a perfect campaign', () {
    final progress = GameProgress(
      unlockedLevelIndex: demoLevels.length - 1,
      bestStars: {for (final level in demoLevels) level.id: 3},
    );

    final summary = CampaignProgressSummary.from(
      progress: progress,
      levels: demoLevels,
    );

    expect(summary.headline, 'Perfect crew');
    expect(summary.completionRate, 1);
    expect(summary.masteryRate, 1);
  });
}
