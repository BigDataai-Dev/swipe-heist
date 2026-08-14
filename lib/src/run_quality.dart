import 'heist_run_summary.dart';

enum RunPace { fast, healthy, slow }

class RunQuality {
  const RunQuality({
    required this.pace,
    required this.efficient,
    required this.mastered,
    required this.firstTimeMastery,
  });

  final RunPace pace;
  final bool efficient;
  final bool mastered;
  final bool firstTimeMastery;

  Map<String, Object> toAnalytics() => <String, Object>{
        'pace': pace.name,
        'efficient': efficient,
        'mastered': mastered,
        'first_time_mastery': firstTimeMastery,
      };

  factory RunQuality.evaluate({
    required HeistRunSummary summary,
    required int durationMs,
    int fastThresholdMs = 12000,
    int slowThresholdMs = 45000,
  }) {
    final pace = durationMs <= fastThresholdMs
        ? RunPace.fast
        : durationMs >= slowThresholdMs
            ? RunPace.slow
            : RunPace.healthy;

    return RunQuality(
      pace: pace,
      efficient: summary.moves <= summary.parMoves + 1,
      mastered: summary.mastered,
      firstTimeMastery: summary.mastered && summary.bestStarsBeforeRun < 3,
    );
  }
}
