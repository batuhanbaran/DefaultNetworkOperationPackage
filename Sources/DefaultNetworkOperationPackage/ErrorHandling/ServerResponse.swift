//
//  ServerResponse.swift
//  CartCodeCase
//
//  Created by Erkut Bas on 20.10.2020.
//

import Foundation

public enum HTTPStatusCode: Int {
    case ok = 200
    case notfound = 404
    case unauthorized = 401
}

public class ServerResponse: Codable, Error {
    public let returnMessage: String?
    public let returnCode: Int?

    public init(returnMessage: String? = nil, returnCode: Int? = nil) {
        self.returnMessage = returnMessage
        self.returnCode = returnCode
    }
}
