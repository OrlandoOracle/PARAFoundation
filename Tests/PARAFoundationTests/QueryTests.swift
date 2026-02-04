import Testing
import Foundation
import SwiftData
@testable import PARAFoundation

@Suite("Query Tests")
struct QueryTests {

    private func makeContainer() throws -> ModelContainer {
        try PARAContainer.createInMemory()
    }

    // MARK: - Inbox Query

    @Test("inbox() returns only inbox items sorted newest first")
    @MainActor
    func inboxQuery() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let older = Item.quickCapture("Older")
        older.createdAt = Date().addingTimeInterval(-3600)
        let newer = Item.quickCapture("Newer")

        let project = Item(body: "Project", itemType: .task, source: .manual, paraCategory: .project)

        context.insert(older)
        context.insert(newer)
        context.insert(project)
        try context.save()

        let results = try context.fetch(ItemQueries.inbox())
        #expect(results.count == 2)
        #expect(results[0].body == "Newer")
        #expect(results[1].body == "Older")
    }

    // MARK: - Active Projects

    @Test("activeProjects() excludes archived and flagged items")
    @MainActor
    func activeProjectsQuery() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let active = Item(body: "Active", itemType: .task, source: .manual, paraCategory: .project)
        let flagged = Item(body: "Flagged", itemType: .task, source: .manual, paraCategory: .project)
        flagged.flaggedForReview = true
        let archived = Item(body: "Archived", itemType: .task, source: .manual, paraCategory: .archive)

        context.insert(active)
        context.insert(flagged)
        context.insert(archived)
        try context.save()

        let results = try context.fetch(ItemQueries.activeProjects())
        #expect(results.count == 1)
        #expect(results[0].body == "Active")
    }

    // MARK: - By Type

    @Test("byType() filters correctly and excludes archived")
    @MainActor
    func byTypeQuery() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let thought1 = Item.quickCapture("Thought 1")
        let thought2 = Item.quickCapture("Thought 2")
        thought2.paraCategory = .archive
        let task = Item.task("Task 1")

        context.insert(thought1)
        context.insert(thought2)
        context.insert(task)
        try context.save()

        let results = try context.fetch(ItemQueries.byType(.thought))
        #expect(results.count == 1)
        #expect(results[0].body == "Thought 1")
    }

    // MARK: - Tasks by Status

    @Test("tasks(status:) returns only task items")
    @MainActor
    func tasksQuery() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let pendingTask = Item.task("Pending task")
        let thought = Item.quickCapture("Not a task")

        context.insert(pendingTask)
        context.insert(thought)
        try context.save()

        let results = try context.fetch(ItemQueries.tasks(status: .pending))
        #expect(results.count == 1)
        #expect(results[0].title == "Pending task")
    }

    // MARK: - Children

    @Test("children(of:) returns correct parent-child relationships")
    @MainActor
    func childrenQuery() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let parent = Item.task("Parent task")
        let child1 = Item.task("Child 1", parentID: parent.id)
        let child2 = Item.task("Child 2", parentID: parent.id)
        let unrelated = Item.task("Unrelated")

        context.insert(parent)
        context.insert(child1)
        context.insert(child2)
        context.insert(unrelated)
        try context.save()

        let results = try context.fetch(ItemQueries.children(of: parent.id))
        #expect(results.count == 2)
    }

    // MARK: - Search

    @Test("search(keyword:) matches across title and body")
    @MainActor
    func searchQuery() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item1 = Item(body: "Learn Swift programming", itemType: .reference, source: .manual, title: "Tutorial")
        let item2 = Item(body: "Buy milk", itemType: .task, source: .manual, title: "Swift errand")
        let item3 = Item(body: "Go for a run", itemType: .thought, source: .manual)

        context.insert(item1)
        context.insert(item2)
        context.insert(item3)
        try context.save()

        let results = try context.fetch(SearchHelpers.search(keyword: "Swift"))
        #expect(results.count == 2)
    }

    // MARK: - Recent with Limit

    @Test("recent(limit:) respects the limit parameter")
    @MainActor
    func recentQuery() throws {
        let container = try makeContainer()
        let context = container.mainContext

        for i in 0..<10 {
            let item = Item.quickCapture("Item \(i)")
            context.insert(item)
        }
        try context.save()

        let results = try context.fetch(ItemQueries.recent(limit: 3))
        #expect(results.count == 3)
    }
}
