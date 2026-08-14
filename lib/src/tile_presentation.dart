enum TileRole { floor, wall, loot, exit, hazard, player }

class TilePresentation {
  const TilePresentation({
    required this.role,
    required this.symbol,
    required this.accessibilityLabel,
    required this.priority,
  });

  final TileRole role;
  final String symbol;
  final String accessibilityLabel;
  final int priority;
}

const tilePresentations = <TileRole, TilePresentation>{
  TileRole.floor: TilePresentation(
    role: TileRole.floor,
    symbol: '',
    accessibilityLabel: 'Floor',
    priority: 0,
  ),
  TileRole.wall: TilePresentation(
    role: TileRole.wall,
    symbol: '■',
    accessibilityLabel: 'Blocked wall',
    priority: 1,
  ),
  TileRole.loot: TilePresentation(
    role: TileRole.loot,
    symbol: '◆',
    accessibilityLabel: 'Loot objective',
    priority: 4,
  ),
  TileRole.exit: TilePresentation(
    role: TileRole.exit,
    symbol: 'EXIT',
    accessibilityLabel: 'Escape exit',
    priority: 3,
  ),
  TileRole.hazard: TilePresentation(
    role: TileRole.hazard,
    symbol: '!',
    accessibilityLabel: 'Hazard',
    priority: 2,
  ),
  TileRole.player: TilePresentation(
    role: TileRole.player,
    symbol: '●',
    accessibilityLabel: 'Player',
    priority: 5,
  ),
};

TilePresentation presentationFor(TileRole role) => tilePresentations[role]!;
