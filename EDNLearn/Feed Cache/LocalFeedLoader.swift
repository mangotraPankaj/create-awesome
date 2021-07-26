//
//  LocalFeedLoader.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 15/07/21.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private var currentDate: () -> Date
    public typealias saveResult = Error?

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func save(_ feed: [FeedImage], completion: @escaping (saveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionerror = error {
                completion(cacheDeletionerror)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }

    public func load(completion: @escaping (Error?) -> Void) {
        store.retrieve(completion: completion)
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping (saveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
