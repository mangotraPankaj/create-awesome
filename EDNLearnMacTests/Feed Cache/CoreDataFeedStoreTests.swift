//
//  CoreDataFeedStoreTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 23/08/21.
//

import EDNLearnMac
import XCTest

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDelieversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {}

    func test_insert_deliversNoErrorOnEmptyCache() {}

    func test_insert_deliversNoErrorOnNonEmptyCache() {}

    func test_delete_deliversNoErrorOnEmptyCache() {}

    func test_delete_hasNoSideEffectsOnEmptyCache() {}

    func test_delete_emptiesPreviouslyInsertedCache() {}

    func test_delete_deliversNoErrorOnNonEmptyCache() {}

    func test_storeSideEffects_runSerially() {}

    // MARK: Helpers

    /// Make StoreURL an explicit dependency so we can inject test-specific URLs(such as '/dev/null' to avoid sharing state with production (and other tests)
    /// '/dev/null' discards all data written to it, but reports that the writes are successful. The writes are ignored but core data still works with in-memory object graph.
    /// This would help us to avoid side-effects which may occur due to artefacts which may remain from tests , since dev/null does not write to sqlite

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
