//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Pankaj Mangotra on 09/09/21.
//

import XCTest

final class FeedViewController {
    init(loader:FeedViewControllerTests.LoaderSpy) {
        
    }
}
final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCellCount, 0)
    }
    
    //MARK: Helpers
    
    class LoaderSpy {
        private(set) var loadCellCount: Int = 0
    }
}
