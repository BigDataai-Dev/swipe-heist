import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/heist_run_summary.dart';
import 'package:swipe_heist/src/puzzle_level.dart';

void main() {
  test('perfect run is marked mastered and new best', () {
    final level = demoLevels.first;
    final summary = HeistRunSummary.fromLevel(
      level: level,
      moves: level.parMoves,
      bestStarsBeforeRun: 2,
    );

    expect(summary.stars, 3);
    expect(summary.mastered, isTrue);
    expect(summary.isNewBest, isTrue);
    expect(summary.headline, 'Perfect getaway');
  });

  test('two star run recommends replay', () {
    final level = demoLevels.first;
    final summary = HeistRunSummary.fromLevel(
      level: level,
      moves: level.parMoves + 1,
      bestStarsBeforeRun: 3,
    );

    expect(summary.stars, 2);
    expect(summary.mastered, isFalse);
    expect(summary.isNewBest, isFalse);
    expect(summary.recommendation, contains('Replay'));
  });
}
