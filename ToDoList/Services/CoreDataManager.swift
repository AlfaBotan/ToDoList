//
//  TasksStore.swift
//  ToDoList
//
//  Created by Илья Волощик on 21.01.25.
//

import CoreData

import CoreData

protocol CoreDataManagerDelegate: AnyObject {
    func didChangeData(_ data: [Task])
}

final class CoreDataManager: NSObject {
    
    static let shared = CoreDataManager()
    private override init() {}
    
    weak var delegate: CoreDataManagerDelegate?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error: \(error), \(error.userInfo)")
                assertionFailure("Core Data stack setup failed")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    private var fetchedResultsController: NSFetchedResultsController<TaskCD>!
    
    func configureFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TaskCD> = TaskCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if let tasks = fetchedResultsController.fetchedObjects {
                let result = createTaskFromTaskCD(tasks: tasks)
                delegate?.didChangeData(result)
            }
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
        }
    }
        
    func saveTask(id: UUID, title: String, details: String?, date: Date, isDone: Bool) {
        context.perform { [weak self] in
            let newTask = TaskCD(context: self?.context ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
            newTask.id = id
            newTask.title = title
            newTask.details = details
            newTask.date = date
            newTask.isDone = isDone
            
            do {
                try self?.context.save()
                print("Task saved successfully")
            } catch {
                print("Failed to save task: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchTasks() -> [TaskCD]? {
        do {
            let tasks = try context.fetch(TaskCD.fetchRequest())
            return tasks
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteTask(_ task: TaskCD) {
        context.perform { [weak self] in
            self?.context.delete(task)
            do {
                try self?.context.save()
                print("Task deleted successfully")
            } catch {
                print("Failed to delete task: \(error.localizedDescription)")
            }
        }
    }
    
    func createTaskFromTaskCD( tasks: [TaskCD]) -> [Task] {
        var taskList: [Task] = []
        tasks.forEach {
            guard let id = $0.id,
                  let title = $0.title,
                  let description = $0.details,
                  let date = $0.date
            else {
                return
            }
            taskList.append(Task(id: id, title: title, description: description, date: date, isDone: $0.isDone))
        }
        return taskList
    }
    
    func deleteAllTasks() {
        context.perform { [weak self] in
            let fetchRequest: NSFetchRequest<TaskCD> = TaskCD.fetchRequest()
            do {
                let tasks = try self?.context.fetch(fetchRequest)
                tasks?.forEach { task in
                    self?.context.delete(task)
                }
                try self?.context.save()
                UserDefaults.standard.set(false, forKey: "isDataLoaded")
                print("All tasks deleted successfully")
            } catch {
                print("Failed to delete all tasks: \(error.localizedDescription)")
            }
        }
    }
    
    func updateTask(id: UUID, title: String?, details: String?, date: Date?, isDone: Bool?) {
        context.perform { [weak self] in
            let fetchRequest: NSFetchRequest<TaskCD> = TaskCD.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                if let tasks = try self?.context.fetch(fetchRequest), let task = tasks.first {
                    if let title = title {
                        task.title = title
                    }
                    if let details = details {
                        task.details = details
                    }
                    if let date = date {
                        task.date = date
                    }
                    if let isDone = isDone {
                        task.isDone = isDone
                    }
                    
                    try self?.context.save()
                    print("Task updated successfully")
                }
            } catch {
                print("Failed to update task: \(error.localizedDescription)")
            }
        }
    }
}

extension CoreDataManager: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let tasks = fetchedResultsController.fetchedObjects {
           let result = createTaskFromTaskCD(tasks: tasks)
            delegate?.didChangeData(result)
        }
    }
}

