//
//  HTTPClient.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 15/06/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
    func post(_ data: Data, to url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
