//
//  RemoteFeedItem.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 20/07/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
