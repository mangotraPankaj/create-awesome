//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 11/10/21.
//

import EDNLearnMac

// Created FeedLoadingViewModel which wraps the boolean to give more context and give us ability to add more variables to it without breaking the tests
struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void

    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    func didStartLoadingFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(FeedViewModel(feed: feed))
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with _: Error) {
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}
