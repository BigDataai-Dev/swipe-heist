import 'grid_point.dart';

class PuzzleLevel {
  const PuzzleLevel({
    required this.id,
    required this.title,
    required this.size,
    required this.start,
    required this.objective,
    required this.exit,
    this.walls = const <GridPoint>{},
    this.hazards = const <GridPoint>{},
  });

  final String id;
  final String title;
  final int size;
  final GridPoint start;
  final GridPoint objective;
  final GridPoint exit;
  final Set<GridPoint> walls;
  final Set<GridPoint> hazards;
}

const demoLevels = <PuzzleLevel>[
  PuzzleLevel(
    id: 'gallery',
    title: 'The Gallery',
    size: 5,
    start: GridPoint(4, 0),
    objective: GridPoint(1, 3),
    exit: GridPoint(0, 4),
    walls: <GridPoint>{GridPoint(1, 1), GridPoint(2, 1), GridPoint(3, 3)},
    hazards: <GridPoint>{GridPoint(2, 3), GridPoint(0, 2)},
  ),
  PuzzleLevel(
    id: 'penthouse',
    title: 'The Penthouse',
    size: 5,
    start: GridPoint(4, 4),
    objective: GridPoint(0, 1),
    exit: GridPoint(2, 4),
    walls: <GridPoint>{GridPoint(1, 2), GridPoint(2, 2), GridPoint(3, 2)},
    hazards: <GridPoint>{GridPoint(0, 3), GridPoint(3, 4)},
  ),
  PuzzleLevel(
    id: 'vault',
    title: 'The Vault',
    size: 6,
    start: GridPoint(5, 0),
    objective: GridPoint(2, 4),
    exit: GridPoint(0, 5),
    walls: <GridPoint>{GridPoint(1, 1), GridPoint(1, 2), GridPoint(3, 3), GridPoint(4, 3)},
    hazards: <GridPoint>{GridPoint(2, 2), GridPoint(4, 5), GridPoint(0, 3)},
  ),
];
