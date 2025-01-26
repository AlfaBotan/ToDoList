//
//  URLProtocolMock.swift
//  ToDoList
//
//  Created by Илья Волощик on 26.01.25.
//

import Foundation
import XCTest

final class URLProtocolMock: URLProtocol {
    
    static var requestHandler: ((URLRequest) -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            XCTFail("Request handler is unavailable.")
            return
        }
        
        let (response, data) = handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
        
    }
    
    override func stopLoading() {}
}


