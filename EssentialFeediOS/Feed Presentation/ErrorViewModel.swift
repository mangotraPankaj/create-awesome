//
//  ErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 16/11/21.
//

import Foundation

struct ErrorViewModel {
    var message: String?
    
    static var noError: ErrorViewModel {
        return ErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ErrorViewModel {
        return ErrorViewModel(message: message)
    }
}
