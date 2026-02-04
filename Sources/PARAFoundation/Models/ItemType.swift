import Foundation

public enum ItemType: String, Codable, CaseIterable, Identifiable, Sendable {
    case thought
    case journal
    case reference
    case task
    case lead
    case showNote = "show_note"
    case log

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .thought:   return "Thought"
        case .journal:   return "Journal"
        case .reference: return "Reference"
        case .task:      return "Task"
        case .lead:      return "Lead"
        case .showNote:  return "Show Note"
        case .log:       return "Log"
        }
    }
}
