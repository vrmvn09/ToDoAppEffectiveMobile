//
//  TaskTableViewCell.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    static let identifier = "TaskTableViewCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let statusImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(statusImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        statusImageView.frame = CGRect(x: 16, y: (contentView.frame.height - 24) / 2, width: 24, height: 24)
        titleLabel.frame = CGRect(x: 56, y: 8, width: contentView.frame.width - 72, height: 22)
        dateLabel.frame = CGRect(x: 56, y: 30, width: contentView.frame.width - 72, height: 18)
    }

    func configure(with task: Task) {
        titleLabel.text = task.title
        dateLabel.text = DateFormatter.taskDateFormatter.string(from: task.createdAt)
        statusImageView.image = task.completed ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
    }
}

