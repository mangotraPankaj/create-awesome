//
//  CoreDataFeedStore.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 24/08/21.
//

import CoreData
import Foundation

public final class CoreDataFeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL) throws {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }

    /// The pros are that we enforce the whole Core Data stack is deallocated along with the CoreDataFeedStore class. This way, we prevent issues with Core Data operations running after the CoreDataFeedStore instance is deallocated (which can lead to unexpected runtime behavior!).

    /// The cons are that deallocating CoreDataFeedStore instances can become expensive operations since it locks until the Core Data stack is deallocated (which may take some time). But I believe it's a good tradeoff to ensure there's no unexpected behavior at runtime.
    ///

    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove(_:))
        }
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }
}
