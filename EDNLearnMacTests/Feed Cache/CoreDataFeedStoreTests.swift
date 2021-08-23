//
//  CoreDataFeedStoreTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 23/08/21.
//

import EDNLearnMac
import XCTest

class CoreDataFeedStore: FeedStore {
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        <#code#>
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        <#code#>
    }
    

    func retrieve(completion: @escaping RetrievalCompletion) { completion(.empty) }
}

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDelieversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsEmptyCache() {}

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {}

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {}

    func test_insert_overridesPreviouslyInsertedCacheValues() {}

    func test_insert_deliversNoErrorOnEmptyCache() {}

    func test_insert_deliversNoErrorOnNonEmptyCache() {}

    func test_delete_deliversNoErrorOnEmptyCache() {}

    func test_delete_hasNoSideEffectsOnEmptyCache() {}

    func test_delete_emptiesPreviouslyInsertedCache() {}

    func test_delete_deliversNoErrorOnNonEmptyCache() {}

    func test_storeSideEffects_runSerially() {}

    // MARK: Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
