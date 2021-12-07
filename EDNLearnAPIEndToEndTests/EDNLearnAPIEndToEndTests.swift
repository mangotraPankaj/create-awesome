//
//  EDNLearnAPIEndToEndTests.swift
//  EDNLearnAPIEndToEndTests
//
//  Created by Pankaj Mangotra on 25/06/21.
//

import EDNLearnMac
import XCTest

class EDNLearnAPIEndToEndTests: XCTestCase {
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(imageFeed):
            XCTAssertEqual(imageFeed.count, 8, "Expected 8 images in the test account imagefeed")

            // We can enumerate this way using for loop or calling assertion directly like below
            /* items.enumerated().forEach { index, item in
                 XCTAssertEqual(item, expectedItem(at: index),"unexpected items value at \(index)")
             } */
            XCTAssertEqual(imageFeed[0], expectedImage(at: 0))
            XCTAssertEqual(imageFeed[1], expectedImage(at: 1))
            XCTAssertEqual(imageFeed[2], expectedImage(at: 2))
            XCTAssertEqual(imageFeed[3], expectedImage(at: 3))
            XCTAssertEqual(imageFeed[4], expectedImage(at: 4))
            XCTAssertEqual(imageFeed[5], expectedImage(at: 5))
            XCTAssertEqual(imageFeed[6], expectedImage(at: 6))
            XCTAssertEqual(imageFeed[7], expectedImage(at: 7))

        case let .failure(error):
            XCTFail("Expected successful feed results, Got \(error) insted")
        default:
            XCTFail("Expected successful feed results, got no result instead")
        }
    }

    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non empty image data")
        case let .failure(error)?:
            XCTFail("expected successful image data result, got \(error) instead")
        default:
            XCTFail("expected successful image data result, got no result instead")
        }
    }

    // MARK: - Helpers

    private func getFeedImageDataResult(file: StaticString = #filePath,
                                        line: UInt = #line) -> FeedImageDataLoader.Result?
    {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed/73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")!

        let loader = RemoteFeedImageDataLoader(client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "wait for load completion")

        var recievedResult: FeedImageDataLoader.Result?
        loader.loadImageData(from: testServerURL) { result in
            recievedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        return recievedResult
    }

    private func getFeedResult(file: StaticString = #filePath,
                               line: UInt = #line) -> FeedLoader.Result?
    {
        let testServerURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json")!
        let loader = RemoteFeedLoader(url: testServerURL, client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for the load to complete")
        var recievedResult: FeedLoader.Result?
        loader.load { result in
            recievedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return recievedResult
    }

    private func ephemeralClient(file: StaticString = #filePath,
                                 line: UInt = #line) -> HTTPClient
    {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }

    private func expectedImage(at index: Int) -> FeedImage {
        return FeedImage(id: id(at: index),
                         description: description(at: index),
                         location: location(at: index),
                         url: imageURL(at: index))
    }

    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01",
        ][index])!
    }

    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8",
        ][index]
    }

    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8",
        ][index]
    }

    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index + 1).com")!
    }
}
