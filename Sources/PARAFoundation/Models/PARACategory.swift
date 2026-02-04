import Foundation

public enum PARACategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case inbox
    case project
    case area
    case resource
    case archive

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .inbox:    return "Inbox"
        case .project:  return "Project"
        case .area:     return "Area"
        case .resource: return "Resource"
        case .archive:  return "Archive"
        }
    }
}
