//
//  TaskTableViewCell.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    protocol TaskTableViewCellDelegate: AnyObject {
        func didToggleCompleted(for task: Task)
    }
    
    static let identifier = "TaskTableViewCell"
    
    private var task: Task?
    weak var delegate: TaskTableViewCellDelegate?
    
    private let statusImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(statusImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        
        separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(statusTapped))
        statusImageView.addGestureRecognizer(tapGesture)
        
        updateColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 12
        let statusSize: CGFloat = 24
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: padding/2, left: padding, bottom: padding/2, right: padding))
        
        statusImageView.frame = CGRect(x: 0,
                                       y: (contentView.frame.height - statusSize)/2,
                                       width: statusSize,
                                       height: statusSize)
        
        let labelX = statusImageView.frame.maxX + 12
        let labelWidth = contentView.frame.width - labelX
        
        titleLabel.frame = CGRect(x: labelX,
                                  y: 8,
                                  width: labelWidth,
                                  height: 22)
        
        descriptionLabel.frame = CGRect(x: labelX,
                                        y: titleLabel.frame.maxY + 2,
                                        width: labelWidth,
                                        height: descriptionLabel.intrinsicContentSize.height)
        
        dateLabel.frame = CGRect(x: labelX,
                                 y: descriptionLabel.frame.maxY + 2,
                                 width: labelWidth,
                                 height: 16)
    }
    
    func configure(with task: Task) {
        self.task = task
        let isDark = traitCollection.userInterfaceStyle == .dark
        
        if task.completed {
            titleLabel.attributedText = strikeThroughText(task.title ?? "")
        } else {
            titleLabel.attributedText = NSAttributedString(string: task.title ?? "")
        }
        
        if let desc = task.taskDescription, !desc.isEmpty {
            descriptionLabel.isHidden = false
            descriptionLabel.text = desc
        } else {
            descriptionLabel.isHidden = true
            descriptionLabel.text = nil
        }
        
        descriptionLabel.textColor = isDark ? .lightGray : .secondaryLabel
        
        if let createdAt = task.createdAt {
            dateLabel.text = DateFormatter.taskDateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = ""
        }
        dateLabel.textColor = isDark ? .lightGray : .tertiaryLabel
        
        let imageName = task.completed ? "checkmark.circle.fill" : "circle"
        statusImageView.image = UIImage(systemName: imageName)
        
        statusImageView.tintColor = isDark
        ? (task.completed ? .systemYellow : UIColor.systemYellow.withAlphaComponent(0.6))
        : (task.completed ? .systemBlue : UIColor.systemBlue.withAlphaComponent(0.6))
        
        updateColors()
    }
    
    private func updateColors() {
        if traitCollection.userInterfaceStyle == .dark {
            contentView.backgroundColor = .black
            backgroundColor = .black
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .white
            backgroundColor = .white
            titleLabel.textColor = .label
        }
    }
    
    private func strikeThroughText(_ text: String) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: text)
        attr.addAttribute(.strikethroughStyle,
                          value: NSUnderlineStyle.single.rawValue,
                          range: NSRange(location: 0, length: attr.length))
        attr.addAttribute(.foregroundColor,
                          value: UIColor.secondaryLabel,
                          range: NSRange(location: 0, length: attr.length))
        return attr
    }
    
    @objc private func statusTapped() {
        guard let task = task else { return }
        delegate?.didToggleCompleted(for: task)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }
}
