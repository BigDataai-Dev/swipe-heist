class RunMetrics {
  RunMetrics({DateTime? startedAt}) : startedAt = startedAt ?? DateTime.now();

  final DateTime startedAt;

  Duration elapsed({DateTime? now}) {
    final end = now ?? DateTime.now();
    final value = end.difference(startedAt);
    return value.isNegative ? Duration.zero : value;
  }

  Map<String, Object> analyticsFields({DateTime? now}) {
    final duration = elapsed(now: now);
    return {
      'duration_ms': duration.inMilliseconds,
      'duration_seconds': duration.inMilliseconds / 1000,
    };
  }
}
