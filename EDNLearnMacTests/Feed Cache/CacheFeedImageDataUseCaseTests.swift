//
//  CacheFeedImageDataUseCaseTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 14/12/21.
//

import EDNLearnMac
import XCTest

class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_saveImageDataFromURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()

        sut.save(data, for: url) { _ in }
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }

    func test_saveImagDataFromURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed(), when: {
            let insertionError = anyError()
            store.completeInsertion(with: insertionError)
        })
    }

    func test_saveImageDataFromURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }

    func test_saveImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()

        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)

        var recieved = [LocalFeedImageDataLoader.SaveResult]()
        sut?.save(anyData(), for: anyURL()) { recieved.append($0) }

        sut = nil
        store.completeInsertionSuccessfully()
        XCTAssertTrue(recieved.isEmpty, "Expected no recieved results after instance has been deallocated")
    }

    // MARK: - Helpers

    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.save(anyData(), for: anyURL()) { recievedResult in
            switch (recievedResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(recievedError as LocalFeedImageDataLoader.SaveError),
                      .failure(expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(recievedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result:\(expectedResult), got \(recievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
