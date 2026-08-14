class TutorialProgress {
  TutorialProgress({this.swipeShown = false, this.lootShown = false, this.exitShown = false});

  bool swipeShown;
  bool lootShown;
  bool exitShown;

  bool get complete => swipeShown && lootShown && exitShown;

  String? nextHint({required bool hasMoved, required bool hasLoot, required bool isOnExitPath}) {
    if (!swipeShown && !hasMoved) return 'Swipe anywhere to move.';
    if (!lootShown && !hasLoot) return 'Grab the diamond before escaping.';
    if (!exitShown && hasLoot && isOnExitPath) return 'Now reach EXIT.';
    return null;
  }

  void acknowledgeSwipe() => swipeShown = true;
  void acknowledgeLoot() => lootShown = true;
  void acknowledgeExit() => exitShown = true;

  Map<String, bool> toJson() => {
        'swipeShown': swipeShown,
        'lootShown': lootShown,
        'exitShown': exitShown,
      };

  factory TutorialProgress.fromJson(Map<String, Object?> json) => TutorialProgress(
        swipeShown: json['swipeShown'] == true,
        lootShown: json['lootShown'] == true,
        exitShown: json['exitShown'] == true,
      );
}
