//
//  CoreDataManagerTests.swift
//  ToDoList
//
//  Created by Илья Волощик on 26.01.25.
//

import XCTest
import CoreData
@testable import ToDoList

final class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    var persistentContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        persistentContainer = NSPersistentContainer(name: "ToDoList")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error, "Ошибка загрузки хранилища для тестов: \(error?.localizedDescription ?? "")")
        }
        
        coreDataManager = CoreDataManager.shared
        coreDataManager.persistentContainer = persistentContainer
    }
    
    override func tearDown() {
        coreDataManager = nil
        persistentContainer = nil
        super.tearDown()
    }
    
    func testSaveTask() {
        let id = UUID()
        let title = "Test Task"
        let details = "Details for test task"
        let date = Date()
        let isDone = false
        
        let expectation = XCTestExpectation(description: "Ожидание сохранения задачи")
        
        coreDataManager.saveTask(id: id, title: title, details: details, date: date, isDone: isDone)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            let tasks = self.coreDataManager.fetchTasks()
            
            XCTAssertNotNil(tasks)
            XCTAssertEqual(tasks?.count, 1)
            XCTAssertEqual(tasks?.first?.id, id)
            XCTAssertEqual(tasks?.first?.title, title)
            XCTAssertEqual(tasks?.first?.details, details)
            XCTAssertEqual(tasks?.first?.date, date)
            XCTAssertEqual(tasks?.first?.isDone, isDone)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchTasks() {
        let id = UUID()
        
        let expectation = XCTestExpectation(description: "Ожидание сохранения задачи")
        
        coreDataManager.saveTask(id: id, title: "Fetch Test", details: nil, date: Date(), isDone: false)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            
            let tasks = self.coreDataManager.fetchTasks()
            
            XCTAssertNotNil(tasks)
            XCTAssertEqual(tasks?.count, 1)
            XCTAssertEqual(tasks?.first?.id, id)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateTaskState() {
        let id = UUID()
        
        let expectation = XCTestExpectation(description: "Ожидание сохранения задачи")
        
        coreDataManager.saveTask(id: id, title: "Update Test", details: nil, date: Date(), isDone: false)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            
            self.coreDataManager.updateTaskState(id: id, isDone: true)
            let updatedTask = self.coreDataManager.fetchTasks()?.first
            
            XCTAssertNotNil(updatedTask)
            XCTAssertEqual(updatedTask?.isDone, true)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteTask() {
        let id = UUID()
        let saveExpectation = XCTestExpectation(description: "Ожидание сохранения задачи")
        let deleteExpectation = XCTestExpectation(description: "Ожидание удаления задачи")
        
        coreDataManager.saveTask(id: id, title: "Delete Test", details: nil, date: Date(), isDone: false)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            let tasksBeforeDeletion = self.coreDataManager.fetchTasks()
            
            XCTAssertEqual(tasksBeforeDeletion?.count, 1)
            XCTAssertEqual(tasksBeforeDeletion?.first?.id, id)
            
            saveExpectation.fulfill()
            
            self.coreDataManager.deleteTask(with: id)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                let tasksAfterDeletion = self.coreDataManager.fetchTasks()
                
                XCTAssertEqual(tasksAfterDeletion?.count, 0)
                
                deleteExpectation.fulfill()
            }
        }
        
        wait(for: [saveExpectation, deleteExpectation], timeout: 2.0)
    }
    
}
