import Testing
import Foundation
import SwiftData
@testable import PARAFoundation

@Suite("Item Tests")
struct ItemTests {

    // MARK: - Factory Method Tests

    @Test("Quick capture creates thought with defaults")
    func quickCapture() throws {
        let item = Item.quickCapture("Hello world")
        #expect(item.body == "Hello world")
        #expect(item.itemType == .thought)
        #expect(item.source == .quickCapture)
        #expect(item.paraCategory == .inbox)
        #expect(item.pinned == false)
        #expect(item.title == nil)
        #expect(item.metadata == .thought(mood: nil))
    }

    @Test("Journal entry sets foreground/background metadata")
    func journalEntry() throws {
        let item = Item.journalEntry(foreground: "Working out", background: "Feeling strong")
        #expect(item.itemType == .journal)
        #expect(item.source == .journalApp)
        #expect(item.body.contains("Working out"))
        #expect(item.body.contains("Feeling strong"))
        #expect(item.metadata == .journal(foreground: "Working out", background: "Feeling strong"))
    }

    @Test("Task factory sets pending status")
    func taskFactory() throws {
        let due = Date().addingTimeInterval(86400)
        let item = Item.task("Buy groceries", dueDate: due)
        #expect(item.itemType == .task)
        #expect(item.title == "Buy groceries")
        #expect(item.source == .manual)
        #expect(item.metadata == .task(status: .pending, dueDate: due))
    }

    @Test("Lead factory sets project category and new stage")
    func leadFactory() throws {
        let item = Item.lead(ghlID: "abc123", clientName: "John Doe", clientPhone: "555-1234")
        #expect(item.itemType == .lead)
        #expect(item.paraCategory == .project)
        #expect(item.title == "John Doe")
        #expect(item.source == .insuranceApp)
        if case .lead(let ghlID, let stage, _, _, let name, let phone, _) = item.metadata {
            #expect(ghlID == "abc123")
            #expect(stage == .new)
            #expect(name == "John Doe")
            #expect(phone == "555-1234")
        } else {
            Issue.record("Expected lead metadata")
        }
    }

    @Test("Show note factory sets wizardry soul value")
    func showNoteFactory() throws {
        let item = Item.showNote("Card Trick Finale", venue: "Comedy Store")
        #expect(item.itemType == .showNote)
        #expect(item.soulValue == .wizardry)
        #expect(item.paraCategory == .project)
        if case .showNote(_, let venue, _, _) = item.metadata {
            #expect(venue == "Comedy Store")
        } else {
            Issue.record("Expected showNote metadata")
        }
    }

    @Test("Mobile capture creates thought with grimoireMobile source")
    func mobileCapture() throws {
        let item = Item.mobileCapture("On the go thought", tags: ["ideas", "mobile"])
        #expect(item.body == "On the go thought")
        #expect(item.itemType == .thought)
        #expect(item.source == .grimoireMobile)
        #expect(item.sourceRaw == "grimoire_mobile")
        #expect(item.paraCategory == .inbox)
        #expect(item.tags == ["ideas", "mobile"])
    }

    @Test("grimoireMobile source has correct display name")
    func grimoireMobileDisplayName() throws {
        #expect(ItemSource.grimoireMobile.displayName == "Grimoire Mobile")
        #expect(ItemSource.grimoireMobile.rawValue == "grimoire_mobile")
    }

    @Test("System log goes directly to archive")
    func systemLog() throws {
        let item = Item.systemLog(action: "Decay ran", triggeredBy: "scheduler")
        #expect(item.itemType == .log)
        #expect(item.paraCategory == .archive)
        #expect(item.source == .debbie)
        #expect(item.pinned == false)
        #expect(item.metadata == .log(action: "Decay ran", triggeredBy: "scheduler"))
    }

    // MARK: - Touch and Timestamps

    @Test("touch() updates lastAccessedAt")
    func touch() async throws {
        let item = Item.quickCapture("test")
        let originalAccess = item.lastAccessedAt
        // Small delay to ensure time difference
        try await Task.sleep(for: .milliseconds(50))
        item.touch()
        #expect(item.lastAccessedAt > originalAccess)
    }

