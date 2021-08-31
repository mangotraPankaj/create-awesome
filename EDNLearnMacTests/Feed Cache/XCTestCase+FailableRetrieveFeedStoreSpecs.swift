//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 23/08/21.
//

import EDNLearnMac
import Foundation
import XCTest

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyError()), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyError()), file: file, line: line)
    }
}
