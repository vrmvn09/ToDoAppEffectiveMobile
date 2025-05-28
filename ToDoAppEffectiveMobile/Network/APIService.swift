//
//  APIService.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import Foundation

class APIService {
    static let shared = APIService()
    private init() {}

    func fetchTodosFromFile(completion: @escaping (Result<[ToDo], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let url = Bundle.main.url(forResource: "todos", withExtension: "json") else {
                completion(.failure(NSError(domain: "FileNotFound", code: 404, userInfo: nil)))
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let todosResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                completion(.success(todosResponse.todos))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

