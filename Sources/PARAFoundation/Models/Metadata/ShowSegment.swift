import Foundation

public enum ShowSegment: String, Codable, CaseIterable, Identifiable, Sendable {
    case opener
    case middle
    case closer
    case standalone

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .opener:     return "Opener"
        case .middle:     return "Middle"
        case .closer:     return "Closer"
        case .standalone: return "Standalone"
        }
    }
}
