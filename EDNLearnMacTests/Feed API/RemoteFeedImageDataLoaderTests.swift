//
//  RemoteFeedImageDataLoader.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 29/11/21.
//

import EDNLearnMac
import XCTest

class RemoteFeedImageDataLoader {
    enum Error: Swift.Error {
        case invalidData
    }

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
        let wrapped: HTTPClientTask

        func cancel() {
            wrapped.cancel()
        }
    }

    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return HTTPTaskWrapper(wrapped: client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.invalidData))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
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

    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)

        expect(sut, toCompleteWithResult: .failure(clientError), when: {
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

    private func anyData() -> Data {
        return Data("anydata".utf8)
    }

    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
}

private class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        func cancel() {}
    }

    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task()
    }

    func post(_: Data, to _: URL, completion _: @escaping (HTTPClient.Result) -> Void) {}

    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!

        messages[index].completion(.success((data, response)))
    }
}
