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
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file _: StaticString = #file, line _: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyError()))
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file _: StaticString = #file, line _: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyError()))
    }
}
