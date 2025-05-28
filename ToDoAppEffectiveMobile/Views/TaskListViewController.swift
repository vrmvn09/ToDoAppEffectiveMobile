//
//  TaskListViewController.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import UIKit
import CoreData

class TaskListViewController: UIViewController {

    private var tasks: [Task] = []

    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)

    private var filteredTasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDo List"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupSearchController()
        loadTasksFromCoreData()

        if tasks.isEmpty {
            fetchTasksFromAPI()
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Tasks"
        definesPresentationContext = true
    }

    private func loadTasksFromCoreData() {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(request)
            filteredTasks = tasks
            tableView.reloadData()
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }

    private func fetchTasksFromAPI() {
        APIService.shared.fetchTodos { [weak self] result in
            switch result {
            case .success(let todos):
                self?.saveTodosToCoreData(todos)
            case .failure(let error):
                print("Failed to fetch todos from API: \(error)")
            }
        }
    }

    private func saveTodosToCoreData(_ todos: [ToDo]) {
        let context = CoreDataManager.shared.context
        context.perform {
            for todo in todos {
                let task = Task(context: context)
                task.id = Int64(todo.id)
                task.title = todo.todo
                task.completed = todo.completed
                task.createdAt = Date() // Можно улучшить, если будет дата из API
                task.taskDescription = nil
            }
            CoreDataManager.shared.save()
            self.loadTasksFromCoreData()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let task = filteredTasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        cell.configure(with: filteredTasks[indexPath.row])
        return cell
    }

    // Реализуй удаление свайпом, редактирование и т.д. по необходимости
}

// MARK: - UISearchResultsUpdating

extension TaskListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            filteredTasks = tasks
            tableView.reloadData()
            return
        }

        filteredTasks = tasks.filter { $0.title.lowercased().contains(text.lowercased()) }
        tableView.reloadData()
    }
}
