//
//  CoreDataFeedStore.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 24/08/21.
//

import CoreData
import Foundation

public class CoreDataFeedStore: FeedStore {
    public init() {}

    public func deleteCacheFeed(completion _: @escaping DeletionCompletion) {}

    public func insert(_: [LocalFeedImage], timestamp _: Date, completion _: @escaping InsertionCompletion) {}

    public func retrieve(completion: @escaping RetrievalCompletion) { completion(.empty) }
}

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date?
    @NSManaged var feed: NSOrderedSet?
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL?
    @NSManaged var cache: ManagedCache?
}
