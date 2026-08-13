# Swipe Heist gameplay metrics

The prototype should instrument a small provider-neutral event contract before any analytics SDK is chosen.

Required events for the vertical slice:
- `level_start`: level id and campaign position.
- `level_fail`: level id, move count, failure tile, elapsed seconds.
- `level_restart`: level id and prior move count.
- `level_complete`: level id, move count, elapsed seconds, replay count.
- `campaign_complete`: total levels completed and total restarts.

Primary product metrics are tutorial completion, first-session level completion, average retries per level, median moves to completion, and percentage of players starting the next level.

Do not add ads until the first three levels are consistently understandable and completion telemetry exists. Rewarded ads should eventually map to optional recovery or cosmetic value, not interrupt every attempt.
