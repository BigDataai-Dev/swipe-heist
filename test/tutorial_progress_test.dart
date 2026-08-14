import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/tutorial_progress.dart';

void main() {
  test('tutorial guides swipe, loot, then exit', () {
    final progress = TutorialProgress();

    expect(
      progress.nextHint(hasMoved: false, hasLoot: false, isOnExitPath: false),
      'Swipe anywhere to move.',
    );

    progress.acknowledgeSwipe();
    expect(
      progress.nextHint(hasMoved: true, hasLoot: false, isOnExitPath: false),
      'Grab the diamond before escaping.',
    );

    progress.acknowledgeLoot();
    expect(
      progress.nextHint(hasMoved: true, hasLoot: true, isOnExitPath: true),
      'Now reach EXIT.',
    );

    progress.acknowledgeExit();
    expect(progress.complete, isTrue);
    expect(
      progress.nextHint(hasMoved: true, hasLoot: true, isOnExitPath: true),
      isNull,
    );
  });

  test('tutorial progress roundtrips through json', () {
    final progress = TutorialProgress(
      swipeShown: true,
      lootShown: true,
      exitShown: false,
    );

    final restored = TutorialProgress.fromJson(progress.toJson());
    expect(restored.swipeShown, isTrue);
    expect(restored.lootShown, isTrue);
    expect(restored.exitShown, isFalse);
    expect(restored.complete, isFalse);
  });
}
