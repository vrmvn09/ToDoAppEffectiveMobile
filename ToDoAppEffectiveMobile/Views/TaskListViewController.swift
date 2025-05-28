//
//  TaskListViewController.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import UIKit
import CoreData

protocol TaskTableViewCellDelegate: AnyObject {
    func didToggleCompleted(for task: Task)
}

class TaskListViewController: UIViewController, TaskTableViewCell.TaskTableViewCellDelegate {

    private var tasks: [Task] = []
    private var filteredTasks: [Task] = []

    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDo List"

        setupAppearance()
        setupTableView()
        setupSearchController()
        loadTasksFromCoreData()

        if tasks.isEmpty {
            fetchTasksFromAPI()
        }

        setupAddButton()
    }

    private func setupAppearance() {
        view.backgroundColor = UIColor { $0.userInterfaceStyle == .dark ? .black : .systemGroupedBackground }
        tableView.backgroundColor = view.backgroundColor

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = view.backgroundColor
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.tintColor = UIColor { $0.userInterfaceStyle == .dark ? .systemYellow : .systemBlue }

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = view.backgroundColor
    }

    private func setupSearchController() {
        tableView.tableHeaderView = searchController.searchBar
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        definesPresentationContext = true

        searchController.searchBar.barStyle = .default
        searchController.searchBar.tintColor = navigationController?.navigationBar.tintColor
        searchController.searchBar.searchTextField.backgroundColor = UIColor { $0.userInterfaceStyle == .dark ? .darkGray : .systemGray6 }
        searchController.searchBar.searchTextField.textColor = UIColor.label
    }

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addTaskTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor { $0.userInterfaceStyle == .dark ? .systemYellow : .systemBlue }
    }

    @objc private func addTaskTapped() {
        let detailVC = TaskDetailViewController()
        detailVC.isNewTask = true
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func loadTasksFromCoreData() {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<Task> = Task.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]

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
                    print("Failed to fetch todos from API: \(error.localizedDescription)")
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
                task.createdAt = Date()
                task.taskDescription = nil
            }
            CoreDataManager.shared.save()
            DispatchQueue.main.async {
                self.loadTasksFromCoreData()
            }
        }
    }

    private func editTask(_ task: Task) {
        let detailVC = TaskDetailViewController()
        detailVC.task = task
        detailVC.isNewTask = false
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func shareTask(_ task: Task) {
        var items: [Any] = []
        if let title = task.title {
            items.append(title)
        }
        if let desc = task.taskDescription, !desc.isEmpty {
            items.append(desc)
        }
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true)
    }

    private func deleteTask(_ task: Task) {
        let alert = UIAlertController(title: "Удалить задачу?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            let context = CoreDataManager.shared.context
            context.delete(task)
            CoreDataManager.shared.save()
            self.loadTasksFromCoreData()
        }))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate, TaskTableViewCellDelegate

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let task = filteredTasks[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        
        cell.configure(with: task)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = filteredTasks[indexPath.row]
        editTask(task)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let task = filteredTasks[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.editTask(task)
            }
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
                self?.shareTask(task)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteTask(task)
            }
            return UIMenu(title: "", children: [edit, share, delete])
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let taskToDelete = self.filteredTasks[indexPath.row]
            let context = CoreDataManager.shared.context
            context.delete(taskToDelete)
            CoreDataManager.shared.save()
            self.loadTasksFromCoreData()
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = filteredTasks[indexPath.row]
        let title = task.completed ? "Отменить" : "Выполнено"
        let markAction = UIContextualAction(style: .normal, title: title) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            task.completed.toggle()
            CoreDataManager.shared.save()
            self.loadTasksFromCoreData()
            completionHandler(true)
        }
        markAction.backgroundColor = task.completed ? .systemGray : .systemGreen
        return UISwipeActionsConfiguration(actions: [markAction])
    }
    
    func didToggleCompleted(for task: Task) {
        task.completed.toggle()
        CoreDataManager.shared.save()
        loadTasksFromCoreData()
    }
}

// MARK: - UISearchResultsUpdating

extension TaskListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            filteredTasks = tasks
            tableView.reloadData()
            return
        }

        filteredTasks = tasks.filter {
            $0.title?.lowercased().contains(text.lowercased()) ?? false
        }
        tableView.reloadData()
    }
}

// MARK: - TaskDetailViewControllerDelegate

extension TaskListViewController: TaskDetailViewControllerDelegate {
    func didSaveTask() {
        loadTasksFromCoreData()
    }
}
