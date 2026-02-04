import Foundation

/// User-configurable thresholds for the decay engine.
public struct DecayConfiguration: Sendable {
    /// Days before an inbox item auto-archives.
    public var inboxStaleDays: Int

    /// Days before a project item gets flagged for review.
    public var projectFlagDays: Int

    /// Days before a resource item auto-archives.
    public var resourceStaleDays: Int

    /// Days after flagging before auto-archiving (grace period).
    public var flagGraceDays: Int

    public init(
        inboxStaleDays: Int = 14,
        projectFlagDays: Int = 30,
        resourceStaleDays: Int = 60,
        flagGraceDays: Int = 7
    ) {
        self.inboxStaleDays = inboxStaleDays
        self.projectFlagDays = projectFlagDays
        self.resourceStaleDays = resourceStaleDays
        self.flagGraceDays = flagGraceDays
    }
}
