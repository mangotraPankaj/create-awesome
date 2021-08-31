//
//  FeedLoader.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 07/06/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
