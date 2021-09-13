//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Pankaj Mangotra on 09/09/21.
//

import EDNLearnMac
import UIKit
import XCTest

final class FeedViewController: UIViewController {
    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        XCTAssertEqual(loader.loadCellCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCellCount, 1)
    }

    // MARK: Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    class LoaderSpy: FeedLoader {
        private(set) var loadCellCount: Int = 0

        func load(completion _: @escaping (FeedLoader.Result) -> Void) {
            loadCellCount += 1
        }
    }
}
