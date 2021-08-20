//
//  CodableFeedStoreTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 10/08/21.
//

import EDNLearnMac
import XCTest

typealias FailableFeedStore = FailableInsertFeedStoreSpecs & FailableRetrieveFeedStoreSpecs & FailableDeleteFeedStoreSpecs

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    /// Teardown and setup methods are written so that the residual artifacts which are written while inserting gets cleaned up otherwise test_retrieve_deliversEmptyOnEmptyCache fails since there would be data present in the cache.

    /// Teardown method is not called if the execution stops midway while test is being run. For e.g. - If you put a breakpoint at line 31 and when breakpoint hits and execution is stopped, insertion would have happened but teardown would not be called.
    /// Hence we have to clear the artifacts both in teardown and setup which are called after and at start of the test respectively.

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(anyError()))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(anyError()))
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        insert((uniqueImageFeed().local, Date()), to: sut)

        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        insert((latestFeed, latestTimeStamp), to: sut)
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimeStamp))
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        let insertionError = insert((feed, timestamp), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)
        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        insert((uniqueImageFeed().local, Date()), to: sut)

        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to suceed")
    }

    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "operation 2")
        sut.deleteCacheFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but the operations finished in the wrong order")
    }

    // - MARK: Helpers

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath,
                         line: UInt = #line) -> FeedStore
    {
        let sut = CodableFeedStore(storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
