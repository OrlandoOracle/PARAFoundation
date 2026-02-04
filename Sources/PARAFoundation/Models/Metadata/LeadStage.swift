import Foundation

public enum LeadStage: String, Codable, CaseIterable, Identifiable, Sendable {
    case new
    case contacted
    case quoted
    case negotiating
    case closedWon = "closed_won"
    case closedLost = "closed_lost"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .new:          return "New"
        case .contacted:    return "Contacted"
        case .quoted:       return "Quoted"
        case .negotiating:  return "Negotiating"
        case .closedWon:    return "Closed Won"
        case .closedLost:   return "Closed Lost"
        }
    }
}
