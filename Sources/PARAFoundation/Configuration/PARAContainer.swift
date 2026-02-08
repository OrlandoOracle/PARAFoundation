import Foundation
import SwiftData

/// Factory that creates a properly configured ModelContainer for the PARA database.
public struct PARAContainer {

    /// CloudKit container identifier.
    /// All companion apps MUST use this same identifier.
    public static let cloudKitContainerID = CloudKitConfig.containerIdentifier

    /// Create the shared ModelContainer with CloudKit sync.
    /// Call this once at app launch in each companion app.
    public static func create() throws -> ModelContainer {
        let schema = Schema([Item.self])
        let config = ModelConfiguration(
            "PARAFoundation",
            schema: schema,
            cloudKitDatabase: .private(CloudKitConfig.containerIdentifier)
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Create a local-only ModelContainer (no CloudKit).
    /// Use as fallback when CloudKit container is not yet provisioned.
    public static func createLocal() throws -> ModelContainer {
        let schema = Schema([Item.self])
        let config = ModelConfiguration(
            "PARAFoundation",
            schema: schema,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Create an in-memory container for testing and previews.
    public static func createInMemory() throws -> ModelContainer {
        let schema = Schema([Item.self])
        let config = ModelConfiguration(
            "PARAFoundation",
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: [config])
    }
}
