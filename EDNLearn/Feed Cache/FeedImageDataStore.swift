//
//  FeedImageDataStore.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 13/12/21.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
