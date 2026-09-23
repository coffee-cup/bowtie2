# Player order and game settings

A game can rank players by score or keep a manually chosen order. Winner scoring remains separate from the display order.

## Sub-features

- `order.manual`: drag players and save or cancel the draft.
- `order.persist`: keep the saved order after scoring and relaunch.
- `game.rules`: highest or lowest score wins; edit game membership and display settings.

## How to get to it (user POV)

Open a game → Game settings → Player Order → Manual. Return to the scoreboard → Reorder Players. The same settings screen offers Winner has, player Edit and Keep Screen Awake.

## Driving it with XCUITest

Preconditions: normal launch; the existing test creates three players and a game through the UI.

```sh
python3 scripts/verify-bowtie.py run --test bowtie2UITests/bowtie2UITests/testManualPlayerOrderDragSaveCancelAndReopen
```

- Select mode: `app.buttons["game.settings"]` → `app.buttons["playerOrder.picker"]` → `app.buttons["Manual"]` or `app.buttons["By Score"]`.
- Reorder: tap `playerOrder.reorder`; use the existing `dragPlayer` helper, which finds cells containing `reorderPlayer.\(name)` and drags within those cells. Assert row order by comparing their vertical positions.
- Cancel: tap `Cancel`; assert the original order remains. Save: tap `playerOrder.save`; assert the chosen order remains after scoring and relaunch.
- Accessibility: the existing test relaunches with `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXXXL`, reopens ordering and captures the Save control and rows.
- Extend rule changes with distinct scores and a tie. Change Winner has and verify the displayed ranking and winner independently of manual order. Extend membership changes through the Players section's `Edit`, checking that retained scores and player order survive relaunch.

## Gotchas

Global Settings → Player sort controls selection lists, not the game's scoreboard order. Reordering requires at least two players and Manual mode. The current test saves, cancels and reopens a manual order, but does not verify all game settings. `bowtie2Tests/PlayerOrderTests` covers migration, failure and reconciliation cases as additional model evidence.
