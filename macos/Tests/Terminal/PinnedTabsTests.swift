import Testing
@testable import Ghostty

@Suite
struct PinnedTabsTests {
    // MARK: ordered

    @Test func orderedNoPinnedIsUnchanged() {
        let tabs = ["a", "b", "c"]
        #expect(PinnedTabs.ordered(tabs) { _ in false } == tabs)
    }

    @Test func orderedAllPinnedIsUnchanged() {
        let tabs = ["a", "b", "c"]
        #expect(PinnedTabs.ordered(tabs) { _ in true } == tabs)
    }

    @Test func orderedAlreadyOrderedIsUnchanged() {
        let pinned: Set = ["a", "b"]
        let tabs = ["a", "b", "c", "d"]
        #expect(PinnedTabs.ordered(tabs) { pinned.contains($0) } == tabs)
    }

    @Test func orderedPinningMovesTabToEndOfPinnedSection() {
        // Pinning "d" with "a" and "b" already pinned moves it right after them.
        let pinned: Set = ["a", "b", "d"]
        let tabs = ["a", "b", "c", "d", "e"]
        #expect(PinnedTabs.ordered(tabs) { pinned.contains($0) } == ["a", "b", "d", "c", "e"])
    }

    @Test func orderedUnpinningMovesTabToStartOfUnpinnedSection() {
        // Unpinning "a" moves it to right after the remaining pinned tabs.
        let pinned: Set = ["b", "c"]
        let tabs = ["a", "b", "c", "d"]
        #expect(PinnedTabs.ordered(tabs) { pinned.contains($0) } == ["b", "c", "a", "d"])
    }

    @Test func orderedPreservesRelativeOrderWithinSections() {
        // E.g. after a drag interleaved pinned and unpinned tabs.
        let pinned: Set = ["p1", "p2", "p3"]
        let tabs = ["u1", "p1", "u2", "p2", "u3", "p3"]
        #expect(PinnedTabs.ordered(tabs) { pinned.contains($0) } == ["p1", "p2", "p3", "u1", "u2", "u3"])
    }

    @Test func orderedEmpty() {
        #expect(PinnedTabs.ordered([String]()) { _ in true }.isEmpty)
    }

    // MARK: moveTarget

    /// Layout used below: 2 pinned tabs (0, 1) followed by 3 unpinned (2, 3, 4).
    private func target(_ selectedIndex: Int, _ amount: Int, pinned: Bool) -> Int {
        PinnedTabs.moveTarget(
            selectedIndex: selectedIndex,
            amount: amount,
            count: 5,
            pinnedCount: 2,
            selectedIsPinned: pinned)
    }

    @Test func moveTargetWithinUnpinnedSection() {
        #expect(target(2, 1, pinned: false) == 3)
        #expect(target(4, -1, pinned: false) == 3)
        #expect(target(3, 0, pinned: false) == 3)
    }

    @Test func moveTargetUnpinnedCannotEnterPinnedSection() {
        #expect(target(2, -1, pinned: false) == 2)
        #expect(target(4, -10, pinned: false) == 2)
    }

    @Test func moveTargetUnpinnedClampsAtEnd() {
        #expect(target(4, 1, pinned: false) == 4)
        #expect(target(2, 10, pinned: false) == 4)
    }

    @Test func moveTargetWithinPinnedSection() {
        #expect(target(0, 1, pinned: true) == 1)
        #expect(target(1, -1, pinned: true) == 0)
    }

    @Test func moveTargetPinnedCannotLeavePinnedSection() {
        #expect(target(1, 1, pinned: true) == 1)
        #expect(target(0, 10, pinned: true) == 1)
        #expect(target(0, -1, pinned: true) == 0)
    }

    @Test func moveTargetNoPinnedTabsMatchesPlainClamping() {
        let t = { (index: Int, amount: Int) in
            PinnedTabs.moveTarget(
                selectedIndex: index, amount: amount, count: 3, pinnedCount: 0, selectedIsPinned: false)
        }
        #expect(t(0, -1) == 0)
        #expect(t(0, 1) == 1)
        #expect(t(1, 5) == 2)
    }

    @Test func moveTargetHugeAmountsDoNotOverflow() {
        #expect(target(3, Int.max, pinned: false) == 4)
        #expect(target(3, Int.min, pinned: false) == 2)
        #expect(target(0, Int.max, pinned: true) == 1)
        #expect(target(1, Int.min, pinned: true) == 0)
    }
}
