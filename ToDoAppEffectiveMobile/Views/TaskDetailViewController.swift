//
//  TaskDetailViewController.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

//
//  TaskDetailViewController.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman Urstem on 28.05.2025.
//

import UIKit
import CoreData

protocol TaskDetailViewControllerDelegate: AnyObject {
    func didSaveTask()
}

class TaskDetailViewController: UIViewController, UITextViewDelegate {

    var task: Task?
    var isNewTask = false
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

    private let descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Описание задачи"
        label.textColor = .placeholderText
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private let reminderLabel: UILabel = {
        let label = UILabel()
        label.text = "Напомнить в"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let reminderDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = Date()
        return picker
    }()

    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = isNewTask ? "Новая задача" : "Редактировать задачу"

        setupViews()
        setupNavigationBar()
        populateData()

        descriptionField.delegate = self
    }

    private func setupViews() {
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(reminderLabel)
        view.addSubview(reminderDatePicker)
        descriptionField.addSubview(descriptionPlaceholderLabel)

        titleField.translatesAutoresizingMaskIntoConstraints = false
        descriptionField.translatesAutoresizingMaskIntoConstraints = false
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false
        reminderDatePicker.translatesAutoresizingMaskIntoConstraints = false
        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleField.heightAnchor.constraint(equalToConstant: 44),

            descriptionField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 20),
            descriptionField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionField.heightAnchor.constraint(equalToConstant: 150),

            reminderLabel.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 20),
            reminderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            reminderDatePicker.centerYAnchor.constraint(equalTo: reminderLabel.centerYAnchor),
            reminderDatePicker.leadingAnchor.constraint(equalTo: reminderLabel.trailingAnchor, constant: 12),

            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionField.topAnchor, constant: 8),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionField.leadingAnchor, constant: 5),
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(saveTapped))
    }

    private func populateData() {
        guard let task = task else {
            descriptionPlaceholderLabel.isHidden = false
            reminderDatePicker.date = Date()
            return
        }
        titleField.text = task.title
        descriptionField.text = task.taskDescription
        descriptionPlaceholderLabel.isHidden = !(task.taskDescription?.isEmpty ?? true)

        if let reminderDate = task.reminderDate {
            reminderDatePicker.date = reminderDate
        } else {
            reminderDatePicker.date = Date()
        }
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
        if isNewTask {
            taskToSave.createdAt = Date()
            taskToSave.id = Int64(Date().timeIntervalSince1970)
        }

        taskToSave.reminderDate = reminderDatePicker.date

        CoreDataManager.shared.save()

        if let reminderDate = taskToSave.reminderDate, reminderDate > Date() {
            NotificationManager.shared.scheduleNotification(for: taskToSave, at: reminderDate)
        } else {
            NotificationManager.shared.cancelNotification(for: taskToSave)
        }

        delegate?.didSaveTask()
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
