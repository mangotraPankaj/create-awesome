//
//  LocalFeedImageDataLoaderTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 07/12/21.
//

import EDNLearnMac
import XCTest

class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }

    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyError()
            store.completeRetrieval(with: retrievalError)
        })
    }

    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)

        })
    }

    func test_loadImageDataFromURL_deliversStoreDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        expect(sut, toCompleteWith: .success(foundData), when: {
            store.completeRetrieval(with: foundData)

        })
    }

    func test_loadImageDataFromURL_doesNotDeliverResultsAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        var recieved = [FeedImageDataLoader.Result]()

        let task = sut.loadImageData(from: anyURL()) { recieved.append($0) }

        task.cancel()

        store.completeRetrieval(with: foundData)
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyError())

        XCTAssertTrue(recieved.isEmpty, "Expecting no recieved results after cancelling the task")
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()

        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)

        var recieved = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { recieved.append($0) }

        sut = nil
        store.completeRetrieval(with: anyData())
        XCTAssertTrue(recieved.isEmpty, "Expected no recieved results after instance has been deallocated")
    }

    // MARK: - Helpers

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL()) { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedResult), .success(expectedResult)):
                XCTAssertEqual(recievedResult, expectedResult, file: file, line: line)
            case let (.failure(recievedError as LocalFeedImageDataLoader.LoadError),
                      .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(recievedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result:\(expectedResult), got \(recievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }

    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }

    private func makeSUT(currentDate _: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
