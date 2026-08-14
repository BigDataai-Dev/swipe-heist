import 'heist_run_summary.dart';

class RunFeedbackPlan {
  const RunFeedbackPlan({
    required this.headlineDelay,
    required this.starRevealDelay,
    required this.ctaDelay,
    required this.emphasis,
  });

  final Duration headlineDelay;
  final Duration starRevealDelay;
  final Duration ctaDelay;
  final RunFeedbackEmphasis emphasis;

  factory RunFeedbackPlan.forSummary(HeistRunSummary summary) {
    final emphasis = summary.mastered
        ? RunFeedbackEmphasis.mastered
        : summary.newBest
            ? RunFeedbackEmphasis.newBest
            : RunFeedbackEmphasis.standard;

    return RunFeedbackPlan(
      headlineDelay: const Duration(milliseconds: 120),
      starRevealDelay: const Duration(milliseconds: 260),
      ctaDelay: Duration(milliseconds: emphasis == RunFeedbackEmphasis.mastered ? 620 : 480),
      emphasis: emphasis,
    );
  }
}

enum RunFeedbackEmphasis { standard, newBest, mastered }
