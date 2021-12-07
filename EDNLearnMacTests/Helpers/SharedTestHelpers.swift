//
//  SharedTestHelpers.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 02/08/21.
//

import Foundation

func anyError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("anydata".utf8)
}
