import Foundation
import SwiftData

/// Basic search across title, body, and tags.
public struct SearchHelpers {

    /// Search items by keyword across title and body.
    /// Tags are stored as an array so predicate-level search is limited;
    /// companion apps should post-filter for tag matches if needed.
    public static func search(keyword: String) -> FetchDescriptor<Item> {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                ($0.title?.localizedStandardContains(keyword) == true) ||
                $0.body.localizedStandardContains(keyword)
            },
            sortBy: [SortDescriptor(\Item.updatedAt, order: .reverse)]
        )
        return descriptor
    }

    /// Search within a specific PARA category.
    public static func search(keyword: String, in category: PARACategory) -> FetchDescriptor<Item> {
        let categoryRaw = category.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.paraCategoryRaw == categoryRaw &&
                (($0.title?.localizedStandardContains(keyword) == true) ||
                $0.body.localizedStandardContains(keyword))
            },
            sortBy: [SortDescriptor(\Item.updatedAt, order: .reverse)]
        )
        return descriptor
    }

    /// Search within a specific item type.
    public static func search(keyword: String, ofType type: ItemType) -> FetchDescriptor<Item> {
        let typeRaw = type.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> {
                $0.itemTypeRaw == typeRaw &&
                (($0.title?.localizedStandardContains(keyword) == true) ||
                $0.body.localizedStandardContains(keyword))
            },
            sortBy: [SortDescriptor(\Item.updatedAt, order: .reverse)]
        )
        return descriptor
    }
}
