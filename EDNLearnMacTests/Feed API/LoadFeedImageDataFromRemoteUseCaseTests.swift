//
//  RemoteFeedImageDataLoader.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 29/11/21.
//

import EDNLearnMac
import XCTest

class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadImageDataFromURL_requestDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!

        let (sut, client) = makeSUT(url: url)
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataFromURLTwice_requestDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!

        let (sut, client) = makeSUT(url: url)
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)

        expect(sut, toCompleteWithResult: failure(.connectivity), when: {
            client.complete(with: clientError)
        })
    }

    func test_loadImageDataFromURL_deliversErrorOnNon200HTTPResponse() {
        // Arrange
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in

            expect(sut, toCompleteWithResult: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }

    func test_loadImageDataFromURL_deliverInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }

    func test_loadImageDataFromURL_deliversRecievedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()

        let nonEmptyData = Data("non empty Data".utf8)

        expect(sut, toCompleteWithResult: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }

        sut = nil

        client.complete(withStatusCode: 200, data: anyData())
        XCTAssertTrue(capturedResults.isEmpty)
    }

    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-given-url.com")!

        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until the task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after the teask is cancelled")
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()

        let nonEmptyData = Data("non epmty data".utf8)
        var recieved = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { recieved.append($0) }
        task.cancel()

        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyError())

        XCTAssertTrue(recieved.isEmpty, "Expected no results after cancelling the task")
    }

    // MARK: - Helper methods

    private func makeSUT(url _: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func expect(_ sut: RemoteFeedImageDataLoader,
                        toCompleteWithResult expectedResult: FeedImageDataLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line)
    {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "wait for load completion")

        sut.loadImageData(from: url) { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedData), .success(expectedData)):
                XCTAssertEqual(recievedData, expectedData, file: file, line: line)
            case let (.failure(recievedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(recievedError, expectedError, file: file, line: line)
            case let (.failure(recievedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(recievedError, expectedError, file: file, line: line)
            default:
                XCTFail("expected result:\(expectedResult) got \(recievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
}
