//
//  ErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 16/11/21.
//

import Foundation

struct FeedErrorViewModel {
    var message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
