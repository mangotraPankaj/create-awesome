//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Pankaj Mangotra on 27/12/21.
//

import EDNLearnMac
import XCTest

class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader

    init(primary: FeedLoader, fallback _: FeedLoader) {
        self.primary = primary
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(recievedFeed):
                XCTAssertEqual(recievedFeed, primaryFeed)

            case .failure:
                XCTFail("expected successful feed load result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    // MARK: - Helpers

    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Memory leak.", file: file, line: line)
        }
    }

    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://a-url.com")!)]
    }

    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result

        init(result: FeedLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
