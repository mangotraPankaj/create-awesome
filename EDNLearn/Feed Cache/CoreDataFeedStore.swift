//
//  CoreDataFeedStore.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 24/08/21.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    public init() {}
    public func deleteCacheFeed(completion _: @escaping DeletionCompletion) {}

    public func insert(_: [LocalFeedImage], timestamp _: Date, completion _: @escaping InsertionCompletion) {}

    public func retrieve(completion: @escaping RetrievalCompletion) { completion(.empty) }
}
