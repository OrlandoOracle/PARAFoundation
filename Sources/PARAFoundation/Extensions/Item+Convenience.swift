import Foundation

extension Item {

    /// Quick capture — minimal input, everything else defaults.
    public static func quickCapture(_ text: String, source: ItemSource = .quickCapture) -> Item {
        Item(body: text, itemType: .thought, source: source)
    }

    /// Mobile capture — creates a thought from Grimoire Mobile.
    public static func mobileCapture(_ text: String, tags: [String] = []) -> Item {
        Item(body: text, itemType: .thought, source: .grimoireMobile, tags: tags)
    }

    /// Journal entry with foreground/background.
    public static func journalEntry(
        foreground: String,
        background: String,
        soulValue: SoulValue? = nil,
        source: ItemSource = .journalApp
    ) -> Item {
        Item(
            body: "FG: \(foreground)\nBG: \(background)",
            itemType: .journal,
            source: source,
            soulValue: soulValue,
            metadata: .journal(foreground: foreground, background: background)
        )
    }

    /// New task.
    public static func task(
        _ title: String,
        body: String = "",
        dueDate: Date? = nil,
        parentID: UUID? = nil,
        source: ItemSource = .manual
    ) -> Item {
        Item(
            body: body,
            itemType: .task,
            source: source,
            title: title,
            parentID: parentID,
            metadata: .task(status: .pending, dueDate: dueDate)
        )
    }

    /// New lead from GoHighLevel.
    public static func lead(
        ghlID: String,
        clientName: String,
        clientPhone: String? = nil,
        clientEmail: String? = nil,
        source: ItemSource = .insuranceApp
    ) -> Item {
        Item(
            body: "",
            itemType: .lead,
            source: source,
            title: clientName,
            paraCategory: .project,
            metadata: .lead(
                ghlID: ghlID,
                stage: .new,
                carrier: nil,
                premium: nil,
                clientName: clientName,
                clientPhone: clientPhone,
                clientEmail: clientEmail
            )
        )
    }

    /// Show note.
    public static func showNote(
        _ title: String,
        body: String = "",
        showDate: Date? = nil,
        venue: String? = nil,
        segment: ShowSegment? = nil
    ) -> Item {
        Item(
            body: body,
            itemType: .showNote,
            source: .manual,
            title: title,
            paraCategory: .project,
            soulValue: .wizardry,
            metadata: .showNote(
                showDate: showDate,
                venue: venue,
                segment: segment,
                duration: nil
            )
        )
    }

    /// System log entry (auto-generated, never manually created).
    public static func systemLog(action: String, triggeredBy: String) -> Item {
        Item(
            body: action,
            itemType: .log,
            source: .debbie,
            paraCategory: .archive,
            pinned: false,
            metadata: .log(action: action, triggeredBy: triggeredBy)
        )
    }
}
