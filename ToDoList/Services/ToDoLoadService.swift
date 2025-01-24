//
//  ToDoServices.swift
//  ToDoList
//
//  Created by Илья Волощик on 21.01.25.
//

import Foundation

final class ToDoLoadService {
    static let shared = ToDoLoadService()
    private init() {}

    private let baseURL = URL(string: "https://dummyjson.com")!

    func fetchTodos(completion: @escaping (Result<[ToDo], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/todos")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ToDoResulte.self, from: data)
                UserDefaults.standard.set(true, forKey: "isDataLoaded")
                completion(.success(response.todos))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
