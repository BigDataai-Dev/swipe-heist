enum SwipeDirection { up, down, left, right }

class SwipeInputPolicy {
  const SwipeInputPolicy({this.minimumVelocity = 80});

  final double minimumVelocity;

  SwipeDirection? classify({required double dx, required double dy}) {
    final speedSquared = (dx * dx) + (dy * dy);
    if (speedSquared < minimumVelocity * minimumVelocity) return null;

    if (dx.abs() > dy.abs()) {
      return dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    }
    return dy > 0 ? SwipeDirection.down : SwipeDirection.up;
  }

  ({int rowDelta, int columnDelta}) deltaFor(SwipeDirection direction) {
    return switch (direction) {
      SwipeDirection.up => (rowDelta: -1, columnDelta: 0),
      SwipeDirection.down => (rowDelta: 1, columnDelta: 0),
      SwipeDirection.left => (rowDelta: 0, columnDelta: -1),
      SwipeDirection.right => (rowDelta: 0, columnDelta: 1),
    };
  }
}
