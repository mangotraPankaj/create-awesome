//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Pankaj Mangotra on 09/09/21.
//

import UIKit
import XCTest

final class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTests.LoaderSpy?

    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load()
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCellCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCellCount, 1)
    }

    // MARK: Helpers

    class LoaderSpy {
        private(set) var loadCellCount: Int = 0

        func load() {
            loadCellCount += 1
        }
    }
}
