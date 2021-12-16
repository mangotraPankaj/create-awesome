//
//  CoreDataFeedImageDataStoreTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 16/12/21.
//

import EDNLearnMac
import XCTest

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_: Data, for _: URL, completion _: @escaping (FeedImageDataStore.InsertionResult) -> Void) {}

    public func retrieve(dataForURL _: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }

    // MARK: Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }

    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        sut.retrieve(dataForURL: url) { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedData), .success(expectedData)):
                XCTAssertEqual(recievedData, expectedData, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(recievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
