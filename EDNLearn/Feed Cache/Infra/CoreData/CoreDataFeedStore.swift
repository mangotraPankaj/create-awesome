//
//  CoreDataFeedStore.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 24/08/21.
//

import CoreData
import Foundation

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }

        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
}
