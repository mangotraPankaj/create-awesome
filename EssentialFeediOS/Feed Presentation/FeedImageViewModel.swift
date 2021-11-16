//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 13/10/21.
//

import EDNLearnMac

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}
