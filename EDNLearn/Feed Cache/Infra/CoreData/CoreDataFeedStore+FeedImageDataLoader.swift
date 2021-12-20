//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 20/12/21.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_: Data, for _: URL, completion _: @escaping (FeedImageDataStore.InsertionResult) -> Void) {}

    public func retrieve(dataForURL _: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
