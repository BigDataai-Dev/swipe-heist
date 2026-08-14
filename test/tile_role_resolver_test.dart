import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/game_state.dart';
import 'package:swipe_heist/src/grid_point.dart';
import 'package:swipe_heist/src/puzzle_level.dart';
import 'package:swipe_heist/src/tile_presentation.dart';
import 'package:swipe_heist/src/tile_role_resolver.dart';

void main() {
  const level = PuzzleLevel(
    id: 'resolver',
    title: 'Resolver',
    size: 4,
    parMoves: 6,
    start: GridPoint(0, 0),
    objective: GridPoint(1, 1),
    exit: GridPoint(3, 3),
    walls: {GridPoint(0, 2)},
    hazards: {GridPoint(2, 2)},
  );

  test('resolves board roles and player with explicit precedence', () {
    final state = PuzzleState(level);

    expect(
      tileRoleFor(point: const GridPoint(0, 0), state: state),
      TileRole.player,
    );
    expect(
      tileRoleFor(point: const GridPoint(1, 1), state: state),
      TileRole.loot,
    );
    expect(
      tileRoleFor(point: const GridPoint(3, 3), state: state),
      TileRole.exit,
    );
    expect(
      tileRoleFor(point: const GridPoint(2, 2), state: state),
      TileRole.hazard,
    );
    expect(
      tileRoleFor(point: const GridPoint(0, 2), state: state),
      TileRole.wall,
    );
    expect(
      tileRoleFor(point: const GridPoint(3, 0), state: state),
      TileRole.floor,
    );
  });

  test('collected objective becomes floor after player moves away', () {
    final state = PuzzleState(level)
      ..collected = true
      ..player = const GridPoint(0, 1);

    expect(
      tileRoleFor(point: const GridPoint(1, 1), state: state),
      TileRole.floor,
    );
  });
}
