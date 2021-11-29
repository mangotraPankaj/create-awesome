//
//  RemoteFeedImageDataLoader.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 29/11/21.
//

import EDNLearnMac
import XCTest

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    func loadImageData(from url: URL, completion _: @escaping (Any) -> Void) {
        client.get(from: url) { _ in }
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

    private func makeSUT(url _: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        func post(_: Data, to _: URL, completion _: @escaping (HTTPClient.Result) -> Void) {}

        var requestedURLs = [URL]()
        func get(from url: URL, completion _: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}
