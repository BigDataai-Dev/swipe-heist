import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/level_validator.dart';
import 'package:swipe_heist/src/puzzle_level.dart';

void main() {
  test('published demo campaign levels are structurally valid and solvable', () {
    for (final level in demoLevels) {
      final issues = LevelValidator.validate(level);
      expect(issues, isEmpty, reason: '${level.id}: ${issues.join(', ')}');
    }
  });
}
