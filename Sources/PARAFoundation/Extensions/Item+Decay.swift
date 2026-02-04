import Foundation

extension Item {

    /// Days since this item was last accessed.
    public var daysSinceAccess: Int {
        Calendar.current.dateComponents([.day], from: lastAccessedAt, to: Date()).day ?? 0
    }

    /// Days since this item was created.
    public var daysSinceCreation: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }

    /// Whether this item is stale based on default thresholds.
    public var isStale: Bool {
        guard !pinned else { return false }
        let config = DecayConfiguration()
        switch paraCategory {
        case .inbox:    return daysSinceAccess >= config.inboxStaleDays
        case .project:  return daysSinceAccess >= config.projectFlagDays
        case .resource: return daysSinceAccess >= config.resourceStaleDays
        case .area:     return false
        case .archive:  return false
        }
    }

    /// Whether this item is immune to decay.
    public var isDecayImmune: Bool {
        pinned || paraCategory == .area || paraCategory == .archive
    }

    /// Update the last accessed timestamp (call when displaying item).
    public func touch() {
        lastAccessedAt = Date()
    }

    /// Promote item to a new PARA category.
    public func promote(to category: PARACategory) {
        paraCategory = category
        updatedAt = Date()
        lastAccessedAt = Date()
        flaggedForReview = false
        flaggedAt = nil
        if category == .archive {
            archivedAt = Date()
        }
        if category == .area {
            pinned = true
        }
    }
}
