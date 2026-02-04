import Foundation

public enum SoulValue: String, Codable, CaseIterable, Identifiable, Sendable {
    case fitness
    case wizardry
    case sales
    case cocktailsSushi = "cocktails_sushi"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .fitness:        return "Fitness"
        case .wizardry:       return "Wizardry"
        case .sales:          return "Sales"
        case .cocktailsSushi: return "Craft Cocktails / Sushi"
        }
    }
}
