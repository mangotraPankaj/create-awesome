//
//  CoreDataFeedImageDataStoreTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 16/12/21.
//

import EDNLearnMac
import XCTest

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }

    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "https://a-url.com")!
        let nonMatchingURL = URL(string: "https://another-url.com")!

        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }

    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()

        let storedData = anyData()
        let matchingURL = URL(string: "https://a-url.com")!

        insert(storedData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
    }

    // MARK: Helpers

    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for cache insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error:\(error)", file: file, line: line)

            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("failed to insert \(data) with error: \(error)", file: file, line: line)
                    }
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }

    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
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
