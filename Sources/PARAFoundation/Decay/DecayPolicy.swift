import Foundation

/// Maps each PARA category to its decay behavior.
public struct DecayPolicy: Sendable {
    public enum Action: Sendable {
        /// Move directly to archive.
        case archive
        /// Flag for review, give grace period, then archive.
        case flagForReview
        /// No decay applies (areas, already archived).
        case none
    }

    public static func action(for category: PARACategory) -> Action {
        switch category {
        case .inbox:    return .archive
        case .project:  return .flagForReview
        case .area:     return .none
        case .resource: return .archive
        case .archive:  return .none
        }
    }
}
