//
//  URLSessionHTTPClientTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 18/06/21.
//

import EDNLearnMac
import XCTest

class URLSessionHTTPClientTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }

    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { request in

            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")

            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_performPOSTRequestWithURL() {
        let url = URL(string: "http://www.google.com")!
        let anyData = Data("anyData".utf8)
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { request in

            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.httpBodyData, anyData)

            exp.fulfill()
        }
        makeSUT().post(anyData, to: url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }

    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let recievedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
        XCTAssertEqual(recievedError?.code, URLError.cancelled.rawValue)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestError = anyError()
        let recievedError = resultErrorFor((data: nil, response: nil, error: requestError))
        XCTAssertEqual((recievedError as NSError?)?.domain, requestError.domain)
        XCTAssertEqual((recievedError as NSError?)?.code, requestError.code)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }

    func test_getFromURL_SucceedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let recievedValues = resultValuesFor((data: data, response: response, error: nil))

        XCTAssertEqual(recievedValues?.data, data)
        XCTAssertEqual(recievedValues?.response.url, response.url)
        XCTAssertEqual(recievedValues?.response.statusCode, response.statusCode)
    }

    func test_getFromURL_SucceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let recievedValues = resultValuesFor((data: nil, response: response, error: nil))
        let emptyData = Data()

        XCTAssertEqual(recievedValues?.data, emptyData)
        XCTAssertEqual(recievedValues?.response.url, response.url)
        XCTAssertEqual(recievedValues?.response.statusCode, response.statusCode)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> HTTPClient
    {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]

        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                                taskHandler: (HTTPClientTask) -> Void = { _ in },
                                file: StaticString = #filePath,
                                line: UInt = #line) -> Error?
    {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?),
                                 file: StaticString = #filePath,
                                 line: UInt = #line) -> (data: Data, response: HTTPURLResponse)?
    {
        let result = resultFor(values, file: file, line: line)

        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?,
                           taskHandler: (HTTPClientTask) -> Void = { _ in },
                           file: StaticString = #filePath,
                           line: UInt = #line) -> HTTPClient.Result
    {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        var recievedResult: HTTPClient.Result!

        taskHandler(sut.get(from: anyURL()) { result in
            recievedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return recievedResult
    }

    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
