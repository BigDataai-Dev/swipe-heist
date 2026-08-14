import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_analytics.dart';
import 'game_progress.dart';
import 'game_state.dart';
import 'grid_point.dart';
import 'puzzle_level.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  static const analytics = DebugGameAnalytics();
  final progressStore = GameProgressStore();

  GameProgress? progress;
  var levelIndex = 0;
  late PuzzleState state = PuzzleState(demoLevels[levelIndex]);

  @override
  void initState() {
    super.initState();
    restoreProgress();
  }

  Future<void> restoreProgress() async {
    final loaded = await progressStore.load(
      demoLevels.map((level) => level.id).toList(growable: false),
    );
    if (!mounted) return;
    final restoredIndex = loaded.unlockedLevelIndex
        .clamp(0, demoLevels.length - 1)
        .toInt();
    setState(() {
      progress = loaded;
      levelIndex = restoredIndex;
      state = PuzzleState(demoLevels[levelIndex]);
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
    HapticFeedback.selectionClick();
    setState(() {
      levelIndex = index;
      state = PuzzleState(demoLevels[index]);
    });
    trackLevelStart();
  }

  void openCampaign() {
    final current = progress!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: demoLevels.length,
          itemBuilder: (context, index) {
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
              trailing: Icon(unlocked ? Icons.play_arrow_rounded : Icons.lock_outline),
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
    final v = details.velocity.pixelsPerSecond;
    if (v.distance < 80 || state.complete || state.failed || progress == null) return;

    final beforePlayer = state.player;
    final wasCollected = state.collected;
    final wasComplete = state.complete;
    final wasFailed = state.failed;
    setState(() {
      if (v.dx.abs() > v.dy.abs()) {
        state.move(0, v.dx > 0 ? 1 : -1);
      } else {
        state.move(v.dy > 0 ? 1 : -1, 0);
      }
    });

    if (state.player == beforePlayer) {
      HapticFeedback.selectionClick();
      return;
    }

    if (!wasCollected && state.collected) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    if (!wasFailed && state.failed) {
      HapticFeedback.heavyImpact();
      analytics.track('level_fail', {'level_id': state.level.id, 'moves': state.moves});
    }
    if (!wasComplete && state.complete) {
      HapticFeedback.heavyImpact();
      final stars = state.level.starsFor(state.moves);
      analytics.track('level_complete', {
        'level_id': state.level.id,
        'moves': state.moves,
        'par_moves': state.level.parMoves,
        'stars': stars,
      });
      recordCompletion();
    }
  }

  void restartLevel() {
    HapticFeedback.selectionClick();
    analytics.track('level_restart', {
      'level_id': state.level.id,
      'moves_before_restart': state.moves,
      'after_fail': state.failed,
    });
    setState(state.reset);
  }

  void nextLevel() {
    if (levelIndex >= demoLevels.length - 1) return;
    analytics.track('level_next', {
      'from_level_id': state.level.id,
      'moves': state.moves,
      'stars': state.level.starsFor(state.moves),
    });
    selectLevel(levelIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    final currentProgress = progress;
    if (currentProgress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final level = state.level;
    final stars = state.complete ? level.starsFor(state.moves) : 0;
    final bestStars = currentProgress.starsFor(level.id);
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
            Text('Moves ${state.moves} · Par ${level.parMoves} · Best ${bestStars == 0 ? '—' : List.filled(bestStars, '★').join()}'),
            if (state.complete) ...[
              const SizedBox(height: 8),
              Text(List.filled(stars, '★').join(), style: Theme.of(context).textTheme.headlineSmall),
            ],
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
                        final point = GridPoint(index ~/ level.size, index % level.size);
                        return _PuzzleTile(point: point, state: state);
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.complete && levelIndex < demoLevels.length - 1)
              FilledButton.icon(
                onPressed: nextLevel,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Next job'),
              )
            else if (state.complete)
              const Text('Demo campaign complete')
            else
              FilledButton.tonal(
                onPressed: restartLevel,
                child: Text(state.failed ? 'Retry job' : 'Restart'),
              ),
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
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        scale: point == state.player ? 1.12 : 1,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
