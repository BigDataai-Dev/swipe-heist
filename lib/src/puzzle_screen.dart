import 'package:flutter/material.dart';
import 'game_state.dart';
import 'grid_point.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final state = PuzzleState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Heist')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(state.status, style: Theme.of(context).textTheme.titleMedium),
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: PuzzleState.size,
                        crossAxisSpacing: 7,
                        mainAxisSpacing: 7,
                      ),
                      itemCount: PuzzleState.size * PuzzleState.size,
                      itemBuilder: (context, index) {
                        final point = GridPoint(index ~/ PuzzleState.size, index % PuzzleState.size);
                        return _PuzzleTile(point: point, state: state);
                      },
                    ),
                  ),
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: () => setState(state.reset),
              child: const Text('Restart'),
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
    var label = '';
    if (PuzzleState.walls.contains(point)) label = '■';
    if (PuzzleState.hazards.contains(point)) label = '◉';
    if (point == PuzzleState.objective && !state.collected) label = '◆';
    if (point == PuzzleState.exit) label = 'EXIT';
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
