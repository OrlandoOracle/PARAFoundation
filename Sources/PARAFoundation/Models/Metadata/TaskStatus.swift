import Foundation

public enum TaskStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case pending
    case inProgress = "in_progress"
    case done
    case cancelled

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .pending:    return "Pending"
        case .inProgress: return "In Progress"
        case .done:       return "Done"
        case .cancelled:  return "Cancelled"
        }
    }
}
