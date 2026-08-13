abstract class GameAnalytics {
  void track(String name, Map<String, Object?> properties);
}

class DebugGameAnalytics implements GameAnalytics {
  const DebugGameAnalytics();

  @override
  void track(String name, Map<String, Object?> properties) {
    // Intentionally SDK-free for the prototype. Replace this adapter with
    // Firebase, PostHog, AppsFlyer, or another provider without touching gameplay.
    assert(() {
      // ignore: avoid_print
      print('[analytics] $name $properties');
      return true;
    }());
  }
}
