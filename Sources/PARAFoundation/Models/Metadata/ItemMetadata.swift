import Foundation

public enum ItemMetadata: Codable, Equatable, Sendable {
    case thought(mood: String?)
    case journal(foreground: String, background: String)
    case reference(url: String?, sourceTitle: String?)
    case task(status: TaskStatus, dueDate: Date?)
    case lead(
        ghlID: String,
        stage: LeadStage,
        carrier: String?,
        premium: Decimal?,
        clientName: String?,
        clientPhone: String?,
        clientEmail: String?
    )
    case showNote(
        showDate: Date?,
        venue: String?,
        segment: ShowSegment?,
        duration: TimeInterval?
    )
    case log(action: String, triggeredBy: String)

    // MARK: - Type discriminator

    private enum MetadataType: String, Codable {
        case thought
        case journal
        case reference
        case task
        case lead
        case showNote = "show_note"
        case log
    }

    // MARK: - CodingKeys

    private enum CodingKeys: String, CodingKey {
        case type
        // thought
        case mood
        // journal
        case foreground, background
        // reference
        case url, sourceTitle
        // task
        case status, dueDate
        // lead
        case ghlID, stage, carrier, premium, clientName, clientPhone, clientEmail
        // showNote
        case showDate, venue, segment, duration
        // log
        case action, triggeredBy
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MetadataType.self, forKey: .type)

        switch type {
        case .thought:
            let mood = try container.decodeIfPresent(String.self, forKey: .mood)
            self = .thought(mood: mood)

        case .journal:
            let foreground = try container.decode(String.self, forKey: .foreground)
            let background = try container.decode(String.self, forKey: .background)
            self = .journal(foreground: foreground, background: background)

        case .reference:
            let url = try container.decodeIfPresent(String.self, forKey: .url)
            let sourceTitle = try container.decodeIfPresent(String.self, forKey: .sourceTitle)
            self = .reference(url: url, sourceTitle: sourceTitle)

        case .task:
            let status = try container.decode(TaskStatus.self, forKey: .status)
            let dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
            self = .task(status: status, dueDate: dueDate)

        case .lead:
            let ghlID = try container.decode(String.self, forKey: .ghlID)
            let stage = try container.decode(LeadStage.self, forKey: .stage)
            let carrier = try container.decodeIfPresent(String.self, forKey: .carrier)
            let premium = try container.decodeIfPresent(Decimal.self, forKey: .premium)
            let clientName = try container.decodeIfPresent(String.self, forKey: .clientName)
            let clientPhone = try container.decodeIfPresent(String.self, forKey: .clientPhone)
            let clientEmail = try container.decodeIfPresent(String.self, forKey: .clientEmail)
            self = .lead(
                ghlID: ghlID,
                stage: stage,
                carrier: carrier,
                premium: premium,
                clientName: clientName,
                clientPhone: clientPhone,
                clientEmail: clientEmail
            )

        case .showNote:
            let showDate = try container.decodeIfPresent(Date.self, forKey: .showDate)
            let venue = try container.decodeIfPresent(String.self, forKey: .venue)
            let segment = try container.decodeIfPresent(ShowSegment.self, forKey: .segment)
            let duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
            self = .showNote(showDate: showDate, venue: venue, segment: segment, duration: duration)

        case .log:
            let action = try container.decode(String.self, forKey: .action)
            let triggeredBy = try container.decode(String.self, forKey: .triggeredBy)
            self = .log(action: action, triggeredBy: triggeredBy)
        }
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .thought(let mood):
            try container.encode(MetadataType.thought, forKey: .type)
            try container.encodeIfPresent(mood, forKey: .mood)

        case .journal(let foreground, let background):
            try container.encode(MetadataType.journal, forKey: .type)
            try container.encode(foreground, forKey: .foreground)
            try container.encode(background, forKey: .background)

        case .reference(let url, let sourceTitle):
            try container.encode(MetadataType.reference, forKey: .type)
            try container.encodeIfPresent(url, forKey: .url)
            try container.encodeIfPresent(sourceTitle, forKey: .sourceTitle)

        case .task(let status, let dueDate):
            try container.encode(MetadataType.task, forKey: .type)
            try container.encode(status, forKey: .status)
            try container.encodeIfPresent(dueDate, forKey: .dueDate)

        case .lead(let ghlID, let stage, let carrier, let premium, let clientName, let clientPhone, let clientEmail):
            try container.encode(MetadataType.lead, forKey: .type)
            try container.encode(ghlID, forKey: .ghlID)
            try container.encode(stage, forKey: .stage)
            try container.encodeIfPresent(carrier, forKey: .carrier)
            try container.encodeIfPresent(premium, forKey: .premium)
            try container.encodeIfPresent(clientName, forKey: .clientName)
            try container.encodeIfPresent(clientPhone, forKey: .clientPhone)
            try container.encodeIfPresent(clientEmail, forKey: .clientEmail)

        case .showNote(let showDate, let venue, let segment, let duration):
            try container.encode(MetadataType.showNote, forKey: .type)
            try container.encodeIfPresent(showDate, forKey: .showDate)
            try container.encodeIfPresent(venue, forKey: .venue)
            try container.encodeIfPresent(segment, forKey: .segment)
            try container.encodeIfPresent(duration, forKey: .duration)

        case .log(let action, let triggeredBy):
            try container.encode(MetadataType.log, forKey: .type)
            try container.encode(action, forKey: .action)
            try container.encode(triggeredBy, forKey: .triggeredBy)
        }
    }
}
