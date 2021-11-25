//
//  FeedPresenter.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 25/11/21.
//

import Foundation

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}

public protocol FeedErrorView {
    func display(_ viewModel: ErrorViewModel)
}

public struct ErrorViewModel {
    public var message: String?

    static var noError: ErrorViewModel {
        return ErrorViewModel(message: nil)
    }

    static func error(message: String) -> ErrorViewModel {
        return ErrorViewModel(message: message)
    }
}

public final class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let feedView: FeedView

    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }

    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }

    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }

    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with _: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(.error(message: feedLoadError))
    }
}
