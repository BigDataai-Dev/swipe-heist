import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/game_state.dart';
import 'package:swipe_heist/src/grid_point.dart';
import 'package:swipe_heist/src/puzzle_level.dart';

void main() {
  const level = PuzzleLevel(
    id: 'test',
    title: 'Test',
    size: 3,
    start: GridPoint(2, 0),
    objective: GridPoint(1, 1),
    exit: GridPoint(0, 2),
    parMoves: 4,
    walls: <GridPoint>{GridPoint(2, 1)},
    hazards: <GridPoint>{GridPoint(1, 2)},
  );

  test('walls and bounds do not consume moves', () {
    final state = PuzzleState(level);
    state.move(0, -1);
    state.move(0, 1);
    expect(state.player, const GridPoint(2, 0));
    expect(state.moves, 0);
  });

  test('objective must be collected before exit completes', () {
    final state = PuzzleState(level);
    state.move(-1, 0);
    state.move(-1, 0);
    state.move(0, 1);
    state.move(0, 1);
    expect(state.complete, isFalse);
    expect(state.status, 'Get the loot first.');
  });

  test('hazard fails the run and blocks further movement', () {
    final state = PuzzleState(level);
    state.move(-1, 0);
    state.move(0, 1);
    expect(state.collected, isTrue);
    state.move(0, 1);
    expect(state.failed, isTrue);
    final moves = state.moves;
    state.move(-1, 0);
    expect(state.moves, moves);
  });

  test('stars reward par or better', () {
    expect(level.starsFor(4), 3);
    expect(level.starsFor(6), 2);
    expect(level.starsFor(7), 1);
  });
}
