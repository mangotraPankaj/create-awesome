//
//  HTTPURLResponse+StatusCode.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 06/12/21.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOk: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
