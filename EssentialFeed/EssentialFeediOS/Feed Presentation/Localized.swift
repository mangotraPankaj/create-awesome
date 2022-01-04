//
//  Localized.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 16/11/21.
//

import Foundation

final class Localized {
    static var bundle: Bundle {
        Bundle(for: Localized.self)
    }
}

extension Localized {
    enum Feed {
        static var table: String { "Feed" }

        static var title: String {
            NSLocalizedString(
                "FEED_VIEW_TITLE",
                tableName: table,
                bundle: bundle,
                comment: "Title for the feed view"
            )
        }

        static var loadError: String {
            NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                              tableName: table,
                              bundle: bundle,
                              comment: "Error message when the feed is not loaded from the server")
        }
    }
}
