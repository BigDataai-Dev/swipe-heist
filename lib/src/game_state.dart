import 'grid_point.dart';
import 'puzzle_level.dart';

class PuzzleState {
  PuzzleState(this.level) : player = level.start;

  final PuzzleLevel level;
  GridPoint player;
  bool collected = false;
  bool failed = false;
  bool complete = false;
  int moves = 0;
  String status = 'Swipe to move';

  void reset() {
    player = level.start;
    collected = false;
    failed = false;
    complete = false;
    moves = 0;
    status = 'Swipe to move';
  }

  void move(int dr, int dc) {
    if (failed || complete) return;

    final next = player.move(dr, dc);
    if (next.row < 0 ||
        next.column < 0 ||
        next.row >= level.size ||
        next.column >= level.size) {
      return;
    }
    if (level.walls.contains(next)) return;

    player = next;
    moves += 1;

    if (level.hazards.contains(next)) {
      failed = true;
      status = 'Caught. Restart the job.';
    } else if (next == level.objective) {
      collected = true;
      status = 'Loot secured. Reach the exit.';
    } else if (next == level.exit && collected) {
      complete = true;
      status = 'Clean escape in $moves moves.';
    } else if (next == level.exit) {
      status = 'Get the loot first.';
    } else {
      status = collected ? 'Reach the exit' : 'Find the loot';
    }
  }
}
