import 'package:flutter/material.dart';

import 'heist_run_summary.dart';

class HeistResultCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stars = List.filled(summary.stars, '★').join();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.headline,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${summary.moves} moves · par ${summary.parMoves}'),
                    ],
                  ),
                ),
                Text(
                  stars,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (summary.isNewBest) ...[
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
            Text(summary.recommendation),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReplay,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Replay'),
                  ),
                ),
                if (onNext != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next job'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
