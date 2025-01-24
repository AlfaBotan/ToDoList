//
//  CustomTableViewCell.swift
//  ToDoList
//
//  Created by Илья Волощик on 21.01.25.
//

import UIKit

final class CustomTableViewCell: UITableViewCell {
    
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .medium)
        let image = UIImage(systemName: "circle", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .yellow
        button.addTarget(self, action: #selector(reverseDoneButtoneState), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Сходить в магазин"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        return titleLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Купить молоко и яйца"
        descriptionLabel.textColor = .white
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.numberOfLines = 2
        return descriptionLabel
    }()
    
    private lazy var burnDateLabel: UILabel = {
        let burnDateLabel = UILabel()
        burnDateLabel.translatesAutoresizingMaskIntoConstraints = false
        burnDateLabel.text = "12:10:2024"
        burnDateLabel.textColor = .white
        burnDateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        return burnDateLabel
    }()
    
    private var taskIsDone = false
    private var id: UUID?
    
    static let identifer = "CustomTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        let interction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interction)
        [titleLabel,
         descriptionLabel,
         burnDateLabel,
         doneButton].forEach {contentView.addSubview($0)}
        
        let heightCell = contentView.heightAnchor.constraint(equalToConstant: 100)
        heightCell.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            heightCell,
            
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            doneButton.widthAnchor.constraint(equalToConstant: 40),
            doneButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 38),
            
            burnDateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            burnDateLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor),
            burnDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            burnDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configCell(data: Task) {
        taskIsDone = data.isDone
        id = data.id
        configDoneButton()
        titleLabel.text = data.title
        descriptionLabel.text = data.description
        burnDateLabel.text = DateFormatterManager.shared.dateFormatter.string(from: data.date)
    }
    
    @objc
    private func reverseDoneButtoneState() {
        guard let id = self.id else {return}
        taskIsDone.toggle()
        configDoneButton()
        CoreDataManager.shared.updateTaskState(id: id, isDone: taskIsDone)
    }
    
    private func configDoneButton() {
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .medium)
        var image = UIImage(systemName: "circle", withConfiguration: configuration)
        if taskIsDone {
            image = UIImage(systemName: "circle", withConfiguration: configuration)
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white
            burnDateLabel.textColor = .white
        } else {
            image = UIImage(systemName: "checkmark.circle", withConfiguration: configuration)
            titleLabel.textColor = .gray
            descriptionLabel.textColor = .gray
            burnDateLabel.textColor = .gray
        }
        doneButton.setImage(image, for: .normal)
    }
}

extension CustomTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
            guard let self = self,
                  let id = self.id,
                  let title = self.titleLabel.text,
                  let description = self.descriptionLabel.text
            else {return}
            print("Редактировать задачу: \(id)")
            
            let editVC = CreateNewTaskViewController()
            editVC.configVCForEditFlow(title: title, description: description, id: id)
            
            if let parentViewController = self.findViewController() {
                parentViewController.navigationController?.pushViewController(editVC, animated: true)
            }
        }
        
        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self]_ in
            
            guard let self = self,
                  let id = self.id
            else {return}
            print("Удалить задачу: \(id)")
            CoreDataManager.shared.deleteTask(with: id)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return UIMenu(children: [editAction, deleteAction])
        }
    }
}
