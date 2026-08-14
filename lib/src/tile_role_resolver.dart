import 'game_state.dart';
import 'grid_point.dart';
import 'tile_presentation.dart';

TileRole tileRoleFor({
  required GridPoint point,
  required PuzzleState state,
}) {
  final level = state.level;

  if (point == state.player) return TileRole.player;
  if (point == level.objective && !state.collected) return TileRole.loot;
  if (point == level.exit) return TileRole.exit;
  if (level.hazards.contains(point)) return TileRole.hazard;
  if (level.walls.contains(point)) return TileRole.wall;
  return TileRole.floor;
}
