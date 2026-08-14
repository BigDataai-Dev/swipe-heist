import 'package:flutter/services.dart';

enum GameFeedbackCue {
  blocked,
  move,
  loot,
  fail,
  complete,
  select,
}

abstract interface class GameFeedback {
  const GameFeedback();

  Future<void> play(GameFeedbackCue cue);
}

class SystemGameFeedback implements GameFeedback {
  const SystemGameFeedback();

  @override
  Future<void> play(GameFeedbackCue cue) async {
    switch (cue) {
      case GameFeedbackCue.blocked:
        await HapticFeedback.selectionClick();
        break;
      case GameFeedbackCue.move:
        await HapticFeedback.lightImpact();
        break;
      case GameFeedbackCue.loot:
        await HapticFeedback.mediumImpact();
        await SystemSound.play(SystemSoundType.click);
        break;
      case GameFeedbackCue.fail:
        await HapticFeedback.heavyImpact();
        break;
      case GameFeedbackCue.complete:
        await HapticFeedback.heavyImpact();
        await SystemSound.play(SystemSoundType.click);
        break;
      case GameFeedbackCue.select:
        await HapticFeedback.selectionClick();
        break;
    }
  }
}
