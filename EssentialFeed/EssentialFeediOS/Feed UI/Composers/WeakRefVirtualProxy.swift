//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 10/11/21.
//

import EDNLearnMac
import UIKit

// Created a virtual proxy which will hold a weak reference to the object. This is done to move the memory management away from presenter and into the composer. We dont want to leak the implementation detail in the presenter.
// Weak reference is needed to pass the tests

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}
