import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/tile_presentation.dart';

void main() {
  test('every gameplay tile role has readable presentation metadata', () {
    for (final role in TileRole.values) {
      final presentation = presentationFor(role);
      expect(presentation.role, role);
      expect(presentation.accessibilityLabel.trim(), isNotEmpty);
      expect(presentation.priority, greaterThanOrEqualTo(0));
    }
  });

  test('player and objective stay visually dominant', () {
    expect(
      presentationFor(TileRole.player).priority,
      greaterThan(presentationFor(TileRole.wall).priority),
    );
    expect(
      presentationFor(TileRole.loot).priority,
      greaterThan(presentationFor(TileRole.hazard).priority),
    );
  });
}