    // MARK: - Promote

    @Test("promote to area auto-pins")
    func promoteToArea() throws {
        let item = Item.quickCapture("Health tracking")
        #expect(item.pinned == false)
        item.promote(to: .area)
        #expect(item.paraCategory == .area)
        #expect(item.pinned == true)
        #expect(item.flaggedForReview == false)
        #expect(item.flaggedAt == nil)
    }

    @Test("promote to archive sets archivedAt")
    func promoteToArchive() throws {
        let item = Item.quickCapture("Old stuff")
        #expect(item.archivedAt == nil)
        item.promote(to: .archive)
        #expect(item.paraCategory == .archive)
        #expect(item.archivedAt != nil)
    }

    @Test("promote clears flagged state")
    func promoteClearsFlagged() throws {
        let item = Item(body: "test", itemType: .task, source: .manual, paraCategory: .project)
        item.flaggedForReview = true
        item.flaggedAt = Date()
        item.promote(to: .project)
        #expect(item.flaggedForReview == false)
        #expect(item.flaggedAt == nil)
    }

    // MARK: - Metadata Codable Round-Trip

    @Test("ItemMetadata thought round-trips correctly")
    func metadataThoughtCodable() throws {
        let original = ItemMetadata.thought(mood: "happy")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ItemMetadata.self, from: data)
        #expect(decoded == original)
    }

    @Test("ItemMetadata journal round-trips correctly")
    func metadataJournalCodable() throws {
        let original = ItemMetadata.journal(foreground: "coding", background: "focused")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ItemMetadata.self, from: data)
        #expect(decoded == original)
    }

    @Test("ItemMetadata reference round-trips correctly")
    func metadataReferenceCodable() throws {
        let original = ItemMetadata.reference(url: "https://example.com", sourceTitle: "Example")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ItemMetadata.self, from: data)
        #expect(decoded == original)
    }

    @Test("ItemMetadata task round-trips correctly")
    func metadataTaskCodable() throws {
        let date = Date()
        let original = ItemMetadata.task(status: .inProgress, dueDate: date)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ItemMetadata.self, from: data)
        #expect(decoded == original)
    }

    @Test("ItemMetadata lead round-trips correctly")
    func metadataLeadCodable() throws {
        let original = ItemMetadata.lead(
            ghlID: "abc",
            stage: .quoted,
            carrier: "Aetna",
            premium: Decimal(450),
            clientName: "John",
            clientPhone: "555-1234",
            clientEmail: "john@example.com"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ItemMetadata.self, from: data)
        #expect(decoded == original)
    }

    @Test("ItemMetadata showNote round-trips correctly")
    func metadataShowNoteCodable() throws {
        let date = Date()
        let original = ItemMetadata.showNote(
            showDate: date,
            venue: "Comedy Store",
            segment: .closer,
            duration: 300.0
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ItemMetadata.self, from: data)
        #expect(decoded == original)
    }

    @Test("ItemMetadata log round-trips correctly")
    func metadataLogCodable() throws {
        let original = ItemMetadata.log(action: "decay_run", triggeredBy: "timer")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ItemMetadata.self, from: data)
        #expect(decoded == original)
    }

    @Test("ItemMetadata JSON uses type discriminator")
    func metadataJSONFormat() throws {
        let metadata = ItemMetadata.lead(
            ghlID: "abc123",
            stage: .quoted,
            carrier: "Aetna",
            premium: Decimal(450),
            clientName: "John Doe",
            clientPhone: nil,
            clientEmail: nil
        )
        let data = try JSONEncoder().encode(metadata)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["type"] as? String == "lead")
        #expect(json["ghlID"] as? String == "abc123")
        #expect(json["stage"] as? String == "quoted")
        #expect(json["carrier"] as? String == "Aetna")
    }

    @Test("ItemMetadata thought with nil mood uses type discriminator")
    func metadataThoughtNilJSON() throws {
        let metadata = ItemMetadata.thought(mood: nil)
        let data = try JSONEncoder().encode(metadata)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["type"] as? String == "thought")
    }
}
