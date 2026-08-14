import 'package:flutter/material.dart';
import 'campaign_progress_summary.dart';
import 'game_analytics.dart';
import 'game_feedback.dart';
import 'game_progress.dart';
import 'game_state.dart';
import 'grid_point.dart';
import 'heist_result_card.dart';
import 'heist_run_summary.dart';
import 'puzzle_level.dart';
import 'run_metrics.dart';
import 'run_quality.dart';
import 'swipe_input.dart';
import 'tutorial_progress.dart';
import 'tutorial_store.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  static const analytics = DebugGameAnalytics();
  static const feedback = SystemGameFeedback();
  static const inputPolicy = SwipeInputPolicy();
  final progressStore = GameProgressStore();
  final tutorialStore = TutorialStore();

  GameProgress? progress;
  TutorialProgress? tutorial;
  var levelIndex = 0;
  var bestStarsBeforeRun = 0;
  late PuzzleState state = PuzzleState(demoLevels[levelIndex]);
  RunMetrics runMetrics = RunMetrics();

  @override
  void initState() {
    super.initState();
    restoreState();
  }

  Future<void> restoreState() async {
    final loadedProgress = await progressStore.load(
      demoLevels.map((level) => level.id).toList(growable: false),
    );
    final loadedTutorial = await tutorialStore.load();
    if (!mounted) return;
    final restoredIndex = loadedProgress.unlockedLevelIndex
        .clamp(0, demoLevels.length - 1)
        .toInt();
    setState(() {
      progress = loadedProgress;
      tutorial = loadedTutorial;
      levelIndex = restoredIndex;
      state = PuzzleState(demoLevels[levelIndex]);
      bestStarsBeforeRun = loadedProgress.starsFor(state.level.id);
      runMetrics = RunMetrics();
    });
    trackLevelStart();
  }

  void trackLevelStart() {
    analytics.track('level_start', {
      'level_id': state.level.id,
      'level_index': levelIndex,
      'par_moves': state.level.parMoves,
      'best_stars': progress?.starsFor(state.level.id) ?? 0,
    });
  }

  Future<void> saveTutorial() async {
    final current = tutorial;
    if (current != null) await tutorialStore.save(current);
  }

  Future<void> recordCompletion() async {
    final current = progress;
    if (current == null) return;
    current.recordCompletion(
      levelId: state.level.id,
      levelIndex: levelIndex,
      stars: state.level.starsFor(state.moves),
    );
    await progressStore.save(current);
    if (mounted) setState(() {});
  }

  void selectLevel(int index) {
    feedback.play(GameFeedbackCue.select);
    setState(() {
      levelIndex = index;
      state = PuzzleState(demoLevels[index]);
      bestStarsBeforeRun = progress?.starsFor(state.level.id) ?? 0;
      runMetrics = RunMetrics();
    });
    trackLevelStart();
  }

  void openCampaign() {
    final current = progress!;
    final summary = CampaignProgressSummary.from(
      progress: current,
      levels: demoLevels,
    );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: demoLevels.length + 1,
          itemBuilder: (context, itemIndex) {
            if (itemIndex == 0) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.headline,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${summary.clearedLevels}/${demoLevels.length} jobs cleared · '
                      '${summary.masteredLevels} mastered · '
                      '${summary.totalStars}/${summary.maxStars} stars',
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: summary.completionRate.clamp(0, 1),
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ],
                ),
              );
            }
            final index = itemIndex - 1;
            final level = demoLevels[index];
            final unlocked = index <= current.unlockedLevelIndex;
            final best = current.starsFor(level.id);
            return ListTile(
              enabled: unlocked,
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(level.title),
              subtitle: Text(
                unlocked
                    ? 'Par ${level.parMoves} · ${best == 0 ? 'Not cleared' : List.filled(best, '★').join()}'
                    : 'Locked',
              ),
              trailing: Icon(
                unlocked ? Icons.play_arrow_rounded : Icons.lock_outline,
              ),
              onTap: unlocked
                  ? () {
                      Navigator.of(context).pop();
                      selectLevel(index);
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }

  void onSwipe(DragEndDetails details) {
    if (state.complete || state.failed || progress == null) return;

    final velocity = details.velocity.pixelsPerSecond;
    final direction = inputPolicy.classify(dx: velocity.dx, dy: velocity.dy);
    if (direction == null) return;
    final delta = inputPolicy.deltaFor(direction);

    final beforePlayer = state.player;
    final wasCollected = state.collected;
    final wasComplete = state.complete;
    final wasFailed = state.failed;
    setState(() {
      state.move(delta.rowDelta, delta.columnDelta);
    });

    if (state.player == beforePlayer) {
      feedback.play(GameFeedbackCue.blocked);
      return;
    }

    final onboarding = tutorial;
    if (onboarding != null && !onboarding.swipeShown) {
      onboarding.acknowledgeSwipe();
      saveTutorial();
    }

    if (!wasCollected && state.collected) {
      feedback.play(GameFeedbackCue.loot);
      if (onboarding != null && !onboarding.lootShown) {
        onboarding.acknowledgeLoot();
        saveTutorial();
      }
    } else {
      feedback.play(GameFeedbackCue.move);
    }

    if (!wasFailed && state.failed) {
      feedback.play(GameFeedbackCue.fail);
      analytics.track('level_fail', {
        'level_id': state.level.id,
        'moves': state.moves,
        ...runMetrics.analyticsFields(),
      });
    }
    if (!wasComplete && state.complete) {
      feedback.play(GameFeedbackCue.complete);
      if (onboarding != null && !onboarding.exitShown) {
        onboarding.acknowledgeExit();
        saveTutorial();
      }
      final stars = state.level.starsFor(state.moves);
      final summary = HeistRunSummary.fromLevel(
        level: state.level,
        moves: state.moves,
        bestStarsBeforeRun: bestStarsBeforeRun,
      );
      final quality = RunQuality.evaluate(
        summary: summary,
        durationMs: runMetrics.elapsed().inMilliseconds,
      );
      analytics.track('level_complete', {
        'level_id': state.level.id,
        'moves': state.moves,
        'par_moves': state.level.parMoves,
        'stars': stars,
        'new_best': stars > bestStarsBeforeRun,
        ...runMetrics.analyticsFields(),
        ...quality.toAnalytics(),
      });
      recordCompletion();
    }
  }

  void restartLevel() {
    feedback.play(GameFeedbackCue.select);
    analytics.track('level_restart', {
      'level_id': state.level.id,
      'moves_before_restart': state.moves,
      'after_fail': state.failed,
      ...runMetrics.analyticsFields(),
    });
    setState(() {
      state.reset();
      bestStarsBeforeRun = progress?.starsFor(state.level.id) ?? 0;
      runMetrics = RunMetrics();
    });
  }

  void nextLevel() {
    if (levelIndex >= demoLevels.length - 1) return;
    analytics.track('level_next', {
      'from_level_id': state.level.id,
      'moves': state.moves,
      'stars': state.level.starsFor(state.moves),
      ...runMetrics.analyticsFields(),
    });
    selectLevel(levelIndex + 1);
  }

  String? tutorialHint() {
    final onboarding = tutorial;
    if (onboarding == null || onboarding.complete || levelIndex != 0) return null;
    return onboarding.nextHint(
      hasMoved: state.moves > 0,
      hasLoot: state.collected,
      isOnExitPath: state.collected && !state.complete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProgress = progress;
    if (currentProgress == null || tutorial == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final level = state.level;
    final bestStars = currentProgress.starsFor(level.id);
    final hint = tutorialHint();
    final runSummary = state.complete
        ? HeistRunSummary.fromLevel(
            level: level,
            moves: state.moves,
            bestStarsBeforeRun: bestStarsBeforeRun,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Swipe Heist · ${level.title}'),
        actions: [
          IconButton(
            tooltip: 'Campaign',
            onPressed: openCampaign,
            icon: const Icon(Icons.grid_view_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${levelIndex + 1}/${demoLevels.length}')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(state.status, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Moves ${state.moves} · Par ${level.parMoves} · Best ${bestStars == 0 ? '—' : List.filled(bestStars, '★').join()}',
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: hint == null
                  ? const SizedBox(height: 12)
                  : Container(
                      key: ValueKey(hint),
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 18),
                          const SizedBox(width: 8),
                          Flexible(child: Text(hint)),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanEnd: onSwipe,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: level.size,
                        crossAxisSpacing: 7,
                        mainAxisSpacing: 7,
                      ),
                      itemCount: level.size * level.size,
                      itemBuilder: (context, index) {
                        final point = GridPoint(
                          index ~/ level.size,
                          index % level.size,
                        );
                        return _PuzzleTile(point: point, state: state);
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (runSummary != null)
              HeistResultCard(
                summary: runSummary,
                onReplay: restartLevel,
                onNext: levelIndex < demoLevels.length - 1 ? nextLevel : null,
              )
            else
              FilledButton.tonal(
                onPressed: restartLevel,
                child: Text(state.failed ? 'Retry job' : 'Restart'),
              ),
            if (state.complete && levelIndex == demoLevels.length - 1) ...[
              const SizedBox(height: 10),
              const Text('Demo campaign complete'),
            ],
          ],
        ),
      ),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({required this.point, required this.state});
  final GridPoint point;
  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    final level = state.level;
    var label = '';
    if (level.walls.contains(point)) label = '■';
    if (level.hazards.contains(point)) label = '◉';
    if (point == level.objective && !state.collected) label = '◆';
    if (point == level.exit) label = 'EXIT';
    if (point == state.player) label = '●';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: point == state.player
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        scale: point == state.player ? 1.12 : 1,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
