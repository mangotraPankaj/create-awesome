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

    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let url = URL(string: "http://a-url.com")!

        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
    }

    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        let url = anyURL()

        let op1 = expectation(description: "operation 1")
        sut.insert([localImage(url: url)], timestamp: Date()) { _ in
            op1.fulfill()
        }

        let op2 = expectation(description: "operation 2")
        sut.insert(anyData(), for: url) { _ in op2.fulfill() }

        let op3 = expectation(description: "operation 3")
        sut.insert(anyData(), for: url) { _ in op3.fulfill() }

        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    }

    // MARK: Helpers

    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for cache insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error:\(error)", file: file, line: line)
                exp.fulfill()

            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("failed to insert \(data) with error: \(error)", file: file, line: line)
                    }
                    exp.fulfill()
                }
            }
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
