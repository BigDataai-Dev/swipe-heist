import 'package:flutter/material.dart';

import 'heist_run_summary.dart';
import 'run_feedback_plan.dart';

class HeistResultCard extends StatefulWidget {
  const HeistResultCard({
    super.key,
    required this.summary,
    required this.onReplay,
    this.onNext,
  });

  final HeistRunSummary summary;
  final VoidCallback onReplay;
  final VoidCallback? onNext;

  @override
  State<HeistResultCard> createState() => _HeistResultCardState();
}

class _HeistResultCardState extends State<HeistResultCard> {
  late final RunFeedbackPlan plan;
  bool showHeadline = false;
  bool showStars = false;
  bool showCtas = false;

  @override
  void initState() {
    super.initState();
    plan = RunFeedbackPlan.forSummary(widget.summary);
    _reveal();
  }

  Future<void> _reveal() async {
    await Future<void>.delayed(plan.headlineDelay);
    if (!mounted) return;
    setState(() => showHeadline = true);

    await Future<void>.delayed(plan.starRevealDelay - plan.headlineDelay);
    if (!mounted) return;
    setState(() => showStars = true);

    await Future<void>.delayed(plan.ctaDelay - plan.starRevealDelay);
    if (!mounted) return;
    setState(() => showCtas = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mastered = plan.emphasis == RunFeedbackEmphasis.mastered;
    final delta = widget.summary.moves - widget.summary.parMoves;
    final paceLabel = delta <= 0 ? 'ON PAR' : '+$delta MOVES';

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: mastered
                ? [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.tertiaryContainer,
                  ]
                : [
                    theme.colorScheme.surfaceContainerHigh,
                    theme.colorScheme.surfaceContainer,
                  ],
          ),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSlide(
              offset: showHeadline ? Offset.zero : const Offset(0, 0.12),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: showHeadline ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mastered ? 'CLEAN GETAWAY' : 'JOB COMPLETE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.summary.headline,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        paceLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            AnimatedScale(
              scale: showStars ? 1 : 0.72,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: showStars ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final earned = index < widget.summary.stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        earned ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 42,
                        color: earned
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.summary.moves} moves',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9),
                  child: Text('·'),
                ),
                Text('par ${widget.summary.parMoves}'),
              ],
            ),
            if (widget.summary.isNewBest) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 19),
                    SizedBox(width: 7),
                    Text('NEW PERSONAL BEST'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              widget.summary.recommendation,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
            ),
            const SizedBox(height: 18),
            AnimatedOpacity(
              opacity: showCtas ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !showCtas,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onReplay,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Replay'),
                      ),
                    ),
                    if (widget.onNext != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: widget.onNext,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next job'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
