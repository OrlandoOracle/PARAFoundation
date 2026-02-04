import Testing
import Foundation
import SwiftData
@testable import PARAFoundation

@Suite("Decay Engine Tests")
struct DecayEngineTests {

    private func makeContainer() throws -> ModelContainer {
        try PARAContainer.createInMemory()
    }

    private func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }

    // MARK: - Inbox Decay

    @Test("Inbox item older than 14 days is archived")
    @MainActor
    func inboxStaleArchived() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item.quickCapture("Old thought")
        item.lastAccessedAt = daysAgo(15)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsArchived.count == 1)
        #expect(item.paraCategory == .archive)
        #expect(item.archivedAt != nil)
    }

    @Test("Inbox item at exactly 14 days is archived")
    @MainActor
    func inboxExactlyStale() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item.quickCapture("Borderline thought")
        item.lastAccessedAt = daysAgo(14)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsArchived.count == 1)
        #expect(item.paraCategory == .archive)
    }

    @Test("Inbox item at 13 days is not archived")
    @MainActor
    func inboxNotYetStale() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item.quickCapture("Recent thought")
        item.lastAccessedAt = daysAgo(13)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsArchived.isEmpty)
        #expect(item.paraCategory == .inbox)
    }

    // MARK: - Project Decay

    @Test("Project item older than 30 days is flagged for review")
    @MainActor
    func projectFlagged() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(body: "Old project", itemType: .task, source: .manual, paraCategory: .project)
        item.lastAccessedAt = daysAgo(31)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsFlagged.count == 1)
        #expect(item.flaggedForReview == true)
        #expect(item.flaggedAt != nil)
        #expect(item.paraCategory == .project) // NOT archived yet
    }

    @Test("Flagged project past grace period is archived")
    @MainActor
    func flaggedProjectArchived() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(body: "Flagged project", itemType: .task, source: .manual, paraCategory: .project)
        item.lastAccessedAt = daysAgo(40)
        item.flaggedForReview = true
        item.flaggedAt = daysAgo(8) // 8 days ago, grace period is 7
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsArchived.count == 1)
        #expect(item.paraCategory == .archive)
        #expect(item.archivedAt != nil)
    }

    @Test("Flagged project within grace period stays flagged")
    @MainActor
    func flaggedProjectWithinGrace() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(body: "Recently flagged", itemType: .task, source: .manual, paraCategory: .project)
        item.lastAccessedAt = daysAgo(35)
        item.flaggedForReview = true
        item.flaggedAt = daysAgo(5) // 5 days ago, grace period is 7
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsArchived.isEmpty)
        #expect(item.paraCategory == .project)
        #expect(item.flaggedForReview == true)
    }

    // MARK: - Resource Decay

    @Test("Resource item older than 60 days is archived")
    @MainActor
    func resourceArchived() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(body: "Old resource", itemType: .reference, source: .manual, paraCategory: .resource)
        item.lastAccessedAt = daysAgo(61)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsArchived.count == 1)
        #expect(item.paraCategory == .archive)
    }

    // MARK: - Immunity

    @Test("Pinned items are never decayed")
    @MainActor
    func pinnedImmune() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item.quickCapture("Important pinned item")
        item.pinned = true
        item.lastAccessedAt = daysAgo(100)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsArchived.isEmpty)
        #expect(summary.itemsFlagged.isEmpty)
        #expect(item.paraCategory == .inbox)
    }

    @Test("Area items are never decayed")
    @MainActor
    func areaImmune() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(body: "Health", itemType: .reference, source: .manual, paraCategory: .area)
        item.pinned = true
        item.lastAccessedAt = daysAgo(200)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.itemsArchived.isEmpty)
        #expect(summary.itemsFlagged.isEmpty)
        #expect(item.paraCategory == .area)
    }

    @Test("Already archived items are not processed")
    @MainActor
    func archivedSkipped() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item.quickCapture("Already archived")
        item.paraCategory = .archive
        item.archivedAt = daysAgo(30)
        item.lastAccessedAt = daysAgo(100)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.runDecay(in: context)

        #expect(summary.totalEvaluated == 0)
        #expect(summary.itemsArchived.isEmpty)
    }

    // MARK: - Preview (Dry Run)

    @Test("previewDecay returns correct summary without modifying data")
    @MainActor
    func previewNoSideEffects() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item.quickCapture("Should stay")
        item.lastAccessedAt = daysAgo(15)
        context.insert(item)
        try context.save()

        let engine = DecayEngine()
        let summary = try engine.previewDecay(in: context)

        #expect(summary.itemsArchived.count == 1)
        // Item should NOT have been modified
        #expect(item.paraCategory == .inbox)
        #expect(item.archivedAt == nil)
    }
}
