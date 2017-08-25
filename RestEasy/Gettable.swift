//
//  HttpGettable.swift
//  RestEasy
//
//  Created by Ryan Baldwin on 2017-08-21.
//  Copyright © 2017 bunnyhug.me. All rights reserved.
//

import Foundation

public protocol Gettable: Restable {}

extension Gettable {
    /// Creates a GET request for the current instance
    ///
    /// - Returns: The URLRequest
    /// - Throws: An HTTPMethodError when the attempt to make the URLRequest failed.
    public func request() throws -> URLRequest {
        return try HTTPMethod.get.makeURLRequest(url: "\(baseURL)\(path)")
    }
}

extension Gettable where Self: Encodable {
    /// Creates a GET request for the current instance
    ///
    /// - Returns: The URLRequest
    /// - Throws: An HTTPMethodError when the attempt to make the URLRequest failed.
    public func request() throws -> URLRequest {
        return try HTTPMethod.get.makeURLRequest(url: "\(baseURL)\(path)", body: self)
    }
}
