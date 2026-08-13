import 'package:flutter/material.dart';
import 'game_state.dart';
import 'grid_point.dart';
import 'puzzle_level.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  var levelIndex = 0;
  late PuzzleState state = PuzzleState(demoLevels[levelIndex]);

  void onSwipe(DragEndDetails details) {
    final v = details.velocity.pixelsPerSecond;
    if (v.distance < 80) return;
    setState(() {
      if (v.dx.abs() > v.dy.abs()) {
        state.move(0, v.dx > 0 ? 1 : -1);
      } else {
        state.move(v.dy > 0 ? 1 : -1, 0);
      }
    });
  }

  void nextLevel() {
    if (levelIndex >= demoLevels.length - 1) return;
    setState(() {
      levelIndex += 1;
      state = PuzzleState(demoLevels[levelIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = state.level;
    return Scaffold(
      appBar: AppBar(
        title: Text('Swipe Heist · ${level.title}'),
        actions: [
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
            Text('Moves ${state.moves}'),
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
                onPressed: () => setState(state.reset),
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: point == state.player
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}
