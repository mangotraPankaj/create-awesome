//
//  LocalFeedImageDataLoader.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 13/12/21.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum Error: Swift.Error {
        case failed
        case notFound
    }

    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    private final class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        public init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        func preventFurtherCompletions() {
            completion = nil
        }
    }

    public typealias SaveResult = Result<Void, Swift.Error>

    public func save(_ data: Data, for url: URL, completion _: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { _ in }
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) })
        }
        return task
    }
}
