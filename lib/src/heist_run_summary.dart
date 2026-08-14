import 'puzzle_level.dart';

class HeistRunSummary {
  const HeistRunSummary({
    required this.levelId,
    required this.moves,
    required this.parMoves,
    required this.stars,
    required this.bestStarsBeforeRun,
  });

  final String levelId;
  final int moves;
  final int parMoves;
  final int stars;
  final int bestStarsBeforeRun;

  int get movesOverPar => moves - parMoves;
  bool get isNewBest => stars > bestStarsBeforeRun;
  bool get mastered => stars == 3;

  String get headline {
    if (mastered) return 'Perfect getaway';
    if (stars == 2) return 'Clean job';
    return 'Made it out';
  }

  String get recommendation {
    if (mastered) return 'Three stars secured. Move on or replay for fewer moves.';
    if (stars == 2) return 'Replay and save ${movesOverPar.clamp(1, 99)} move(s) to chase three stars.';
    return 'Replay the route and cut unnecessary moves before the next job.';
  }

  factory HeistRunSummary.fromLevel({
    required PuzzleLevel level,
    required int moves,
    required int bestStarsBeforeRun,
  }) {
    return HeistRunSummary(
      levelId: level.id,
      moves: moves,
      parMoves: level.parMoves,
      stars: level.starsFor(moves),
      bestStarsBeforeRun: bestStarsBeforeRun,
    );
  }
}
