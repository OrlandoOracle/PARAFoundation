import Foundation

public enum ItemSource: String, Codable, CaseIterable, Identifiable, Sendable {
    case journalApp = "journal_app"
    case scheduleApp = "schedule_app"
    case insuranceApp = "insurance_app"
    case debbie
    case quickCapture = "quick_capture"
    case grimoire
    case manual

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .journalApp:    return "Journal"
        case .scheduleApp:   return "Schedule"
        case .insuranceApp:  return "Insurance"
        case .debbie:        return "DEBBIE"
        case .quickCapture:  return "Quick Capture"
        case .grimoire:      return "Grimoire"
        case .manual:        return "Manual"
        }
    }
}
