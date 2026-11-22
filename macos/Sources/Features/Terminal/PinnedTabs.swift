/// Pure helpers for pinned tab ordering. The native macOS tab bar has no concept
/// of pinned tabs so `TerminalController` maintains the invariant that all pinned
/// tabs come before all unpinned tabs. These are separated out to be testable.
enum PinnedTabs {
    /// Returns `items` reordered so that all pinned items come first, preserving
    /// the relative order within the pinned and unpinned sections.
    static func ordered<T>(_ items: [T], isPinned: (T) -> Bool) -> [T] {
        items.filter(isPinned) + items.filter { !isPinned($0) }
    }

    /// Returns the index a tab at `selectedIndex` should move to for a `move_tab`
    /// of `amount`, given that pinned tabs occupy the first `pinnedCount` indices.
    ///
    /// The move is clamped (not wrapped) to the bounds of the tab's own section,
    /// so pinned tabs only move among pinned tabs and unpinned among unpinned.
    static func moveTarget(
        selectedIndex: Int,
        amount: Int,
        count: Int,
        pinnedCount: Int,
        selectedIsPinned: Bool
    ) -> Int {
        let lowerBound = selectedIsPinned ? 0 : pinnedCount
        let upperBound = selectedIsPinned ? pinnedCount - 1 : count - 1
        // Clamp the amount first so huge values (e.g. `move_tab:9223372036854775807`)
        // can't overflow when added to the index.
        let target = selectedIndex + max(-count, min(count, amount))
        return max(lowerBound, min(upperBound, target))
    }
}
