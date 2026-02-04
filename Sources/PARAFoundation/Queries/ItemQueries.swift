import Foundation
import SwiftData

/// Pre-built queries that companion apps use to fetch items.
public struct ItemQueries {

    // MARK: - PARA Category Queries

    /// All inbox items, newest first.
    public static func inbox() -> FetchDescriptor<Item> {
        let raw = PARACategory.inbox.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.paraCategoryRaw == raw },
            sortBy: [SortDescriptor(\Item.createdAt, order: .reverse)]
        )
        return descriptor
    }

    /// All active projects (not archived, not flagged).
    public static func activeProjects() -> FetchDescriptor<Item> {
        let raw = PARACategory.project.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.paraCategoryRaw == raw && $0.flaggedForReview == false
            },
            sortBy: [SortDescriptor(\Item.updatedAt, order: .reverse)]
        )
        return descriptor
    }

    /// All areas (items in area category).
    public static func areas() -> FetchDescriptor<Item> {
        let raw = PARACategory.area.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.paraCategoryRaw == raw },
            sortBy: [SortDescriptor(\Item.title)]
        )
        return descriptor
    }

    /// All resources, sorted by last accessed.
    public static func resources() -> FetchDescriptor<Item> {
        let raw = PARACategory.resource.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.paraCategoryRaw == raw },
            sortBy: [SortDescriptor(\Item.lastAccessedAt, order: .reverse)]
        )
        return descriptor
    }

    /// Archived items, optionally filtered by original type.
    public static func archive(itemType: ItemType? = nil) -> FetchDescriptor<Item> {
        let archiveRaw = PARACategory.archive.rawValue
        if let itemType {
            let typeRaw = itemType.rawValue
            return FetchDescriptor<Item>(
                predicate: #Predicate<Item> {
                    $0.paraCategoryRaw == archiveRaw && $0.itemTypeRaw == typeRaw
                },
                sortBy: [SortDescriptor(\Item.archivedAt, order: .reverse)]
            )
        } else {
            return FetchDescriptor<Item>(
                predicate: #Predicate<Item> { $0.paraCategoryRaw == archiveRaw },
                sortBy: [SortDescriptor(\Item.archivedAt, order: .reverse)]
            )
        }
    }

    // MARK: - Type-Specific Queries

    /// All items of a given type, excluding archived.
    public static func byType(_ type: ItemType) -> FetchDescriptor<Item> {
        let typeRaw = type.rawValue
        let archiveRaw = PARACategory.archive.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.itemTypeRaw == typeRaw && $0.paraCategoryRaw != archiveRaw
            },
            sortBy: [SortDescriptor(\Item.updatedAt, order: .reverse)]
        )
        return descriptor
    }

    /// All tasks with a specific status.
    /// Note: Status filtering is done post-fetch since metadata is encoded.
    public static func tasks(status: TaskStatus) -> FetchDescriptor<Item> {
        let taskRaw = ItemType.task.rawValue
        let archiveRaw = PARACategory.archive.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.itemTypeRaw == taskRaw && $0.paraCategoryRaw != archiveRaw
            },
            sortBy: [SortDescriptor(\Item.updatedAt, order: .reverse)]
        )
        return descriptor
    }

    /// All leads at a specific stage.
    /// Note: Stage filtering is done post-fetch since metadata is encoded.
    public static func leads(stage: LeadStage) -> FetchDescriptor<Item> {
        let leadRaw = ItemType.lead.rawValue
        let archiveRaw = PARACategory.archive.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.itemTypeRaw == leadRaw && $0.paraCategoryRaw != archiveRaw
            },
            sortBy: [SortDescriptor(\Item.updatedAt, order: .reverse)]
        )
        return descriptor
    }

    /// Journal entries for a specific date range.
    public static func journalEntries(from startDate: Date, to endDate: Date) -> FetchDescriptor<Item> {
        let journalRaw = ItemType.journal.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.itemTypeRaw == journalRaw &&
                $0.createdAt >= startDate &&
                $0.createdAt <= endDate
            },
            sortBy: [SortDescriptor(\Item.createdAt, order: .reverse)]
        )
        return descriptor
    }

    // MARK: - Soul Value Queries

    /// All items tagged with a soul value.
    public static func bySoulValue(_ value: SoulValue) -> FetchDescriptor<Item> {
        let valueRaw = value.rawValue
        let archiveRaw = PARACategory.archive.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.soulValueRaw == valueRaw && $0.paraCategoryRaw != archiveRaw
            },
            sortBy: [SortDescriptor(\Item.updatedAt, order: .reverse)]
        )
        return descriptor
    }

    // MARK: - Decay-Related Queries

    /// Items flagged for review (need user attention).
    public static func flaggedForReview() -> FetchDescriptor<Item> {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.flaggedForReview == true },
            sortBy: [SortDescriptor(\Item.flaggedAt, order: .reverse)]
        )
        return descriptor
    }

    /// Items that haven't been accessed in more than the given number of days.
    public static func staleItems(olderThan days: Int) -> FetchDescriptor<Item> {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let archiveRaw = PARACategory.archive.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.pinned == false &&
                $0.paraCategoryRaw != archiveRaw &&
                $0.lastAccessedAt < cutoff
            },
            sortBy: [SortDescriptor(\Item.lastAccessedAt)]
        )
        return descriptor
    }

    // MARK: - Relationship Queries

    /// All children of a parent item.
    public static func children(of parentID: UUID) -> FetchDescriptor<Item> {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.parentID == parentID },
            sortBy: [SortDescriptor(\Item.createdAt)]
        )
        return descriptor
    }

    /// All items related to a given item by ID.
    /// Note: Since relatedIDs is an array, #Predicate array containment
    /// may not be supported. This returns children as a starting point;
    /// companion apps should also filter relatedIDs post-fetch.
    public static func related(to itemID: UUID) -> FetchDescriptor<Item> {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.parentID == itemID },
            sortBy: [SortDescriptor(\Item.createdAt)]
        )
        return descriptor
    }

    // MARK: - Source Queries

    /// All items from a specific source app.
    public static func bySource(_ source: ItemSource) -> FetchDescriptor<Item> {
        let sourceRaw = source.rawValue
        let archiveRaw = PARACategory.archive.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.sourceRaw == sourceRaw && $0.paraCategoryRaw != archiveRaw
            },
            sortBy: [SortDescriptor(\Item.createdAt, order: .reverse)]
        )
        return descriptor
    }

    /// Recent items from any source, limited count.
    public static func recent(limit: Int) -> FetchDescriptor<Item> {
        let archiveRaw = PARACategory.archive.rawValue
        var descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.paraCategoryRaw != archiveRaw },
            sortBy: [SortDescriptor(\Item.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return descriptor
    }
}
