//
//  RestableConfiguration.swift
//  RestEasy
//
//  Created by Ryan Baldwin on 2017-08-22.
//  Copyright © 2017 bunnyhug.me. All rights reserved.
//

import Quick
import Nimble
@testable import RestEasy

class RestableConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a Restable"){ (sharedExampleContext: @escaping SharedExampleContext) in
            var restable: AnyRestable<Person>!
            var encodable: AnyRestable<Person>!
            var method: String!
            
            beforeEach {
                restable = sharedExampleContext()["request"] as! AnyRestable<Person>!
                encodable = sharedExampleContext()["encodable"] as! AnyRestable<Person>!
                method = sharedExampleContext()["method"] as! String
            }
            
            describe("its headers") {
                it("accepts json") {
                    expect { try restable.request().value(forHTTPHeaderField: "Accept") } == "application/json"
                }
                
                it("submits json") {
                    expect { try restable.request().value(forHTTPHeaderField: "Content-Type") } == "application/json"
                }
            }
            
            context("it fails") {
                it("completes with an HTTPError.other if an error occured.") {
                    var error: HTTPError?
                    restable.dataTaskCompletionHandler(data: nil, response: HTTPURLResponse(), error: HTTPError.noData) {
                        if case let Result.failure(err) = $0 { error = err }
                    }
                    expect(error).toEventually(equal(HTTPError.other(HTTPError.noData)))
                }
                
                it("completes with HTTPError.noResponse when the server does not respond.") {
                    var error: HTTPError?
                    restable.dataTaskCompletionHandler(data: Data(), response: nil, error: nil) {
                        if case let Result.failure(err) = $0 { error = err }
                    }
                    
                    expect(error).toEventually(equal(HTTPError.noResponse))
                }
                
                it("completes with HTTPError.unexpectedResponse when the URLResponse is not an HTTPURLResponse") {
                    var error: HTTPError?
                    let response = URLResponse()
                    restable.dataTaskCompletionHandler(data: Data(), response: response, error: nil) {
                        if case let Result.failure(err) = $0 { error = err }
                    }
                    
                    expect(error).toEventually(equal(HTTPError.unexpectedResponse(response)))
                }
                
                it("completes with HTTPError.unsuccessfulResponse when the response code is not a 2xx") {
                    var error: HTTPError?
                    let response = HTTPURLResponse(url: URL(string: "google.ca")!, statusCode: 403, httpVersion: nil, headerFields: nil)!
                    restable.dataTaskCompletionHandler(data: Data(), response: response, error: nil) {
                        if case let Result.failure(err) = $0 { error = err }
                    }
                    
                    expect(error).toEventually(equal(HTTPError.unsuccessfulResponse(response)))
                }
            }
            
            context("when encodable") {
                it("creates a DELETE request with itself as the body") {
                    let req = try? encodable.request()
                    expect(req).toNot(beNil())
                    expect(req?.httpMethod) == method
                    expect(req?.httpBody).toNot(beNil())
                }
            }
            
            it("creates a request with the appropriate method type") {
                expect { try restable.request().httpMethod }.to(equal(method))
            }
        }
    }
}
