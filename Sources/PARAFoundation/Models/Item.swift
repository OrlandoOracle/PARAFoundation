import Foundation
import SwiftData

@Model
public final class Item {
    // Identity — no @Attribute(.unique) because CloudKit doesn't support unique constraints
    public var id: UUID = UUID()
    public var title: String?
    public var body: String = ""

    // Classification — stored as raw strings for predicate compatibility
    public var itemTypeRaw: String = "thought"
    public var paraCategoryRaw: String = "inbox"
    public var sourceRaw: String = "manual"
    public var soulValueRaw: String?
    public var tags: [String] = []

    // Timestamps
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    public var lastAccessedAt: Date = Date()

    // Decay control
    public var pinned: Bool = false
    public var archivedAt: Date?
    public var flaggedForReview: Bool = false
    public var flaggedAt: Date?

    // Relationships (lightweight, UUID-based)
    public var parentID: UUID?
    public var relatedIDs: [UUID] = []

    // Type-specific data stored as raw JSON
    public var metadataData: Data = Data()

    // Progressive Summarization (Distill Mode)
    public var distillLevel: Int = 0
    public var executiveSummary: String = ""

    // MARK: - Typed Enum Accessors

    @Transient
    public var itemType: ItemType {
        get { ItemType(rawValue: itemTypeRaw) ?? .thought }
        set { itemTypeRaw = newValue.rawValue }
    }

    @Transient
    public var paraCategory: PARACategory {
        get { PARACategory(rawValue: paraCategoryRaw) ?? .inbox }
        set { paraCategoryRaw = newValue.rawValue }
    }

    @Transient
    public var source: ItemSource {
        get { ItemSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    @Transient
    public var soulValue: SoulValue? {
        get { soulValueRaw.flatMap { SoulValue(rawValue: $0) } }
        set { soulValueRaw = newValue?.rawValue }
    }

    @Transient
    public var metadata: ItemMetadata {
        get {
            (try? JSONDecoder().decode(ItemMetadata.self, from: metadataData))
                ?? .thought(mood: nil)
        }
        set {
            metadataData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    public init(
        body: String,
        itemType: ItemType,
        source: ItemSource,
        title: String? = nil,
        paraCategory: PARACategory = .inbox,
        soulValue: SoulValue? = nil,
        tags: [String] = [],
        pinned: Bool = false,
        parentID: UUID? = nil,
        relatedIDs: [UUID] = [],
        metadata: ItemMetadata = .thought(mood: nil),
        distillLevel: Int = 0,
        executiveSummary: String = ""
    ) {
        self.id = UUID()
        self.body = body
        self.itemTypeRaw = itemType.rawValue
        self.sourceRaw = source.rawValue
        self.title = title
        self.paraCategoryRaw = paraCategory.rawValue
        self.soulValueRaw = soulValue?.rawValue
        self.tags = tags
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastAccessedAt = Date()
        self.pinned = pinned
        self.archivedAt = nil
        self.flaggedForReview = false
        self.flaggedAt = nil
        self.parentID = parentID
        self.relatedIDs = relatedIDs
        self.metadataData = (try? JSONEncoder().encode(metadata)) ?? Data()
        self.distillLevel = distillLevel
        self.executiveSummary = executiveSummary
    }
}
