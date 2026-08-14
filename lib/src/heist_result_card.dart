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
    final stars = List.filled(widget.summary.stars, '★').join();
    final mastered = plan.emphasis == RunFeedbackEmphasis.mastered;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedOpacity(
              opacity: showHeadline ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.summary.headline,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${widget.summary.moves} moves · par ${widget.summary.parMoves}'),
                      ],
                    ),
                  ),
                  if (mastered)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.local_fire_department_rounded),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            AnimatedScale(
              scale: showStars ? 1 : 0.72,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: showStars ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: Text(
                  stars,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            if (widget.summary.isNewBest) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.emoji_events_rounded, size: 18),
                  SizedBox(width: 7),
                  Text('New best'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(widget.summary.recommendation),
            const SizedBox(height: 16),
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
