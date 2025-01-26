//
//  ToDoLoadServiceTests.swift
//  ToDoListTests
//
//  Created by Илья Волощик on 26.01.25.
//

import XCTest
@testable import ToDoList

final class ToDoLoadServiceTests: XCTestCase {
    
    private var toDoLoadService: ToDoLoadService!
    
    override func setUp() {
        super.setUp()
        toDoLoadService = ToDoLoadService.shared
        
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        URLProtocol.registerClass(URLProtocolMock.self)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolMock.self)
        toDoLoadService = nil
        super.tearDown()
    }
    
    func testFetchTodosSuccess() {
        let jsonResponse = """
        {
            "todos": [
                {"id": 1, "todo": "Task 1", "completed": false},
                {"id": 2, "todo": "Task 2", "completed": true}
            ]
        }
        """.data(using: .utf8)!
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, jsonResponse)
        }
        
        let expectation = self.expectation(description: "Todos fetched successfully")
        
        toDoLoadService.fetchTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 2)
                XCTAssertEqual(todos[0].todo, "Task 1")
                XCTAssertEqual(todos[1].completed, true)
                XCTAssertTrue(UserDefaults.standard.bool(forKey: "isDataLoaded"))
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Expected success but got failure: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTodosFailure() {
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, nil)
        }
        
        let expectation = self.expectation(description: "Todos fetch failed")
        
        toDoLoadService.fetchTodos { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
                
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertFalse(UserDefaults.standard.bool(forKey: "isDataLoaded"))
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
