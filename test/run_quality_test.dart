import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/heist_run_summary.dart';
import 'package:swipe_heist/src/run_quality.dart';

void main() {
  test('classifies a first-time mastered fast run', () {
    const summary = HeistRunSummary(
      levelId: 'gallery',
      moves: 8,
      parMoves: 8,
      stars: 3,
      bestStarsBeforeRun: 2,
    );

    final quality = RunQuality.evaluate(summary: summary, durationMs: 9000);

    expect(quality.pace, RunPace.fast);
    expect(quality.efficient, isTrue);
    expect(quality.mastered, isTrue);
    expect(quality.firstTimeMastery, isTrue);
  });

  test('classifies a slow inefficient completion', () {
    const summary = HeistRunSummary(
      levelId: 'vault',
      moves: 18,
      parMoves: 10,
      stars: 1,
      bestStarsBeforeRun: 1,
    );

    final quality = RunQuality.evaluate(summary: summary, durationMs: 60000);

    expect(quality.pace, RunPace.slow);
    expect(quality.efficient, isFalse);
    expect(quality.mastered, isFalse);
    expect(quality.firstTimeMastery, isFalse);
  });
}
