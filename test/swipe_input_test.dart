import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_heist/src/swipe_input.dart';

void main() {
  const policy = SwipeInputPolicy(minimumVelocity: 80);

  test('ignores gestures below minimum velocity', () {
    expect(policy.classify(dx: 30, dy: 20), isNull);
  });

  test('classifies dominant horizontal direction', () {
    expect(policy.classify(dx: 140, dy: 20), SwipeDirection.right);
    expect(policy.classify(dx: -140, dy: 20), SwipeDirection.left);
  });

  test('classifies dominant vertical direction', () {
    expect(policy.classify(dx: 10, dy: -120), SwipeDirection.up);
    expect(policy.classify(dx: 10, dy: 120), SwipeDirection.down);
  });

  test('maps directions to grid deltas', () {
    expect(policy.deltaFor(SwipeDirection.up), (rowDelta: -1, columnDelta: 0));
    expect(policy.deltaFor(SwipeDirection.right), (rowDelta: 0, columnDelta: 1));
  });
}
