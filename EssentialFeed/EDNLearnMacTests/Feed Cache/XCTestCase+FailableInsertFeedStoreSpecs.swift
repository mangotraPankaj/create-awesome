//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 23/08/21.
//

import EDNLearnMac
import XCTest

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        let insertionError = insert((feed, timestamp), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
