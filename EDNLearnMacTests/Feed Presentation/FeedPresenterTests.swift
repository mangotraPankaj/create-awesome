//
//  FeedPresenterTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 17/11/21.
//

import XCTest

protocol FeedErrorView {
    func display(_ viewModel: ErrorViewModel)
}

struct ErrorViewModel {
    var message: String?

    static var noError: ErrorViewModel {
        return ErrorViewModel(message: nil)
    }
}

final class FeedPresenter {
    private let errorView: FeedErrorView
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (_, view) = makeSUT()

        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy: FeedErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
        }

        private(set) var messages = [Message]()

        func display(_ viewModel: ErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
