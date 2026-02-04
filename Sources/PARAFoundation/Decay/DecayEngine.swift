import Foundation
import SwiftData

/// Summary of actions taken or previewed by the decay engine.
public struct DecaySummary: Sendable {
    public var itemsFlagged: [PersistentIdentifier]
    public var itemsArchived: [PersistentIdentifier]
    public var totalEvaluated: Int

    public init(
        itemsFlagged: [PersistentIdentifier] = [],
        itemsArchived: [PersistentIdentifier] = [],
        totalEvaluated: Int = 0
    ) {
        self.itemsFlagged = itemsFlagged
        self.itemsArchived = itemsArchived
        self.totalEvaluated = totalEvaluated
    }
}

/// Engine that evaluates and executes the decay lifecycle on items.
public final class DecayEngine: Sendable {
    public let configuration: DecayConfiguration

    public init(configuration: DecayConfiguration = DecayConfiguration()) {
        self.configuration = configuration
    }

    /// Evaluate all items and execute decay transitions.
    /// Returns a summary of actions taken.
    @MainActor
    public func runDecay(in context: ModelContext) throws -> DecaySummary {
        return try processDecay(in: context, dryRun: false)
    }

    /// Preview what would happen without making changes.
    @MainActor
    public func previewDecay(in context: ModelContext) throws -> DecaySummary {
        return try processDecay(in: context, dryRun: true)
    }

    @MainActor
    private func processDecay(in context: ModelContext, dryRun: Bool) throws -> DecaySummary {
        // Fetch all non-pinned, non-archived items
        let archiveRaw = PARACategory.archive.rawValue
        let predicate = #Predicate<Item> { item in
            item.pinned == false && item.paraCategoryRaw != archiveRaw
        }
        var descriptor = FetchDescriptor<Item>(predicate: predicate)
        descriptor.fetchLimit = nil
        let items = try context.fetch(descriptor)

        var flagged: [PersistentIdentifier] = []
        var archived: [PersistentIdentifier] = []
        let now = Date()
        let calendar = Calendar.current

        for item in items {
            let daysSinceAccess = calendar.dateComponents([.day], from: item.lastAccessedAt, to: now).day ?? 0
            let policyAction = DecayPolicy.action(for: item.paraCategory)

            switch policyAction {
            case .archive:
                let threshold = item.paraCategory == .inbox
                    ? configuration.inboxStaleDays
                    : configuration.resourceStaleDays
                if daysSinceAccess >= threshold {
                    if !dryRun {
                        item.paraCategory = .archive
                        item.archivedAt = now
                        item.updatedAt = now
                    }
                    archived.append(item.persistentModelID)
                }

            case .flagForReview:
                if item.flaggedForReview {
                    // Already flagged — check if grace period has passed
                    if let flagDate = item.flaggedAt {
                        let daysSinceFlagged = calendar.dateComponents([.day], from: flagDate, to: now).day ?? 0
                        if daysSinceFlagged >= configuration.flagGraceDays {
                            if !dryRun {
                                item.paraCategory = .archive
                                item.archivedAt = now
                                item.updatedAt = now
                            }
                            archived.append(item.persistentModelID)
                        }
                    }
                } else if daysSinceAccess >= configuration.projectFlagDays {
                    // Not yet flagged — flag it
                    if !dryRun {
                        item.flaggedForReview = true
                        item.flaggedAt = now
                        item.updatedAt = now
                    }
                    flagged.append(item.persistentModelID)
                }

            case .none:
                break
            }
        }

        return DecaySummary(
            itemsFlagged: flagged,
            itemsArchived: archived,
            totalEvaluated: items.count
        )
    }
}
