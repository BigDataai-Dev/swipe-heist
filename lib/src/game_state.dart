import 'grid_point.dart';

class PuzzleState {
  static const size = 5;
  static const start = GridPoint(4, 0);
  static const objective = GridPoint(1, 3);
  static const exit = GridPoint(0, 4);
  static const walls = <GridPoint>{GridPoint(1, 1), GridPoint(2, 1), GridPoint(3, 3)};
  static const hazards = <GridPoint>{GridPoint(2, 3), GridPoint(0, 2)};

  GridPoint player = start;
  bool collected = false;
  String status = 'Swipe to move';

  void reset() {
    player = start;
    collected = false;
    status = 'Swipe to move';
  }

  void move(int dr, int dc) {
    final next = player.move(dr, dc);
    if (next.row < 0 || next.column < 0 || next.row >= size || next.column >= size) return;
    if (walls.contains(next)) return;
    player = next;
    if (hazards.contains(next)) {
      status = 'Hazard hit';
    } else if (next == objective) {
      collected = true;
      status = 'Objective collected';
    } else if (next == exit && collected) {
      status = 'Level complete';
    } else {
      status = collected ? 'Reach the exit' : 'Find the objective';
    }
  }
}
