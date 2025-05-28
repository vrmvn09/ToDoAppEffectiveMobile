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

    func fetchTodos(completion: @escaping (Result<[ToDo], Error>) -> Void) {
        let urlString = "https://dummyjson.com/todos"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let statusCodeError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(statusCodeError))
                return
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
            }

            do {
                let todosResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                completion(.success(todosResponse.todos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
