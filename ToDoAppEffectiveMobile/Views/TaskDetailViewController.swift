//
//  TaskDetailViewController.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import UIKit
import CoreData

protocol TaskDetailViewControllerDelegate: AnyObject {
    func didSaveTask()
}

class TaskDetailViewController: UIViewController {

    var task: Task? // если nil — создаём новую задачу
    weak var delegate: TaskDetailViewControllerDelegate?

    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Название задачи"
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let descriptionField: UITextView = {
        let tv = UITextView()
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 8
        return tv
    }()

    private let completedSwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = task == nil ? "Новая задача" : "Редактировать задачу"

        setupViews()
        setupNavigationBar()
        populateData()
    }

    private func setupViews() {
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(completedSwitch)

        titleField.translatesAutoresizingMaskIntoConstraints = false
        descriptionField.translatesAutoresizingMaskIntoConstraints = false
        completedSwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleField.heightAnchor.constraint(equalToConstant: 44),

            descriptionField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 20),
            descriptionField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionField.heightAnchor.constraint(equalToConstant: 150),

            completedSwitch.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 20),
            completedSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(saveTapped))
    }

    private func populateData() {
        guard let task = task else { return }
        titleField.text = task.title
        descriptionField.text = task.taskDescription
        completedSwitch.isOn = task.completed
    }

    @objc private func saveTapped() {
        guard let titleText = titleField.text, !titleText.isEmpty else {
            showAlert(message: "Введите название задачи")
            return
        }

        let context = CoreDataManager.shared.context

        let taskToSave = task ?? Task(context: context)

        taskToSave.title = titleText
        taskToSave.taskDescription = descriptionField.text
        taskToSave.completed = completedSwitch.isOn
        if task == nil {
            taskToSave.createdAt = Date()
            taskToSave.id = Int64(Date().timeIntervalSince1970) // простой уникальный ID
        }

        CoreDataManager.shared.save()
        delegate?.didSaveTask()
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

