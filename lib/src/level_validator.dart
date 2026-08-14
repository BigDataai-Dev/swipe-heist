import 'grid_point.dart';
import 'puzzle_level.dart';

class LevelValidator {
  const LevelValidator._();

  static List<String> validate(PuzzleLevel level) {
    final issues = <String>[];
    final special = <String, GridPoint>{
      'start': level.start,
      'objective': level.objective,
      'exit': level.exit,
    };

    for (final entry in special.entries) {
      if (!_inside(level, entry.value)) {
        issues.add('${entry.key} is outside the grid');
      }
      if (level.walls.contains(entry.value)) {
        issues.add('${entry.key} overlaps a wall');
      }
      if (level.hazards.contains(entry.value)) {
        issues.add('${entry.key} overlaps a hazard');
      }
    }

    for (final wall in level.walls) {
      if (!_inside(level, wall)) issues.add('wall $wall is outside the grid');
    }
    for (final hazard in level.hazards) {
      if (!_inside(level, hazard)) issues.add('hazard $hazard is outside the grid');
      if (level.walls.contains(hazard)) issues.add('hazard $hazard overlaps a wall');
    }

    if (!_reachable(level, level.start, level.objective)) {
      issues.add('objective is unreachable from start');
    }
    if (!_reachable(level, level.objective, level.exit)) {
      issues.add('exit is unreachable after collecting the objective');
    }
    if (level.parMoves <= 0) issues.add('parMoves must be positive');

    return issues;
  }

  static bool _inside(PuzzleLevel level, GridPoint point) =>
      point.row >= 0 &&
      point.column >= 0 &&
      point.row < level.size &&
      point.column < level.size;

  static bool _reachable(PuzzleLevel level, GridPoint from, GridPoint to) {
    if (!_inside(level, from) || !_inside(level, to)) return false;
    final blocked = <GridPoint>{...level.walls, ...level.hazards};
    if (blocked.contains(from) || blocked.contains(to)) return false;

    final queue = <GridPoint>[from];
    final seen = <GridPoint>{from};
    const directions = <GridPoint>[
      GridPoint(-1, 0),
      GridPoint(1, 0),
      GridPoint(0, -1),
      GridPoint(0, 1),
    ];

    for (var cursor = 0; cursor < queue.length; cursor++) {
      final current = queue[cursor];
      if (current == to) return true;
      for (final direction in directions) {
        final next = current.move(direction.row, direction.column);
        if (_inside(level, next) && !blocked.contains(next) && seen.add(next)) {
          queue.add(next);
        }
      }
    }
    return false;
  }
}
