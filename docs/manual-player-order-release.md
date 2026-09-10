# Manual player order release checks

The `bowtie2PlayerOrder` model adds `Game.playerOrderValue`,
`PlayerScore.manualPosition`, and `PlayerScore.orderingID`. The previous
`bowtie2` model remains bundled for lightweight migration. Existing games stay
score-sorted and receive positions only when manual order is saved.

## CloudKit

Before distributing this model through TestFlight or the App Store:

1. Run a development-signed build against `iCloud.Bowtie`. Initialize the
   development schema with `NSPersistentCloudKitContainer.initializeCloudKitSchema`
   using the app's loaded container, then inspect the additive fields in
   CloudKit Console. Keep schema initialization out of normal app startup.
2. On two devices signed into the same iCloud account, open the same game.
   Reorder on one and confirm the other's visible scoreboard updates without
   reopening. Switch By Score/Manual and confirm the remembered order syncs.
3. Reorder offline on both devices, then reconnect. Confirm the final order
   converges and every player appears once. A merged arrangement is acceptable;
   position updates are not an atomic whole-list transaction. Also test adding
   and removing a player while the other device's reorder editor is open.
4. Review the development-to-production schema diff and deploy the additive
   fields using [Apple's schema deployment procedure](https://developer.apple.com/documentation/cloudkit/deploying-an-icloud-container-s-schema).
   Verify production contains the fields before releasing the app.

Local validation cannot substitute for these checks. This implementation session
had no CloudKit management token and only one connected physical device, so no
production schema deployment or live two-device sync validation was performed.

## Local validation

`PlayerOrderTests` covers ordering, ranked results, save failure/retry, membership
changes, duplication, SQLite reopening, migration from the previous model, and
merging position changes from another managed-object context.

`testManualPlayerOrderDragSaveCancelAndReopen` performs consecutive native handle
drags without intervening taps, checks Save and Cancel, enters a score, switches
display modes in Game Settings, relaunches the app, and captures normal and
accessibility-text screenshots. It also verifies that the reorder toolbar button
appears only in Manual mode.

The editor uses UIKit's native editable table with SwiftUI row content through
`UIHostingConfiguration` (iOS 16+). The table owns drag handles, row movement,
animations, and accessibility. A move updates the local draft without reloading
the table. Membership changes are reconciled separately from dragging, and
persistence happens only on Save.

Rapid consecutive gestures reproduced a missed second drag in SwiftUI's `List`,
including its automatic `editActions: .move` implementation. The native table
avoids that SwiftUI list behavior without custom gestures or animation delays.
