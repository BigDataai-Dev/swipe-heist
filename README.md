# Swipe Heist

Swipe Heist is a fictional mobile arcade puzzle about guiding a stylized character through compact levels with one-thumb directional swipes.

## Current prototype loop

- Swipe up, down, left or right.
- Collect the objective token before the exit becomes useful.
- Avoid hazards and blocked tiles.
- Reach the exit tile.
- Restart instantly after failure.
- Earn 1–3 stars from move efficiency against each level par.
- Unlock campaign jobs and keep best-star progress locally.
- Re-open unlocked jobs from the campaign selector.

## Prototype architecture

The Flutter prototype keeps gameplay deliberately small and provider-agnostic:

- `PuzzleLevel` describes level geometry and par.
- `PuzzleState` owns movement, objective, failure and completion rules.
- `GameProgress` persists unlocked level and best-star state.
- `GameAnalytics` isolates telemetry from gameplay so a real provider can be added later.

## Product gate before adding monetization

The next milestone is not ads. First the prototype should prove that a new player understands the interaction without explanation and wants to replay for a better result.

Track at minimum:

- tutorial / first-job completion rate;
- failures before first clear;
- restarts per level;
- stars on first clear versus replay;
- campaign progression depth;
- sessions per user and D1 retention once external analytics is connected.

Only after these signals are credible should rewarded ads, cosmetics, progression economy or paid acquisition be tested.

## Next gameplay slice

The next useful content pass should expand from simple walls/hazards into one mechanic at a time, keeping one-thumb readability:

1. camera tiles with predictable line-of-sight;
2. key + locked exit;
3. alarm state that changes the safe route;
4. a short getaway finish after the puzzle.

Each mechanic should enter through dedicated tutorial jobs before being combined.

## Tech

Flutter for the first prototype. The V0 avoids external game-engine dependencies so the interaction loop stays cheap to test and easy to instrument.
