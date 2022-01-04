//
//  FeedLoader.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 07/06/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
