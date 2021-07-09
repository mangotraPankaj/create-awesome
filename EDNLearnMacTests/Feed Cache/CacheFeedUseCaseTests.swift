//
//  CacheFeedUseCaseTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 09/07/21.
//

import XCTest

class LoadFeedLoader {
    init(store: FeedStore) {}
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LoadFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
