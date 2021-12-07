//
//  LocalFeedImageDataLoaderTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 07/12/21.
//

import EDNLearnMac
import XCTest

final class LocalFeedImageDataLoader {
    init(store _: Any) {}
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(currentDate _: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }
}
