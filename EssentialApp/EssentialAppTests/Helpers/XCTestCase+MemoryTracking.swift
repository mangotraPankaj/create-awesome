//
//  XCTestCase+MemoryTracking.swift
//  EssentialAppTests
//
//  Created by Pankaj Mangotra on 04/01/22.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Memory leak.", file: file, line: line)
        }
    }
}
